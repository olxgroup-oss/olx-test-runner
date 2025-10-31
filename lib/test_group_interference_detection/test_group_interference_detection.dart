import 'package:olx_test_runner/test_group_generator/test_group_generator.dart';
import 'package:olx_test_runner/test_runner/test_runner.dart';
import 'package:olx_test_runner/utils/cli_logger.dart';

class TestGroupInterferenceDetection {
  TestGroupInterferenceDetection({TestGroupGenerator? generator, TestRunner? testRunner})
      : _generator = generator ?? TestGroupGenerator(loggerEnabled: false),
        _testRunner = testRunner ?? TestRunner(loggerEnabled: false);

  final TestGroupGenerator _generator;
  final TestRunner _testRunner;

  final _filePattern = RegExp(r'(.*)_[a-zA-Z0-9]+\.main\(\)');

  Future<void> run({
    required int shardCount,
    required String testPath,
    int? shardIndex,
    int? seed,
  }) async {
    try {
      final progress = CliLogger.logProgress('Running test group to gather data...');

      final result = await _testRunner.run(
        shardCount: shardCount,
        testPath: testPath,
        shardIndex: shardIndex,
        seed: seed,
        keepGeneratedTestGroups: true,
      );

      if (result.first.errorTests.isEmpty) {
        progress.complete('No test interference detected. All tests passed.');
        return;
      }

      final firstErrorTest = result.first.errorTests.first;
      CliLogger.logInfo('');
      CliLogger.logInfo('Test interference detected on test: $firstErrorTest');


      final normalizedFirstErrorTest = firstErrorTest.replaceAllMapped(_filePattern, (match) {
        return '${match.group(1)}.dart';
      });

      CliLogger.logInfo('');
      CliLogger.logInfo('The first failing test is $normalizedFirstErrorTest');

      /// Generate test groups again to ensure we have the correct grouping
      final testGroups = _generator.generateTestGroup(
          shardIndex: shardIndex ?? 0, shardCount: shardCount, seed: seed, testPath: testPath);


      if (testGroups == null || testGroups.isEmpty) {
        progress.fail('No test groups generated. Exiting interference detection.');
        return;
      }


      /// Create a sublist of test groups up to and including the first error test
      final sublistEndIndex =
      testGroups.indexWhere((testGroupItem) =>
          testGroupItem.uri.toString().contains(normalizedFirstErrorTest));

      /// If the first error test is not found in the test groups, use the full list
      /// for interference detection
      final testGroupsSublist =
      sublistEndIndex != -1 ? testGroups.sublist(0, sublistEndIndex + 1) : testGroups;

      /// Now, iteratively run tests removing one test at a time from the start
      for (var index = 0; index < testGroupsSublist.length; index++) {
        progress.update('Testing interference ${index + 1}/${testGroupsSublist.length}.');

        final newTestGroupsSublist = testGroupsSublist.sublist(index);
        final file = _generator.createTestGroupFile(
            shardIndex: shardIndex ?? 0,
            shardCount: shardCount,
            testPath: testPath,
            groups: newTestGroupsSublist);

        final results = await _testRunner.runTests(
            shardIndex: shardIndex ?? 0,
            totalShardCount: shardCount,
            filePath: file.path,
            resultsFilePath: null);

        if (results.errorTests.isEmpty) {
          final interferenceTestPath = testGroupsSublist[index - 1];
          final interferenceTest = interferenceTestPath.uri
              .toString()
              .split('/')
              .last;
          _printInterferenceFound(progress, normalizedFirstErrorTest, interferenceTest);
          break;
        } else {
          CliLogger.logInfo('');
          CliLogger.logInfo('No interference solution detected in this run.');
        }
      }
    } catch (error, stackTrace) {
      CliLogger.logError(
        'Failed to run test group interference detection',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _printInterferenceFound(CliLoggerProgress progress, String normalizedFirstErrorTest,
      String interferenceTest) {
    progress.complete();
    CliLogger.logInfo('');
    CliLogger.logInfo('Testing completed');
    CliLogger.logSuccess('========= INTERFERENCE DETECTED =========');
    CliLogger.logSuccess(
        'Test file located in $normalizedFirstErrorTest has interference with $interferenceTest');
    CliLogger.logSuccess(
        'This means that $normalizedFirstErrorTest should be investigated for side effects.');
    CliLogger.logSuccess('=========================================');
  }
