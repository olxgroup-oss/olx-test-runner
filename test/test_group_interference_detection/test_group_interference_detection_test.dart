import 'dart:io';

import 'package:mocktail/mocktail.dart';
import 'package:olx_test_runner/test_group_interference_detection/test_group_interference_detection.dart';
import 'package:olx_test_runner/utils/cli_logger.dart';
import 'package:test/test.dart';

class MockDirectory extends Mock implements Directory {}

class MockFile extends Mock implements File {}

class MockCliLogger extends Mock implements CliLogger {}

void main() {
  const testFilesWithoutInterference =
      'test_files/interference/no_interference';
  const testFilesWithInterference = 'test_files/interference/interference';
  const seed = 421499543;
  const shardCount = 1;
  const shardIndex = 0;

  group('TestGroupInterferenceDetection', () {
    late TestGroupInterferenceDetection testGroupInterferenceDetection;

    setUpAll(() {
      CliLogger.setup(disableLogging: true);
    });

    setUp(() {
      testGroupInterferenceDetection = TestGroupInterferenceDetection();
    });

    test('should not find interference if invalid files have been provided',
        () async {
      final result = await testGroupInterferenceDetection.run(
          shardIndex: shardIndex,
          shardCount: shardCount,
          testPath: 'invalid_path',
          seed: seed);
      expect(result.interferenceFound, isFalse);
      expect(result.firstErrorTest, isNull);
      expect(result.interferenceErrorTest, isNull);
    });

    test(
        'should not find interference if valid non-interference files have been provided',
        () async {
      final result = await testGroupInterferenceDetection.run(
          shardIndex: shardIndex,
          shardCount: shardCount,
          testPath: testFilesWithoutInterference,
          seed: seed);
      expect(result.interferenceFound, isFalse);
      expect(result.firstErrorTest, isNull);
      expect(result.interferenceErrorTest, isNull);
    });

    test(
        'should find interference when valid interference files have been provided',
        () async {
      final result = await testGroupInterferenceDetection.run(
          shardIndex: shardIndex,
          shardCount: shardCount,
          testPath: testFilesWithInterference,
          seed: seed);
      expect(result.interferenceFound, isTrue);
      expect(result.firstErrorTest, 'first_test.dart');
      expect(result.interferenceErrorTest, 'second_test.dart');
    });
  });
}
