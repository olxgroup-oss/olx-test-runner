import 'package:mocktail/mocktail.dart';
import 'package:test/scaffolding.dart';
import 'package:test_runner/command_runner/test_group_generator_command.dart';
import 'package:test_runner/test_group_generator/test_group_generator.dart';
import 'package:test_runner/utils/cli_logger.dart';
import 'package:test_runner/utils/exit.dart';

import 'fake_command_runner.dart';

class TestGroupGeneratorMock extends Mock implements TestGroupGenerator {}

class ExitWrapperMock extends Mock implements ExitWrapper {}

void main() {
  const testFiles = 'test_files/test_runner';
  const seed = 421499543;
  const shardCount = 3;
  const shardIndex = 0;

  group('$TestGroupGeneratorCommand', () {
    late TestGroupGeneratorMock mockTestGroupGenerator;
    late ExitWrapperMock mockExitWrapper;
    late FakeCommandRunner commandRunner;

    setUpAll(() {
      CliLogger.setup(disableLogging: true);
    });

    setUp(() {
      mockTestGroupGenerator = TestGroupGeneratorMock();
      mockExitWrapper = ExitWrapperMock();
      when(
        () => mockTestGroupGenerator.generateTestGroups(
          shardCount: any(named: 'shardCount'),
          seed: any(named: 'seed'),
          testPath: any(named: 'testPath'),
        ),
      ).thenAnswer((_) => ['file_path']);
      when(
        () => mockTestGroupGenerator.generateTestGroup(
          shardCount: any(named: 'shardCount'),
          seed: any(named: 'seed'),
          testPath: any(named: 'testPath'),
          shardIndex: any(named: 'shardIndex'),
        ),
      ).thenAnswer((_) => 'file_path');
      when(() => mockExitWrapper.exit(any())).thenAnswer((_) => {});
      commandRunner = FakeCommandRunner(
        TestGroupGeneratorCommand(
          testGroupGenerator: mockTestGroupGenerator,
          exitWrapper: mockExitWrapper,
        ),
      );
    });

    test('should exit with error if shard index is invalid', () async {
      await commandRunner.run([
        'generate',
        '--shard-index',
        'invalid',
      ]);

      verify(() => mockExitWrapper.exit(1));
    });

    test('should exit with error if shard index is not positive', () async {
      await commandRunner.run([
        'generate',
        '--shard-index',
        '-1',
        '--test-path',
        testFiles,
      ]);

      verify(() => mockExitWrapper.exit(1));
    });

    test('should exit with error if shard count is invalid', () async {
      await commandRunner.run([
        'generate',
        '--shard-count',
        'invalid',
        '--test-path',
        testFiles,
      ]);

      verify(() => mockExitWrapper.exit(1));
    });

    test('should exit with error if shard count is not positive', () async {
      await commandRunner.run([
        'generate',
        '--shard-count',
        '-1',
        '--test-path',
        testFiles,
      ]);

      verify(() => mockExitWrapper.exit(1));
    });

    test('should exit with error if shard count is zero', () async {
      await commandRunner.run([
        'generate',
        '--shard-count',
        '0',
        '--test-path',
        testFiles,
      ]);

      verify(() => mockExitWrapper.exit(1));
    });

    test('should exit with error if seed is invalid', () async {
      await commandRunner.run([
        'generate',
        '--seed',
        'invalid',
        '--test-path',
        testFiles,
      ]);

      verify(() => mockExitWrapper.exit(1));
    });

    test('should exit with error if seed is not positive', () async {
      await commandRunner.run([
        'generate',
        '--seed',
        '-1',
        '--test-path',
        testFiles,
      ]);

      verify(() => mockExitWrapper.exit(1));
    });

    test('should exit with error if test path is invalid', () async {
      await commandRunner.run([
        'generate',
        '--test-path',
        '',
      ]);

      verify(() => mockExitWrapper.exit(1));
    });

    test('should exit with error if generate fails and there are no results',
        () async {
      when(
        () => mockTestGroupGenerator.generateTestGroups(
          shardCount: any(named: 'shardCount'),
          seed: any(named: 'seed'),
          testPath: any(named: 'testPath'),
        ),
      ).thenAnswer((_) => []);

      await commandRunner.run([
        'generate',
        '--test-path',
        testFiles,
      ]);

      verify(
        () => mockTestGroupGenerator.generateTestGroups(
          shardCount: any(named: 'shardCount'),
          seed: any(named: 'seed'),
          testPath: any(named: 'testPath'),
        ),
      ).called(1);

      verify(() => mockExitWrapper.exit(1));
    });

    test('should generate test groups if only test path is provided', () async {
      await commandRunner.run([
        'generate',
        '--test-path',
        testFiles,
      ]);

      verify(
        () => mockTestGroupGenerator.generateTestGroups(
          shardCount: any(named: 'shardCount'),
          seed: any(named: 'seed'),
          testPath: any(named: 'testPath'),
        ),
      ).called(1);

      verifyNever(() => mockExitWrapper.exit(1));
    });

    test('should generate test groups if test path and seed are provided',
        () async {
      await commandRunner
          .run(['generate', '--test-path', testFiles, '--seed', '$seed']);

      verify(
        () => mockTestGroupGenerator.generateTestGroups(
          shardCount: any(named: 'shardCount'),
          seed: seed,
          testPath: testFiles,
        ),
      ).called(1);

      verifyNever(() => mockExitWrapper.exit(1));
    });

    test(
        'should generate test groups if test path, seed and shard count are provided',
        () async {
      await commandRunner.run(
        [
          'generate',
          '--test-path',
          testFiles,
          '--seed',
          '$seed',
          '--shard-count',
          '$shardCount',
        ],
      );

      verify(
        () => mockTestGroupGenerator.generateTestGroups(
          shardCount: shardCount,
          seed: seed,
          testPath: testFiles,
        ),
      ).called(1);

      verifyNever(() => mockExitWrapper.exit(1));
    });

    test(
        'should generate test groups if test path, seed, shard count and shard index are provided',
        () async {
      await commandRunner.run([
        'generate',
        '--test-path',
        testFiles,
        '--seed',
        '$seed',
        '--shard-count',
        '$shardCount',
        '--shard-index',
        '$shardIndex',
      ]);

      verify(
        () => mockTestGroupGenerator.generateTestGroup(
          shardCount: shardCount,
          seed: seed,
          testPath: testFiles,
          shardIndex: shardIndex,
        ),
      ).called(1);

      verifyNever(() => mockExitWrapper.exit(1));
    });
  });
}
