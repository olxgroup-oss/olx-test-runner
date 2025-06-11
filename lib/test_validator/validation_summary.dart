import 'package:test_runner/test_validator/validation_result.dart';

class ValidationSummary {
  ValidationSummary({
    required this.results,
    this.isFailed = false,
    this.warningCount = 0,
    this.errorCount = 0,
  });

  final List<ValidationResult> results;
  final bool isFailed;
  final int warningCount;
  final int errorCount;
}
