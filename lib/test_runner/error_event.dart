import 'package:olx_test_runner/test_runner/event.dart';
import 'package:olx_test_runner/test_runner/event_type.dart';

class ErrorEvent extends Event {
  ErrorEvent({
    required this.testID,
    required this.error,
    required this.stackTrace,
    required this.isFailure,
  }) : super(type: EventType.error);

  /// Factory constructor for creating an `ErrorEvent` instance from a JSON map.
  factory ErrorEvent.fromJson(Map<String, dynamic> json) {
    return ErrorEvent(
      testID: json['testID'] as int,
      error: json['error'] as String,
      stackTrace: json['stackTrace'] as String,
      isFailure: json['isFailure'] as bool,
    );
  }

  /// The ID of the test that experienced the error.
  int testID;

  /// The result of calling `toString()` on the error object.
  String error;

  /// The error's stack trace, in the `stack_trace` package format.
  String stackTrace;

  /// Whether the error was a `TestFailure`.
  bool isFailure;

  /// Method to convert `ErrorEvent` instance into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'testID': testID,
      'error': error,
      'stackTrace': stackTrace,
      'isFailure': isFailure,
    };
  }
}
