import 'package:olx_test_runner/test_group_generator/test_group_generator.dart';
import 'package:olx_test_runner/test_runner/test_runner.dart';
import 'package:olx_test_runner/utils/cli_logger.dart';

class TestGroupInterferenceDetection {
  TestGroupInterferenceDetection({TestGroupGenerator? generator, TestRunner? testRunner})
      : _generator = generator ?? TestGroupGenerator(),
        _testRunner = testRunner ?? TestRunner();

  final TestGroupGenerator _generator;
  final TestRunner _testRunner;

  Future<void> run({
    required int shardCount,
    required String testPath,
    int? shardIndex,
    int? seed,
  }) async {
    CliLogger.logInfo('Running test group normally to detect failing tests...');
    final result = await _testRunner.run(
        shardCount: shardCount,
        testPath: testPath,
        shardIndex: shardIndex,
        seed: seed,
        keepGeneratedTestGroups: true);
    CliLogger.logInfo('Analyzing results...');

    if (result.first.errorTests.isEmpty) {
      CliLogger.logInfo('No test interference detected. All tests passed.');
      return;
    }

    final firstErrorTest = result.first.errorTests.first;
    CliLogger.logInfo('Test interference detected on test: $firstErrorTest');
    // Regex pattern to match any prefix ending with '_[random-string].main()'
    RegExp pattern = RegExp(r"(.*)_[a-zA-Z0-9]+\.main\(\)");

    // Replace occurrences in the text
    final normalizedTest = firstErrorTest.replaceAllMapped(pattern, (match) {
      // Preserve the prefix group (the first captured group)
      return "${match.group(1)}.dart";
    });

    CliLogger.logInfo("The first failing test is $normalizedTest");

    final testGroups = _generator.generateTestGroup(
        shardIndex: shardIndex ?? 0, shardCount: shardCount, seed: seed, testPath: testPath);
    final sublistEndIndex =
        testGroups!.indexWhere((tg) => tg.uri.toString().contains(normalizedTest));
    final testGroupsSublist =
        sublistEndIndex != -1 ? testGroups.sublist(0, sublistEndIndex + 1) : testGroups;

    for (var index = 0; index < testGroupsSublist.length; index++) {
      CliLogger.logInfo('Testing ${index + 1}/${testGroupsSublist.length}...');
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
        final interferenceTest = interferenceTestPath.uri.toString().split('/').last;
        CliLogger.logInfo('');
        CliLogger.logSuccess('========= INTERFERENCE DETECTED =========');
        CliLogger.logSuccess(
            'Test file located in $normalizedTest has interference with ${interferenceTest}');
        CliLogger.logSuccess(
            'This means that $normalizedTest should be investigated for side effects.');
        CliLogger.logSuccess('=========================================');
        break;
      } else {
        CliLogger.logInfo('No interference solution detected in this run.');
      }
    }
  }
}
