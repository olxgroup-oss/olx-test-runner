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
    print("Failed tests");
    print(result.first.errorTests);
    progress.complete('Completed normal tests');
  }
}
