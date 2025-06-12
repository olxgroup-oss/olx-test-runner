import 'package:mason_logger/mason_logger.dart';
import 'package:olx_test_runner/test_runner/test_event.dart';

class TestProgress {
  TestProgress({
    required this.test,
    required this.progress,
    this.completed = false,
    this.failed = false,
  });

  final Test test;
  final Progress progress;
  bool completed;
  bool failed;
}
