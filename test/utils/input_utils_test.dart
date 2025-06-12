import 'dart:io';

import 'package:olx_test_runner/utils/input_utils.dart';
import 'package:test/test.dart';

void main() {
  group('$InputUtils', () {
    test(
        'should return true for positive numbers when isNumericPositive has been called',
        () {
      expect(InputUtils.isNumericPositive('10'), isTrue);
    });

    test('should return true for zero when isNumericPositive has been called',
        () {
      expect(InputUtils.isNumericPositive('0'), isTrue);
    });

    test(
        'should return false for negative numbers when isNumericPositive has been called',
        () {
      expect(InputUtils.isNumericPositive('-1'), isFalse);
    });

    test(
        'should returns false for invalid input when isNumericPositive has been called',
        () {
      expect(InputUtils.isNumericPositive('abc'), isFalse);
    });

    test(
        'should return true for positive numbers greater than zero when isNumericGreaterThanZero has been called',
        () {
      expect(InputUtils.isNumericGreaterThanZero('10'), isTrue);
    });

    test(
        'should return false for zero when isNumericGreaterThanZero has been called',
        () {
      expect(InputUtils.isNumericGreaterThanZero('0'), isFalse);
    });

    test(
        'should return false for negative numbers when isNumericGreaterThanZero has been called',
        () {
      expect(InputUtils.isNumericGreaterThanZero('-1'), isFalse);
    });

    test(
        'should returs false for invalid input when isNumericGreaterThanZero has been called',
        () {
      expect(InputUtils.isNumericGreaterThanZero('abc'), isFalse);
    });

    group('validateDirExists', () {
      late Directory tempDir;

      setUp(() {
        tempDir = Directory.systemTemp.createTempSync();
      });

      tearDown(() {
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      });

      test('should return true for an existing directory', () {
        expect(InputUtils.validateDirExists(tempDir.path), isTrue);
      });

      test('should return false for a non-existing directory', () {
        final nonExistentPath = '${tempDir.path}/nonexistent';
        expect(InputUtils.validateDirExists(nonExistentPath), isFalse);
      });
    });
  });
}
