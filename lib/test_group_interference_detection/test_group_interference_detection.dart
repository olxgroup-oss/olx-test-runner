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
    final progress = CliLogger.logProgress('Running normal tests');
    final result = await _testRunner.run(
        shardCount: shardCount,
        testPath: testPath,
        shardIndex: shardIndex,
        seed: seed,
        keepGeneratedTestGroups: true);
    progress.complete('Completed normal tests');

    if (result.first.errorTests.isEmpty) {
      CliLogger.logInfo('No test interference detected.');
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
        shardIndex: shardIndex ?? 0, shardCount: shardCount, testPath: testPath);
    final sublistEndIndex =
        testGroups!.indexWhere((tg) => tg.uri.toString().contains(normalizedTest));
    final testGroupsSublist =
        sublistEndIndex != -1 ? testGroups.sublist(0, sublistEndIndex + 1) : testGroups;

    for (var index = 0; index < testGroupsSublist.length - 1; index++) {
      print("TESTING WITH INDEX $index");
      var newTestGroupsSublist = testGroupsSublist.sublist(index);
      final file = _generator.createTestGroupFile(
          shardIndex: shardIndex ?? 0,
          shardCount: shardCount,
          testPath: testPath,
          groups: newTestGroupsSublist);
      print("File created");
      print(file.existsSync());
      final results = await _testRunner.runTests(
          shardIndex: shardIndex ?? 0,
          totalShardCount: shardCount,
          filePath: file.path,
          resultsFilePath: null);
      if (results.errorTests.isEmpty) {
        final interferenceTest = testGroupsSublist[index - 1];
        CliLogger.logInfo(
            "Test interference detected! The interfering test is: ${interferenceTest.uri}");
        break;
      }
    }
  }
}
