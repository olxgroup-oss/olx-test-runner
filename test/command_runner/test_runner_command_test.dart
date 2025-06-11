import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:test_runner/command_runner/test_runner_command.dart';
import 'package:test_runner/test_runner/test_result.dart';
import 'package:test_runner/test_runner/test_runner.dart';
import 'package:test_runner/utils/cli_logger.dart';
import 'package:test_runner/utils/exit.dart';

import 'fake_command_runner.dart';

class TestRunnerMock extends Mock implements TestRunner {}

class ExitWrapperMock extends Mock implements ExitWrapper {}

void main() {
  const testPath = 'test_files/test_runner';
  const seed = 421499543;
  const shardCount = 3;
  const shardIndex = 0;
  const resultPath = 'results';
  const coveragePath = 'coverage_results';

  group('$TestRunnerCommand', () {
    late TestRunnerMock mockTestRunner;
    late ExitWrapperMock mockExitWrapper;
    late FakeCommandRunner commandRunner;

    setUpAll(() {
      CliLogger.setup(disableLogging: true);
    });

    setUp(() {
      mockTestRunner = TestRunnerMock();
      mockExitWrapper = ExitWrapperMock();
      when(
        () => mockTestRunner.run(
          shardCount: any(named: 'shardCount'),
          seed: any(named: 'seed'),
          testPath: any(named: 'testPath'),
          shardIndex: any(named: 'shardIndex'),
          resultPath: any(named: 'resultPath'),
          isCoverageEnabled: any(named: 'isCoverageEnabled'),
          coveragePath: any(named: 'coveragePath'),
          keepGeneratedTestGroups: any(named: 'keepGeneratedTestGroups'),
        ),
      ).thenAnswer((_) async => []);
      when(() => mockExitWrapper.exit(any())).thenAnswer((_) => {});
      commandRunner = FakeCommandRunner(
        TestRunnerCommand(
          testRunner: mockTestRunner,
          exitWrapper: mockExitWrapper,
        ),
      );
    });

    void mockSuccessRun() {
      when(
        () => mockTestRunner.run(
          shardCount: any(named: 'shardCount'),
          seed: any(named: 'seed'),
          testPath: any(named: 'testPath'),
          shardIndex: any(named: 'shardIndex'),
          resultPath: any(named: 'resultPath'),
          isCoverageEnabled: any(named: 'isCoverageEnabled'),
          coveragePath: any(named: 'coveragePath'),
        ),
      ).thenAnswer(
        (_) async => [
          TestResult(
            index: 0,
            filePath: '',
            isSuccess: true,
            duration: Duration.zero,
            totalTestsCount: 1,
            errorTestsCount: 0,
            successTestsCount: 1,
          ),
        ],
      );
    }

    void verifyTestRunNotStarted() {
      verifyNever(
        () => mockTestRunner.run(
          shardCount: any(named: 'shardCount'),
          seed: any(named: 'seed'),
          testPath: any(named: 'testPath'),
          shardIndex: any(named: 'shardIndex'),
          resultPath: any(named: 'resultPath'),
          isCoverageEnabled: any(named: 'isCoverageEnabled'),
          coveragePath: any(named: 'coveragePath'),
        ),
      );

      verify(() => mockExitWrapper.exit(1));
    }

    test('should exit with error if shard index is invalid', () async {
      await commandRunner.run([
        'test',
        '--shard-index',
        'invalid',
        '--test-path',
        testPath,
      ]);

      verifyTestRunNotStarted();
    });

    test('should exit with error if shard index is negative', () async {
      await commandRunner.run([
        'test',
        '--shard-index',
        '-1',
        '--test-path',
        testPath,
      ]);

      verifyTestRunNotStarted();
    });

    test(
        'should exit with error if shard index is greater or equals shard count',
        () async {
      await commandRunner.run([
        'test',
        '--shard-index',
        '5',
        '--shard-count',
        '$shardCount',
        '--test-path',
        testPath,
      ]);

      verifyTestRunNotStarted();
    });

    test('should exit with error if shard count is invalid', () async {
      await commandRunner.run([
        'test',
        '--shard-count',
        'invalid',
        '--test-path',
        testPath,
      ]);

      verifyTestRunNotStarted();
    });

    test('should exit with error if shard count is negative', () async {
      await commandRunner.run([
        'test',
        '--shard-count',
        '-1',
        '--test-path',
        testPath,
      ]);

      verifyTestRunNotStarted();
    });

    test('should exit with error if shard count is zero', () async {
      await commandRunner.run([
        'test',
        '--shard-count',
        '0',
        '--test-path',
        testPath,
      ]);

      verifyTestRunNotStarted();
    });

    test('should exit with error if seed is invalid', () async {
      await commandRunner.run([
        'test',
        '--shard-count',
        '$shardCount',
        '--seed',
        'invalid',
        '--test-path',
        testPath,
      ]);

      verifyTestRunNotStarted();
    });

    test('should exit with error if seed is negative', () async {
      await commandRunner.run([
        'test',
        '--shard-count',
        '$shardCount',
        '--seed',
        '-1',
        '--test-path',
        testPath,
      ]);

      verifyTestRunNotStarted();
    });

    test('should exit with code 1 if test fails', () async {
      when(
        () => mockTestRunner.run(
          shardCount: any(named: 'shardCount'),
          seed: any(named: 'seed'),
          testPath: any(named: 'testPath'),
          shardIndex: any(named: 'shardIndex'),
          resultPath: any(named: 'resultPath'),
          isCoverageEnabled: any(named: 'isCoverageEnabled'),
          coveragePath: any(named: 'coveragePath'),
          keepGeneratedTestGroups: any(named: 'keepGeneratedTestGroups'),
        ),
      ).thenAnswer(
        (_) async => [
          TestResult(
            index: 0,
            filePath: '',
            isSuccess: false,
            duration: Duration.zero,
            totalTestsCount: 1,
            errorTestsCount: 1,
            successTestsCount: 0,
          ),
        ],
      );
      await commandRunner.run([
        'test',
        '--shard-index',
        '$shardIndex',
        '--shard-count',
        '$shardCount',
        '--seed',
        '$seed',
        '--test-path',
        testPath,
        '--result-path',
        resultPath,
      ]);
      verify(() => mockExitWrapper.exit(1));
    });

    test('should run test if only test path is provided', () async {
      mockSuccessRun();

      await commandRunner.run([
        'test',
        '--test-path',
        testPath,
      ]);

      verifyNever(() => mockExitWrapper.exit(1));
      verify(
        () => mockTestRunner.run(
          shardCount: 1,
          seed: any(named: 'seed'),
          testPath: testPath,
          shardIndex: any(named: 'shardIndex'),
          resultPath: any(named: 'resultPath'),
          isCoverageEnabled: any(named: 'isCoverageEnabled'),
          keepGeneratedTestGroups: false,
        ),
      );
    });

    test('should run test if test path and shard count are provided', () async {
      mockSuccessRun();

      await commandRunner.run([
        'test',
        '--test-path',
        testPath,
        '--shard-count',
        '$shardCount',
      ]);

      verifyNever(() => mockExitWrapper.exit(1));
      verify(
        () => mockTestRunner.run(
          shardCount: shardCount,
          seed: any(named: 'seed'),
          testPath: testPath,
          shardIndex: any(named: 'shardIndex'),
          resultPath: any(named: 'resultPath'),
          isCoverageEnabled: any(named: 'isCoverageEnabled'),
          keepGeneratedTestGroups: false,
        ),
      );
    });

    test(
        'should run test if test path, shard count and shard index are provided',
        () async {
      mockSuccessRun();

      await commandRunner.run([
        'test',
        '--test-path',
        testPath,
        '--shard-count',
        '$shardCount',
        '--shard-index',
        '$shardIndex',
      ]);

      verifyNever(() => mockExitWrapper.exit(1));
      verify(
        () => mockTestRunner.run(
          shardCount: shardCount,
          seed: any(named: 'seed'),
          testPath: testPath,
          shardIndex: shardIndex,
          resultPath: any(named: 'resultPath'),
          isCoverageEnabled: any(named: 'isCoverageEnabled'),
          keepGeneratedTestGroups: false,
        ),
      );
    });

    test(
        'should run test if test path, shard count, shard index and seed are provided',
        () async {
      mockSuccessRun();

      await commandRunner.run([
        'test',
        '--test-path',
        testPath,
        '--shard-count',
        '$shardCount',
        '--shard-index',
        '$shardIndex',
        '--seed',
        '$seed',
      ]);

      verifyNever(() => mockExitWrapper.exit(1));
      verify(
        () => mockTestRunner.run(
          shardCount: shardCount,
          seed: seed,
          testPath: testPath,
          shardIndex: shardIndex,
          resultPath: any(named: 'resultPath'),
          isCoverageEnabled: any(named: 'isCoverageEnabled'),
          keepGeneratedTestGroups: false,
        ),
      );
    });

    test(
        'should run test if test path, shard count, shard index, seed and result path are provided',
        () async {
      mockSuccessRun();

      await commandRunner.run([
        'test',
        '--test-path',
        testPath,
        '--shard-count',
        '$shardCount',
        '--shard-index',
        '$shardIndex',
        '--seed',
        '$seed',
        '--result-path',
        resultPath,
      ]);

      verifyNever(() => mockExitWrapper.exit(1));
      verify(
        () => mockTestRunner.run(
          shardCount: shardCount,
          seed: seed,
          testPath: testPath,
          shardIndex: shardIndex,
          resultPath: resultPath,
          isCoverageEnabled: any(named: 'isCoverageEnabled'),
          keepGeneratedTestGroups: false,
        ),
      );
    });

    test(
        'should run test if test path, shard count, shard index, seed, result path and coverage are provided',
        () async {
      mockSuccessRun();

      await commandRunner.run([
        'test',
        '--test-path',
        testPath,
        '--shard-count',
        '$shardCount',
        '--shard-index',
        '$shardIndex',
        '--seed',
        '$seed',
        '--result-path',
        resultPath,
        '--coverage',
      ]);

      verifyNever(() => mockExitWrapper.exit(1));
      verify(
        () => mockTestRunner.run(
          shardCount: shardCount,
          seed: seed,
          testPath: testPath,
          shardIndex: shardIndex,
          resultPath: resultPath,
          isCoverageEnabled: true,
          keepGeneratedTestGroups: false,
        ),
      );
    });

    test(
        'should run test if test path, shard count, shard index, seed, result path, coverage and coverage path are provided',
        () async {
      mockSuccessRun();

      await commandRunner.run([
        'test',
        '--test-path',
        testPath,
        '--shard-count',
        '$shardCount',
        '--shard-index',
        '$shardIndex',
        '--seed',
        '$seed',
        '--result-path',
        resultPath,
        '--coverage',
        '--coverage-path',
        coveragePath,
      ]);

      verifyNever(() => mockExitWrapper.exit(1));
      verify(
        () => mockTestRunner.run(
          shardCount: shardCount,
          seed: seed,
          testPath: testPath,
          shardIndex: shardIndex,
          resultPath: resultPath,
          isCoverageEnabled: true,
          coveragePath: coveragePath,
          keepGeneratedTestGroups: false,
        ),
      );
    });

    test(
        'should run test if test path, shard count, shard index, seed, result path, coverage, coverage path and keep generated test groups are provided',
        () async {
      mockSuccessRun();

      await commandRunner.run([
        'test',
        '--test-path',
        testPath,
        '--shard-count',
        '$shardCount',
        '--shard-index',
        '$shardIndex',
        '--seed',
        '$seed',
        '--result-path',
        resultPath,
        '--coverage',
        '--coverage-path',
        coveragePath,
        '--keep-generated-test-groups',
      ]);

      verifyNever(() => mockExitWrapper.exit(1));
      verify(
        () => mockTestRunner.run(
          shardCount: shardCount,
          seed: seed,
          testPath: testPath,
          shardIndex: shardIndex,
          resultPath: resultPath,
          isCoverageEnabled: true,
          coveragePath: coveragePath,
          keepGeneratedTestGroups: true,
        ),
      );
    });
  });
}
