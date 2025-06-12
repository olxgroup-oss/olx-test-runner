import 'package:args/command_runner.dart';
import 'package:olx_test_runner/test_group_generator/test_group_generator.dart';
import 'package:olx_test_runner/utils/cli_logger.dart';
import 'package:olx_test_runner/utils/exit.dart';
import 'package:olx_test_runner/utils/input_utils.dart';

class TestGroupGeneratorCommand extends Command<void> {
  TestGroupGeneratorCommand({
    TestGroupGenerator? testGroupGenerator,
    ExitWrapper? exitWrapper,
  })  : _testGroupGenerator = testGroupGenerator ?? TestGroupGenerator(),
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
        'test-path',
        help: 'Path to the tests.',
      );
  }

  final TestGroupGenerator _testGroupGenerator;
  final ExitWrapper _exitWrapper;

  @override
  String get description => 'Generates test group file.';

  @override
  String get name => 'generate';

  @override
  Future<void> run() async {
    final shardIndex = argResults?.option('shard-index');
    final shardCount = argResults?.option('shard-count');
    final seed = argResults?.option('seed');
    final testPath = argResults?.option('test-path');

    if (shardIndex != null && !InputUtils.isNumericPositive(shardIndex)) {
      CliLogger.logError(
        'Invalid shard index. It should be a positive number. Please provide it via --shard-index option.',
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
        'Invalid path. Please provide it via --test-path option.',
      );
      return _exitWrapper.exit(1);
    }

    final seedNumeric = int.tryParse(seed ?? '');
    final results = <String>[];

    if (shardIndexNumeric != null) {
      final file = _testGroupGenerator.generateTestGroup(
        shardIndex: shardIndexNumeric,
        shardCount: shardCountNumeric,
        seed: seedNumeric,
        testPath: testPath,
      );
      if (file != null) {
        results.add(file);
      }
    } else {
      results.addAll(
        _testGroupGenerator.generateTestGroups(
          shardCount: shardCountNumeric,
          seed: seedNumeric,
          testPath: testPath,
        ),
      );
    }

    if (results.isEmpty) {
      CliLogger.logError('No test groups were generated');
      _exitWrapper.exit(1);
    }
  }
}
