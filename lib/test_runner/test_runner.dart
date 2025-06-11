import 'dart:convert';
import 'dart:io';

import 'package:test_runner/test_group_generator/test_group_generator.dart';
import 'package:test_runner/test_runner/error_event.dart';
import 'package:test_runner/test_runner/event.dart';
import 'package:test_runner/test_runner/event_type.dart';
import 'package:test_runner/test_runner/group_event.dart';
import 'package:test_runner/test_runner/test_event.dart';
import 'package:test_runner/test_runner/test_progress.dart';
import 'package:test_runner/test_runner/test_result.dart';
import 'package:test_runner/utils/cli_logger.dart';

class TestRunner {
  TestRunner({TestGroupGenerator? generator})
      : _generator = generator ?? TestGroupGenerator();

  static const _skipNames = [
    '(setUp)',
    '(setUpAll)',
    '(tearDown)',
    '(tearDownAll)',
  ];

  final TestGroupGenerator _generator;

  Future<List<TestResult>> run({
    required int shardCount,
    required String testPath,
    int? shardIndex,
    int? seed,
    String? resultPath,
    bool? isCoverageEnabled,
    String? coveragePath,
    bool? keepGeneratedTestGroups,
  }) async {
    final progress = CliLogger.logProgress('Generating files');
    final results = <TestResult>[];
    final files = <String>[];
    try {
      final testGroupsFiles = _generateTestGroups(
        shardCount: shardCount,
        seed: seed,
        testPath: testPath,
        shardIndex: shardIndex,
      );
      files.addAll(testGroupsFiles);

      if (files.isEmpty) {
        progress.fail('Failed to generate test files');
        return results;
      }

      progress.complete('Files generated. Running tests.');

      for (var fileIndex = 0; fileIndex < files.length; fileIndex++) {
        results.add(
          await _runTests(
            shardIndex: fileIndex,
            totalShardCount: files.length,
            filePath: files[fileIndex],
            resultsFilePath: resultPath,
            isCoverageEnabled: isCoverageEnabled,
            coveragePath: coveragePath,
            keepGeneratedTestGroups: keepGeneratedTestGroups,
          ),
        );
      }

      final totalTime = _calculateTotalTestTime(results);

      CliLogger.logSuccess(' ');
      CliLogger.logSuccess(
        'Running tests completed in ${_formatDuration(totalTime)}',
      );

      _printTestsSummary(results);
    } catch (error, stackTrace) {
      progress.fail('Running tests failed');
      CliLogger.logError(
        'Running tests failed',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      if (keepGeneratedTestGroups != true) {
        _deleteTestGroups(files);
      }
    }
    return results;
  }

  Duration _calculateTotalTestTime(List<TestResult> results) {
    var totalTime = Duration.zero;
    for (final result in results) {
      totalTime += result.duration;
    }
    return totalTime;
  }

  void _printTestsSummary(List<TestResult> results) {
    for (final result in results) {
      final timeFormatted = _formatDuration(result.duration);
      final baseMessage =
          '${result.index + 1}/${results.length} - test count: ${result.totalTestsCount} -'
          ' success: ${result.successTestsCount} - failure: ${result.errorTestsCount} -';
      if (result.isSuccess) {
        CliLogger.logSuccess(
          '$baseMessage completed successfully in $timeFormatted',
        );
      } else {
        CliLogger.logError(
          '$baseMessage completed with failure in $timeFormatted',
        );
      }
    }
  }

  List<String> _generateTestGroups({
    required int shardCount,
    required String testPath,
    int? shardIndex,
    int? seed,
  }) {
    if (shardIndex != null) {
      final file = _generator.generateTestGroup(
        shardIndex: shardIndex,
        shardCount: shardCount,
        seed: seed,
        testPath: testPath,
      );
      if (file != null) {
        return [file];
      } else {
        return [];
      }
    } else {
      return _generator.generateTestGroups(
        shardCount: shardCount,
        seed: seed,
        testPath: testPath,
      );
    }
  }

  String _formatDuration(Duration duration) => duration.toString();

  Future<TestResult> _runTests({
    required int shardIndex,
    required int totalShardCount,
    required String filePath,
    required String? resultsFilePath,
    bool? isCoverageEnabled,
    String? coveragePath,
    bool? keepGeneratedTestGroups,
  }) async {
    try {
      String? resultsFile;
      if (resultsFilePath != null) {
        resultsFile = await _createResultsFile(
          path: resultsFilePath,
          testGroupName: 'results_$shardIndex',
        );
      }

      final stopwatch = Stopwatch()..start();
      final progressMap = <int, TestProgress>{};

      CliLogger.logInfo(
        'Running test group: ${shardIndex + 1}/$totalShardCount',
      );

      final coverageArgs = <String>[];
      if (isCoverageEnabled == true) {
        coverageArgs.add('--coverage');
      }
      if (coveragePath != null) {
        coverageArgs.addAll(['--coverage-path', coveragePath]);
      }

      final process = await Process.start(
        'flutter',
        ['test', filePath, '--machine', ...coverageArgs],
      );
      await process.stdout.transform(utf8.decoder).forEach(
            (line) => _handleLine(
              line: line,
              progressMap: progressMap,
              resultsFilePath: resultsFile,
            ),
          );

      stopwatch.stop();
      final duration = Duration(milliseconds: stopwatch.elapsedMilliseconds);

      var successCount = 0;
      var failureCount = 0;
      var failed = await process.exitCode != 0;
      for (final progress in progressMap.values) {
        if (progress.completed) {
          if (progress.failed) {
            failureCount += 1;
            failed = true;
          } else {
            successCount += 1;
          }
        }
      }

      CliLogger.logInfo(
        'Completed test group ${shardIndex + 1}/$totalShardCount',
      );
      return TestResult(
        index: shardIndex,
        filePath: filePath,
        isSuccess: !failed,
        duration: duration,
        totalTestsCount: progressMap.length,
        successTestsCount: successCount,
        errorTestsCount: failureCount,
      );
    } catch (error, stackTrace) {
      CliLogger.logError(
        'Running test failed',
        error: error,
        stackTrace: stackTrace,
      );
      return TestResult(
        index: shardIndex,
        filePath: filePath,
        isSuccess: false,
        duration: Duration.zero,
        totalTestsCount: 0,
        successTestsCount: 0,
        errorTestsCount: 1,
      );
    }
  }

  bool _shouldSkipTest(Test test) {
    final testName = test.name;
    return _skipNames.any(testName.contains);
  }

  List<Event> _getEventFromLine(String line) {
    try {
      return line
          .split('\n')
          .map((line) {
            if (line.isEmpty || line.contains('test.startedProcess')) {
              return null;
            }
            final lineJson = jsonDecode(line) as Map<String, dynamic>;
            final event = Event.fromJson(lineJson);
            switch (event.type) {
              case EventType.error:
                return ErrorEvent.fromJson(lineJson);
              case EventType.group:
                return GroupEvent.fromJson(lineJson);
              case EventType.testStart:
                return TestStartEvent.fromJson(lineJson);
              case EventType.testDone:
                return TestDoneEvent.fromJson(lineJson);
              case EventType.unknown:
                return event;
            }
          })
          .nonNulls
          .toList();
    } catch (error, stackTrace) {
      CliLogger.logError(
        'Failed to parse line: $line',
        error: error,
        stackTrace: stackTrace,
      );
    }
    return [];
  }

  void _handleLine({
    required String line,
    required Map<int, TestProgress> progressMap,
    String? resultsFilePath,
  }) {
    if (resultsFilePath != null) {
      _appendNewLineToResultsFile(filePath: resultsFilePath, line: line);
    }
    final events = _getEventFromLine(line);

    for (final event in events) {
      switch (event.type) {
        case EventType.testStart:
          final startTest = event as TestStartEvent;
          final test = startTest.test;
          if (!_shouldSkipTest(test)) {
            final progress =
                CliLogger.logProgress('Test: ${test.name} - running');
            final testProgress =
                TestProgress(test: startTest.test, progress: progress);
            progressMap[test.id] = testProgress;
          }
        case EventType.testDone:
          final testDone = event as TestDoneEvent;
          final progress = progressMap[testDone.testID];
          progress?.completed = true;

          if (progress == null) {
            continue;
          }
          if (testDone.result == 'success') {
            progress.progress.complete('Test: ${progress.test.name} - success');
          } else {
            progress.progress.fail('Test: ${progress.test.name} - fail');
            progress.failed = true;
          }
        case EventType.error:
          final error = event as ErrorEvent;
          final progress = progressMap[error.testID];
          progress?.progress.fail('Test: ${progress.test.name} - fail');
          progress?.failed = true;
        case EventType.group:
          final group = event as GroupEvent;
          final groupName = group.group.name;
          if (groupName.isNotEmpty) {
            CliLogger.logInfo('Running group: ${group.group.name}');
          }
        case EventType.unknown:
      }
    }
  }

  Future<String?> _createResultsFile({
    required String path,
    required String testGroupName,
  }) async {
    try {
      final file = File('$path/$testGroupName.json');
      if (file.existsSync()) {
        await file.delete();
      }

      await file.create();
      await file.writeAsString('');
      return file.path;
    } catch (error, stackTrace) {
      CliLogger.logError(
        'Failed to create file $testGroupName.json',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  bool _appendNewLineToResultsFile({
    required String filePath,
    required String line,
  }) {
    try {
      File(filePath).writeAsStringSync(line, mode: FileMode.append);
      return true;
    } catch (error, stackTrace) {
      CliLogger.logError(
        'Failed to append new line to file $filePath',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  void _deleteTestGroups(List<String> testGroupsFiles) {
    try {
      for (final file in testGroupsFiles) {
        File(file).deleteSync();
      }
    } catch (error, stackTrace) {
      CliLogger.logError(
        'Failed to remove test group files',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
