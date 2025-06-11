import 'dart:io';

import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:test_runner/test_runner/test_runner.dart';
import 'package:test_runner/utils/cli_logger.dart';

import '../test_utils.dart';

void main() {
  group('$TestRunner', () {
    const testFiles = 'test_files/test_runner/';
    late TestRunner testRunner;
    setUpAll(() {
      CliLogger.setup(disableLogging: true);
    });

    setUp(() {
      testRunner = TestRunner();
    });

    test('should run correctly tests when shard count is 1', () async {
      final path = await TestUtils.getAbsolutePath(testFiles);
      final results =
          await testRunner.run(shardCount: 1, seed: 1, testPath: path);

      expect(results.length, 1);

      final result = results.first;
      expect(result.totalTestsCount, 56);
      expect(result.isSuccess, isFalse);
      expect(result.filePath.isNotEmpty, isTrue);
      expect(result.index, 0);
      expect(result.duration.inMilliseconds, isPositive);
    });

    test('should run correctly tests when shard count is greater than 1',
        () async {
      final path = await TestUtils.getAbsolutePath(testFiles);
      final results =
          await testRunner.run(shardCount: 2, seed: 1, testPath: path);
      expect(results.length, 2);

      for (var index = 0; index < results.length; index++) {
        final result = results[index];
        expect(result.totalTestsCount, isPositive);
        expect(result.filePath.isNotEmpty, isTrue);
        expect(result.index, index);
        expect(result.duration.inMilliseconds, isPositive);
      }
    });

    test('should run correctly tests when shard index is set', () async {
      final path = await TestUtils.getAbsolutePath(testFiles);
      final results = await testRunner.run(
        shardCount: 1,
        shardIndex: 0,
        seed: 1,
        testPath: path,
      );

      expect(results.length, 1);

      final result = results.first;
      expect(result.totalTestsCount, isPositive);
      expect(result.isSuccess, isFalse);
      expect(result.filePath.isNotEmpty, isTrue);
      expect(result.index, 0);
      expect(result.duration.inMilliseconds, isPositive);
    });

    test('should report empty list when tests not found', () async {
      final path = await TestUtils.getAbsolutePath('some_path/');
      final results = await testRunner.run(
        shardCount: 2,
        shardIndex: 0,
        seed: 1,
        testPath: path,
      );

      expect(results.length, 0);
    });

    test('should create result file when results path is set', () async {
      final dir = Directory('test_result');
      if (!dir.existsSync()) {
        dir.createSync();
      }

      final path = await TestUtils.getAbsolutePath(testFiles);
      final results = await testRunner.run(
        shardCount: 2,
        seed: 1,
        testPath: path,
        resultPath: dir.path,
      );

      expect(results.length, 2);

      for (var index = 0; index < results.length; index++) {
        final file = File('${dir.path}/results_$index.json');

        expect(file.existsSync(), isTrue);
        expect(file.readAsStringSync(), isNotEmpty);
        file.deleteSync();
      }
      dir.deleteSync();
    });

    test('should not create result file when results path is not set',
        () async {
      final dir = Directory('test_result');
      if (!dir.existsSync()) {
        dir.createSync();
      }

      final path = await TestUtils.getAbsolutePath(testFiles);
      final results =
          await testRunner.run(shardCount: 2, seed: 1, testPath: path);

      expect(results.length, 2);

      for (var index = 0; index < results.length; index++) {
        final file = File('${dir.path}/results_$index.json');

        expect(file.existsSync(), isFalse);
      }
      dir.deleteSync();
    });

    test('should remove test group file after test', () async {
      final path = await TestUtils.getAbsolutePath(testFiles);
      final results =
          await testRunner.run(shardCount: 1, seed: 1, testPath: path);

      expect(results.length, 1);

      expect(File(results.first.filePath).existsSync(), isFalse);
    });
  });
}
