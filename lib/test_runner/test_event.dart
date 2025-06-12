import 'package:olx_test_runner/test_runner/event.dart';
import 'package:olx_test_runner/test_runner/event_type.dart';

class Test {
  Test({
    required this.id,
    required this.name,
    required this.suiteID,
    required this.groupIDs,
    this.line,
    this.column,
    this.url,
    this.rootLine,
    this.rootColumn,
    this.rootUrl,
  });

  /// Factory constructor for creating a `Test` instance from a JSON map.
  factory Test.fromJson(Map<String, dynamic> json) {
    return Test(
      id: json['id'] as int,
      name: json['name'] as String,
      suiteID: json['suiteID'] as int,
      groupIDs: List<int>.from(json['groupIDs'] as List<dynamic>),
      line: json['line'] as int?,
      column: json['column'] as int?,
      url: json['url'] as String?,
      rootLine: json['root_line'] as int?,
      rootColumn: json['root_column'] as int?,
      rootUrl: json['root_url'] as String?,
    );
  }

  /// An opaque ID for the test.
  int id;

  /// The name of the test, including prefixes from any containing groups.
  String name;

  /// The ID of the suite containing this test.
  int suiteID;

  /// The IDs of groups containing this test, in order from outermost to innermost.
  List<int> groupIDs;

  /// The (1-based) line on which the test was defined, or `null`.
  int? line;

  /// The (1-based) column on which the test was defined, or `null`.
  int? column;

  /// The URL for the file in which the test was defined, or `null`.
  String? url;

  /// The (1-based) line in the original test suite from which the test originated.
  ///
  /// Will only be present if `root_url` is different from `url`.
  int? rootLine;

  /// The (1-based) column in the original test suite from which the test originated.
  ///
  /// Will only be present if `root_url` is different from `url`.
  int? rootColumn;

  /// The URL for the original test suite in which the test was defined.
  ///
  /// Will only be present if different from `url`.
  String? rootUrl;

  /// Method to convert a `Test` instance into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'suiteID': suiteID,
      'groupIDs': groupIDs,
      'line': line,
      'column': column,
      'url': url,
      'root_line': rootLine,
      'root_column': rootColumn,
      'root_url': rootUrl,
    };
  }
}

class TestStartEvent extends Event {
  TestStartEvent({required this.test}) : super(type: EventType.testStart);

  /// Factory constructor for creating a `TestStartEvent` instance from a JSON map.
  factory TestStartEvent.fromJson(Map<String, dynamic> json) {
    return TestStartEvent(
      test: Test.fromJson(json['test'] as Map<String, dynamic>),
    );
  }

  /// Metadata about the test that started.
  Test test;

  /// Method to convert a `TestStartEvent` instance into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'test': test.toJson(),
    };
  }
}

class TestDoneEvent extends Event {
  TestDoneEvent({
    required this.testID,
    required this.result,
    required this.hidden,
    required this.skipped,
  }) : super(type: EventType.testDone);

  /// Factory constructor for creating a `TestDoneEvent` instance from a JSON map.
  factory TestDoneEvent.fromJson(Map<String, dynamic> json) {
    return TestDoneEvent(
      testID: json['testID'] as int,
      result: json['result'] as String,
      hidden: json['hidden'] as bool,
      skipped: json['skipped'] as bool,
    );
  }

  /// The ID of the test that completed.
  int testID;

  /// The result of the test.
  String result;

  /// Whether the test's result should be hidden.
  bool hidden;

  /// Whether the test (or some part of it) was skipped.
  bool skipped;

  /// Method to convert `TestDoneEvent` instance into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'testID': testID,
      'result': result,
      'hidden': hidden,
      'skipped': skipped,
    };
  }
}
