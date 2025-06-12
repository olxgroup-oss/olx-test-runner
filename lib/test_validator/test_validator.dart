import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:olx_test_runner/test_validator/validation_result.dart';
import 'package:olx_test_runner/test_validator/validation_summary.dart';
import 'package:olx_test_runner/utils/cli_logger.dart';
import 'package:olx_test_runner/utils/input_utils.dart';

class TestValidator {
  Future<ValidationSummary> validate(String testPath) async {
    CliLogger.logInfo('Validating tests at $testPath');

    if (!InputUtils.validateDirExists(testPath)) {
      CliLogger.logError('The path: `$testPath` does not exist.');
      return ValidationSummary(results: [], isFailed: true);
    }

    final progress = CliLogger.logProgress('Selecting files');
    final files = _getTestFiles(testPath);

    progress.update('Running validation...');
    final results =
        await _validateFiles(files: files, loggerProgress: progress);

    progress.complete('Completed validation');
    var warnings = 0;
    var errors = 0;
    for (final result in results) {
      warnings += result.warnings.length;
      errors += result.errors.length;
    }

    final summary = ValidationSummary(
      results: results,
      isFailed: errors != 0 || warnings != 0,
      warningCount: warnings,
      errorCount: errors,
    );

    _printResults(summary);

    return summary;
  }

  void _printResults(ValidationSummary summary) {
    for (final result in summary.results) {
      if (result.isValid) {
        CliLogger.logSuccess('${result.path} is valid.');
      } else {
        final errorsCount = result.errors.length;
        final warningsCount = result.warnings.length;
        var resultMessage = '${result.path} is invalid, detected';
        if (errorsCount != 0) {
          resultMessage += ' $errorsCount error(s).';
        }
        if (warningsCount != 0) {
          resultMessage += ' $warningsCount warning(s).';
        }
        if (errorsCount != 0) {
          CliLogger.logError(resultMessage);
        } else {
          CliLogger.logWarning(resultMessage);
        }

        for (final error in result.errors) {
          CliLogger.logError('- $error');
        }
        for (final warning in result.warnings) {
          CliLogger.logWarning('- $warning');
        }
      }
    }

    CliLogger.logInfo(
      'Total ${summary.results.length} validated files, found ${summary.errorCount} error(s) and ${summary.warningCount} warning(s).',
    );
  }

  Future<List<ValidationResult>> _validateFiles({
    required List<String> files,
    required Progress loggerProgress,
  }) async {
    if (files.isEmpty) {
      CliLogger.logError(
        'No test files found. Make sure your test files names are formatted like: your_test.dart',
      );
      return [];
    }

    final results = <ValidationResult>[];

    var currentItem = 0;
    final totalCount = files.length;

    for (final file in files) {
      currentItem += 1;
      loggerProgress.update('($currentItem/$totalCount) Validating $file');
      final validationResult = await _validateFile(file);
      results.add(validationResult);
    }

    results.sort((first, second) {
      return first.warnings.length.compareTo(second.warnings.length) |
          first.errors.length.compareTo(second.errors.length);
    });

    return results;
  }

  List<String> _getTestFiles(String path) {
    try {
      final testDirectory = Directory(path);

      final testFiles = testDirectory
          .listSync(recursive: true)
          .where(
            (entity) => entity is File && entity.path.endsWith('_test.dart'),
          )
          .toList();

      return testFiles.map((file) => file.path).toList();
    } catch (error, _) {
      CliLogger.logError(
        'Failed to generate test files list. Verify if $path exists.',
        error: error,
      );
      return [];
    }
  }

  Future<ValidationResult> _validateFile(String filePath) async {
    try {
      final file = File(filePath);

      if (!file.existsSync()) {
        return ValidationResult.invalid(
          path: filePath,
          errors: ['Error: File does not exist at $filePath'],
        );
      }

      final sourceContent = await file.readAsString();

      // Parse the Dart file
      final result = parseString(content: sourceContent);

      // Handle syntax errors, if any
      if (result.errors.isNotEmpty) {
        final errors = <String>[];
        for (final error in result.errors) {
          final lineInfo = result.lineInfo.getLocation(error.offset);
          final errorLine =
              '${error.errorCode.name} at line ${lineInfo.lineNumber}: ${error.message}';
          errors.add(errorLine);
        }
        return ValidationResult.invalid(path: filePath, errors: errors);
      }

      // Traverse the AST using our custom visitor
      final warnings = <String>[];

      final visitor =
          _TestVisitor(lineInfo: result.lineInfo, warnings: warnings);
      result.unit.visitChildren(visitor);
      visitor.validateGroupsEmptiness(); // Check for missing `group`

      if (warnings.isEmpty) {
        return ValidationResult.valid(path: filePath);
      } else {
        return ValidationResult.invalid(path: filePath, warnings: warnings);
      }
    } catch (error, _) {
      return ValidationResult.invalid(
        path: filePath,
        errors: [error.toString()],
      );
    }
  }
}

/// Custom visitor to analyze Dart test files
class _TestVisitor extends RecursiveAstVisitor<void> {
  _TestVisitor({required this.lineInfo, required this.warnings});

  final LineInfo lineInfo;
  final List<String> warnings;

  // Tracks whether we are inside a `group`
  final List<bool> _groupStack = [];

  // Tracks if any `group` is present
  bool _hasGroup = false;
  bool _hasStandaloneTest = false;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    // Identify `group` and push it onto the stack
    if (node.methodName.name == 'group') {
      // Mark that a `group` exists
      _hasGroup = true;
      _groupStack.add(true);
      node.visitChildren(this);
      // Pop the stack after leaving the group block
      _groupStack.removeLast();
      return;
    }

    // Check for `setUp`, `setUpAll`, or `test` outside any group
    if (node.methodName.name == 'setUp' ||
        node.methodName.name == 'setUpAll' ||
        node.methodName.name == 'tearDown' ||
        node.methodName.name == 'tearDownAll' ||
        node.methodName.name == 'test') {
      final location = lineInfo.getLocation(node.offset);

      // If node is a `test` outside a group, track it
      if (node.methodName.name == 'test' && _groupStack.isEmpty) {
        _hasStandaloneTest = true;
        warnings.add(
          'test found outside of a group at line ${location.lineNumber}',
        );
      }

      // If `setUp` or `setUpAll` is outside a group, warn
      if ((node.methodName.name == 'setUp' ||
              node.methodName.name == 'setUpAll' ||
              node.methodName.name == 'tearDown' ||
              node.methodName.name == 'tearDownAll') &&
          _groupStack.isEmpty) {
        warnings.add(
          '${node.methodName.name} found outside of a group at line ${location.lineNumber}',
        );
      }
    }

    super.visitMethodInvocation(node);
  }

  /// Reports a warning if no `group` is found but there are `test`, `setUp`, `setUpAll`,
  /// `tearDown`, `tearDownAll` calls
  void validateGroupsEmptiness() {
    if (!_hasGroup && _hasStandaloneTest) {
      warnings.add(
        'No test group found, but standalone test or setup methods exist.',
      );
    } else if (!_hasGroup) {
      warnings.add('No test group exists in the file.');
    }
  }
}
