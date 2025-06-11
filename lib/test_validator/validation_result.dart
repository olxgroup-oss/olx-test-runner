class ValidationResult {
  ValidationResult({
    required this.path,
    required this.isValid,
    List<String>? warnings,
    List<String>? errors,
  })  : warnings = warnings ?? [],
        errors = errors ?? [];

  factory ValidationResult.valid({
    required String path,
    List<String>? warnings,
    List<String>? errors,
  }) =>
      ValidationResult(
        path: path,
        isValid: true,
        warnings: warnings,
        errors: errors,
      );

  factory ValidationResult.invalid({
    required String path,
    List<String>? warnings,
    List<String>? errors,
  }) =>
      ValidationResult(
        path: path,
        isValid: false,
        warnings: warnings,
        errors: errors,
      );

  final String path;
  final bool isValid;
  final List<String> warnings;
  final List<String> errors;
}
