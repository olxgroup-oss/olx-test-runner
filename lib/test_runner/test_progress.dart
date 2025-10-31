import 'package:olx_test_runner/test_runner/test_event.dart';
import 'package:olx_test_runner/utils/cli_logger.dart';

class TestProgress {
  TestProgress({
    required this.test,
    required this.progress,
    this.completed = false,
    this.failed = false,
  });

  final Test test;
  final CliLoggerProgress progress;
  bool completed;
  bool failed;
}
