import 'package:mocktail/mocktail.dart';
import 'package:olx_test_runner/command_runner/test_group_interference_detection_command.dart';
import 'package:olx_test_runner/test_group_interference_detection/test_group_interference_detection.dart';
import 'package:olx_test_runner/test_group_interference_detection/test_group_interference_detection_result.dart';
import 'package:olx_test_runner/utils/cli_logger.dart';
import 'package:olx_test_runner/utils/exit.dart';
import 'package:test/scaffolding.dart';
import 'package:test/test.dart';

import 'fake_command_runner.dart';

class TestGroupInterferenceDetectionMock extends Mock
    implements TestGroupInterferenceDetection {}

class ExitWrapperMock extends Mock implements ExitWrapper {}

void main() {
  const testFiles = 'test_files/olx_test_runner';
  const seed = 421499543;
  const shardCount = 3;
  const shardIndex = 0;

  group('$TestGroupInterferenceDetectionCommand', () {
    late TestGroupInterferenceDetectionMock mockTestGroupInterferenceDetection;
    late ExitWrapperMock mockExitWrapper;
    late FakeCommandRunner commandRunner;

    setUpAll(() {
      CliLogger.setup(disableLogging: true);
    });

    setUp(() {
      mockTestGroupInterferenceDetection = TestGroupInterferenceDetectionMock();
      mockExitWrapper = ExitWrapperMock();
      when(
        () => mockTestGroupInterferenceDetection.run(
          shardCount: any(named: 'shardCount'),
          seed: any(named: 'seed'),
          testPath: any(named: 'testPath'),
          shardIndex: any(named: 'shardIndex'),
        ),
      ).thenAnswer((_) async => TestGroupInterferenceDetectionResult(
          interferenceFound: true,
          firstErrorTest: 'test.dart',
          interferenceErrorTest: 'test2.dart'));

      when(() => mockExitWrapper.exit(any())).thenAnswer((_) => {});
      commandRunner = FakeCommandRunner(
        TestGroupInterferenceDetectionCommand(
          testGroupInterferenceDetection: mockTestGroupInterferenceDetection,
          exitWrapper: mockExitWrapper,
        ),
      );
    });

    test('should exit with error if shard index is invalid', () async {
      await commandRunner.run([
        'test-group-interference-detection',
        '--shard-index',
        'invalid',
      ]);

      verify(() => mockExitWrapper.exit(1));
    });

    test('should exit with error if shard index is not positive', () async {
      await commandRunner.run([
        'test-group-interference-detection',
        '--shard-index',
        '-1',
        '--test-path',
        testFiles,
      ]);

      verify(() => mockExitWrapper.exit(1));
    });

    test('should exit with error if shard count is invalid', () async {
      await commandRunner.run([
        'test-group-interference-detection',
        '--shard-count',
        'invalid',
        '--test-path',
        testFiles,
      ]);

      verify(() => mockExitWrapper.exit(1));
    });

    test('should exit with error if shard count is not positive', () async {
      await commandRunner.run([
        'test-group-interference-detection',
        '--shard-count',
        '-1',
        '--test-path',
        testFiles,
      ]);

      verify(() => mockExitWrapper.exit(1));
    });

    test('should exit with error if shard count is zero', () async {
      await commandRunner.run([
        'test-group-interference-detection',
        '--shard-count',
        '0',
        '--test-path',
        testFiles,
      ]);

      verify(() => mockExitWrapper.exit(1));
    });

    test('should exit with error if seed is invalid', () async {
      await commandRunner.run([
        'test-group-interference-detection',
        '--seed',
        'invalid',
        '--test-path',
        testFiles,
      ]);

      verify(() => mockExitWrapper.exit(1));
    });

    test('should exit with error if seed is not positive', () async {
      await commandRunner.run([
        'test-group-interference-detection',
        '--seed',
        '-1',
        '--test-path',
        testFiles,
      ]);

      verify(() => mockExitWrapper.exit(1));
    });

    test('should exit with error if test path is invalid', () async {
      await commandRunner.run([
        'test-group-interference-detection',
        '--test-path',
        '',
      ]);

      verify(() => mockExitWrapper.exit(1));
    });

    test(
        'should test interference for groups if test path, seed, shard count and shard index are provided',
        () async {
      await commandRunner.run([
        'test-group-interference-detection',
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
        () => mockTestGroupInterferenceDetection.run(
          shardCount: any(named: 'shardCount'),
          seed: any(named: 'seed'),
          testPath: any(named: 'testPath'),
          shardIndex: any(named: 'shardIndex'),
        ),
      ).called(1);

      verifyNever(() => mockExitWrapper.exit(1));
    });

    test('should exit with code 0 when interference is found', () async {
      await commandRunner.run([
        'test-group-interference-detection',
        '--test-path',
        testFiles,
        '--seed',
        '$seed',
        '--shard-count',
        '$shardCount',
        '--shard-index',
        '$shardIndex',
      ]);

      verify(() => mockExitWrapper.exit(0));
    });

    test('should exit with code 1 when interference is not found', () async {
      when(
        () => mockTestGroupInterferenceDetection.run(
          shardCount: any(named: 'shardCount'),
          seed: any(named: 'seed'),
          testPath: any(named: 'testPath'),
          shardIndex: any(named: 'shardIndex'),
        ),
      ).thenAnswer((_) async =>
          TestGroupInterferenceDetectionResult(interferenceFound: false));
      await commandRunner.run([
        'test-group-interference-detection',
        '--test-path',
        testFiles,
        '--seed',
        '$seed',
        '--shard-count',
        '$shardCount',
        '--shard-index',
        '$shardIndex',
      ]);

      verify(() => mockExitWrapper.exit(1));
    });
  });
}
