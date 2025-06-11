class TestResult {
  TestResult({
    required this.index,
    required this.filePath,
    required this.isSuccess,
    required this.duration,
    required this.totalTestsCount,
    required this.successTestsCount,
    required this.errorTestsCount,
  });

  final int index;
  final String filePath;
  final bool isSuccess;
  final Duration duration;
  final int totalTestsCount;
  final int successTestsCount;
  final int errorTestsCount;
}
