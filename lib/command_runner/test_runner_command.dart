import 'package:args/command_runner.dart';
import 'package:olx_test_runner/test_runner/test_runner.dart';
import 'package:olx_test_runner/utils/cli_logger.dart';
import 'package:olx_test_runner/utils/exit.dart';
import 'package:olx_test_runner/utils/input_utils.dart';

class TestRunnerCommand extends Command<void> {
  TestRunnerCommand({TestRunner? testRunner, ExitWrapper? exitWrapper})
      : _testRunner = testRunner ?? TestRunner(),
        _exitWrapper = exitWrapper ?? ExitWrapper() {
    argParser
      ..addOption(
        'shard-index',
        help: '(Optional) Index of the shard',
      )
      ..addOption('shard-count', help: '(Optional) Total count of shards')
      ..addOption(
        'seed',
        help: '(Optional) Number used to randomize test groups.',
      )
      ..addOption(
        'result-path',
        help:
            '(Optional) Path to the results tests. It will contains machine results of test.',
      )
      ..addOption(
        'coverage-path',
        help: '(Optional) Path to coverage file.',
      )
      ..addFlag(
        'coverage',
        help: '(Optional) Should test be run with coverage.',
      )
      ..addOption(
        'test-path',
        help: 'Path to the tests.',
      )
      ..addFlag(
        'keep-generated-test-groups',
        help: '(Optional) Should keep test generated groups.',
      );
  }

  final TestRunner _testRunner;
  final ExitWrapper _exitWrapper;

  @override
  String get description => 'Validates, generates and runs tests.';

  @override
  String get name => 'test';

  @override
  Future<void> run() async {
    final shardIndex = argResults?.option('shard-index');
    final shardCount = argResults?.option('shard-count');
    final seed = argResults?.option('seed');
    final testPath = argResults?.option('test-path');
    final resultPath = argResults?.option('result-path');
    final coverage = argResults?.flag('coverage');
    final coveragePath = argResults?.option('coverage-path');
    final keepGeneratedTestGroups =
        argResults?.flag('keep-generated-test-groups');

    if (shardIndex != null && !InputUtils.isNumericPositive(shardIndex)) {
      CliLogger.logError(
        'Invalid shard index. It should be a positive number. Please provide it via --shard-index option.',
      );
      return _exitWrapper.exit(1);
    }

    if (resultPath != null && resultPath.isEmpty == true) {
      CliLogger.logError(
        'Invalid result path. Please provide it via --result-path option.',
      );
      return _exitWrapper.exit(1);
    }

    if (shardCount != null &&
        !InputUtils.isNumericGreaterThanZero(shardCount)) {
      CliLogger.logError(
        'Invalid shard count. It should be a number greater than 0. Please provide it via --shard-count option.',
      );
      return _exitWrapper.exit(1);
    }

    final shardIndexNumeric = int.tryParse(shardIndex ?? '');
    final shardCountNumeric = int.tryParse(shardCount ?? '') ?? 1;

    if (shardIndexNumeric != null && shardIndexNumeric >= shardCountNumeric) {
      CliLogger.logError(
        "Shard index can't be greater or equals than shard count.",
      );
      return _exitWrapper.exit(1);
    }

    if (seed != null && !InputUtils.isNumericPositive(seed)) {
      CliLogger.logError(
        'Invalid seed. It should be a positive number. Please provide it via --seed option.',
      );
      return _exitWrapper.exit(1);
    }

    if (testPath == null || testPath.isEmpty == true) {
      CliLogger.logError(
        'Invalid test path. Please provide it via --test-path option.',
      );
      return _exitWrapper.exit(1);
    }
    if (coveragePath != null && coveragePath.isEmpty) {
      CliLogger.logError(
        'Invalid coverage path. Please provide it via --coverage-path option.',
      );
      return _exitWrapper.exit(1);
    }
    final seedNumeric = int.tryParse(seed ?? '');

    final results = await _testRunner.run(
      shardCount: shardCountNumeric,
      seed: seedNumeric,
      testPath: testPath,
      shardIndex: shardIndexNumeric,
      resultPath: resultPath,
      isCoverageEnabled: coverage,
      coveragePath: coveragePath,
      keepGeneratedTestGroups: keepGeneratedTestGroups,
    );

    if (results.any((result) => !result.isSuccess)) {
      return _exitWrapper.exit(1);
    }
  }
}
