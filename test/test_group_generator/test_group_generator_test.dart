import 'dart:io';

import 'package:mocktail/mocktail.dart';
import 'package:olx_test_runner/test_group_generator/test_group_generator.dart';
import 'package:olx_test_runner/utils/cli_logger.dart';
import 'package:test/test.dart';

class MockDirectory extends Mock implements Directory {}

class MockFile extends Mock implements File {}

class MockCliLogger extends Mock implements CliLogger {}

void main() {
  const testFiles = 'test_files/olx_test_runner';
  const firstSeed = 421499543;
  const anotherSeed = 4214995443;
  const shardCount = 3;
  const shardIndex = 0;

  group('TestGroupGenerator', () {
    late TestGroupGenerator generator;

    setUpAll(() {
      CliLogger.setup(disableLogging: true);
    });

    setUp(() {
      generator = TestGroupGenerator();
    });

    void verifyFileContent({
      required String fileContent,
      required int shardIndex,
      required int shardCount,
    }) {
      expect(fileContent, isNotEmpty);
      expect(fileContent, contains('// OLX Test Runner generated file'));
      expect(
        fileContent,
        contains('// TEST GROUP ${shardIndex + 1}/$shardCount'),
      );
      expect(fileContent, contains('import'));
      expect(fileContent, contains('as'));
      expect(fileContent, contains('void main() {'));
      expect(fileContent, contains('.main()'));
      expect(fileContent, contains('}'));
    }

    test(
        'should returns null if no test files are found in the provided directory when generateFile has been called',
        () {
      final result = generator.generateTestGroup(
        shardIndex: shardIndex,
        shardCount: shardCount,
        testPath: 'invalid_path',
      );
      expect(result, isNull);
    });

    test(
        'should returns empty list if no test files are found in the provided directory when generateFile has been called',
        () {
      final result = generator.generateTestGroups(
        shardCount: shardCount,
        testPath: 'invalid_path',
      );
      expect(result, isEmpty);
    });

    test(
        'should generate the correct group file for sharded test when generateFile has been called',
        () {
      final result = generator.generateTestGroup(
        shardIndex: shardIndex,
        shardCount: shardCount,
        testPath: testFiles,
      );
      expect(result, isNotNull);
      final fileContent = File(result!).readAsStringSync();
      verifyFileContent(fileContent: fileContent, shardIndex: 0, shardCount: 3);
    });

    test(
        'should generate the correct group file for not sharded test when generateFile has been called',
        () {
      final result = generator.generateTestGroup(
        shardIndex: 0,
        shardCount: 1,
        testPath: testFiles,
      );
      expect(result, isNotNull);
      final fileContent = File(result!).readAsStringSync();
      verifyFileContent(fileContent: fileContent, shardIndex: 0, shardCount: 1);
    });

    test(
        'should generate the correct group files when generateFiles has been called',
        () {
      final results = generator.generateTestGroups(
        shardCount: shardCount,
        testPath: testFiles,
      );
      expect(results.length, 3);
      for (var index = 0; index < results.length; index++) {
        final result = results[index];
        final fileContent = File(result).readAsStringSync();
        verifyFileContent(
          fileContent: fileContent,
          shardIndex: index,
          shardCount: 3,
        );
      }
    });

    test(
        'should generate the correct group files when generateFiles has been called with only one group',
        () {
      final results =
          generator.generateTestGroups(shardCount: 1, testPath: testFiles);
      expect(results.length, 1);
      for (var index = 0; index < results.length; index++) {
        final result = results[index];
        final fileContent = File(result).readAsStringSync();
        verifyFileContent(
          fileContent: fileContent,
          shardIndex: index,
          shardCount: 1,
        );
      }
    });

    test('should generate different groups when different seed has been used',
        () {
      final firstResult = generator.generateTestGroup(
        shardIndex: 0,
        shardCount: 1,
        seed: firstSeed,
        testPath: testFiles,
      );
      expect(firstResult, isNotNull);
      final firstResultContent = File(firstResult!).readAsStringSync();

      final secondResult = generator.generateTestGroup(
        shardIndex: 0,
        shardCount: 1,
        seed: anotherSeed,
        testPath: testFiles,
      );
      expect(secondResult, isNotNull);
      final secondResultContent = File(secondResult!).readAsStringSync();

      expect(firstResultContent == secondResultContent, isFalse);
    });

    test('should generate the same groups when the same seed has been used',
        () {
      final firstResult = generator.generateTestGroup(
        shardIndex: 0,
        shardCount: 1,
        seed: firstSeed,
        testPath: testFiles,
      );
      expect(firstResult, isNotNull);
      final firstResultContent = File(firstResult!).readAsStringSync();

      final secondResult = generator.generateTestGroup(
        shardIndex: 0,
        shardCount: 1,
        seed: firstSeed,
        testPath: testFiles,
      );
      expect(secondResult, isNotNull);
      final secondResultContent = File(secondResult!).readAsStringSync();

      expect(firstResultContent == secondResultContent, isTrue);
    });
  });
}
