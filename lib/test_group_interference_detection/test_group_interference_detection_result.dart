class TestGroupInterferenceDetectionResult {
  TestGroupInterferenceDetectionResult({
    required this.interferenceFound,
    this.firstErrorTest,
    this.interferenceErrorTest,
  });

  final bool interferenceFound;

  /// The first test that failed in the initial run
  final String? firstErrorTest;

  /// The test that was identified as causing interference
  final String? interferenceErrorTest;
}
