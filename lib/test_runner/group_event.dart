import 'package:test_runner/test_runner/event.dart';
import 'package:test_runner/test_runner/event_type.dart';

class GroupEvent extends Event {
  GroupEvent({required this.group}) : super(type: EventType.group);

  /// Factory constructor for creating a `GroupEvent` instance from a JSON map.
  factory GroupEvent.fromJson(Map<String, dynamic> json) {
    return GroupEvent(
      group: Group.fromJson(json['group'] as Map<String, dynamic>),
    );
  }

  /// Metadata about the group.
  Group group;

  /// Method to convert `GroupEvent` instance into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'group': group.toJson(),
    };
  }
}

class Group {
  Group({
    required this.id,
    required this.name,
    required this.suiteID,
    required this.testCount,
    this.parentID,
    this.line,
    this.column,
    this.url,
  });

  /// Factory constructor for creating a `Group` instance from a JSON map.
  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] as int,
      name: json['name'] as String,
      suiteID: json['suiteID'] as int,
      parentID: json['parentID'] as int?,
      testCount: json['testCount'] as int,
      line: json['line'] as int?,
      column: json['column'] as int?,
      url: json['url'] as String?,
    );
  }

  /// An opaque ID for the group.
  int id;

  /// The name of the group, including prefixes from any containing groups.
  String name;

  /// The ID of the suite containing this group.
  int suiteID;

  /// The ID of the group's parent group, unless it's the root group.
  int? parentID;

  /// The number of tests (recursively) within this group.
  int testCount;

  /// The (1-based) line on which the group was defined, or `null`.
  int? line;

  /// The (1-based) column on which the group was defined, or `null`.
  int? column;

  /// The URL for the file in which the group was defined, or `null`.
  String? url;

  /// Method to convert `Group` instance into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'suiteID': suiteID,
      'parentID': parentID,
      'testCount': testCount,
      'line': line,
      'column': column,
      'url': url,
    };
  }
}
