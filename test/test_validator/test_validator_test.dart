import 'package:test/test.dart';
import 'package:test_runner/test_validator/test_validator.dart';
import 'package:test_runner/utils/cli_logger.dart';

import '../test_utils.dart';

void main() {
  group('$TestValidator', () {
    const testFiles = 'test_files/validator/';
    late TestValidator testValidator;
    setUpAll(() {
      CliLogger.setup(disableLogging: true);
    });

    setUp(() {
      testValidator = TestValidator();
    });

    test('should validate correctly valid test file', () async {
      final path = await TestUtils.getAbsolutePath('$testFiles/valid');
      final summary = await testValidator.validate(path);

      expect(summary.results.length, 1);

      final result = summary.results.first;
      expect(result.isValid, isTrue);
      expect(result.warnings, isEmpty);
      expect(result.errors, isEmpty);
      expect(summary.isFailed, false);
      expect(summary.errorCount, 0);
      expect(summary.warningCount, 0);
    });

    test('should validate correctly invalid test files', () async {
      final path = await TestUtils.getAbsolutePath('$testFiles/invalid');
      final summary = await testValidator.validate(path);

      expect(summary.results.length, 2);

      for (final result in summary.results) {
        expect(result.isValid, isFalse);
        expect(result.warnings, isNotEmpty);
        expect(result.errors, isEmpty);
      }

      expect(summary.isFailed, true);
      expect(summary.errorCount, 0);
      expect(summary.warningCount, 6);
    });

    test('should report invalid placement of helper methods', () async {
      final path = await TestUtils.getAbsolutePath('$testFiles/invalid');
      final summary = await testValidator.validate(path);

      final result = summary.results.firstWhere(
        (result) => result.path.contains('invalid_helper_methods_test'),
      );
      expect(result.warnings, [
        'setUpAll found outside of a group at line 5',
        'setUp found outside of a group at line 8',
        'tearDown found outside of a group at line 11',
        'tearDownAll found outside of a group at line 14',
      ]);
    });

    test('should report group-less tests', () async {
      final path = await TestUtils.getAbsolutePath('$testFiles/invalid');
      final summary = await testValidator.validate(path);

      final result = summary.results
          .firstWhere((result) => result.path.contains('group_less_test'));
      expect(result.warnings, [
        'test found outside of a group at line 5',
        'No test group found, but standalone test or setup methods exist.',
      ]);
    });

    test('should report empty result list if directory is empty', () async {
      final path = await TestUtils.getAbsolutePath('$testFiles/empty');
      final summary = await testValidator.validate(path);

      expect(summary.results, isEmpty);
    });
  });
}
