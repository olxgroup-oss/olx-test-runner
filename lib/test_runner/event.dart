import 'package:test_runner/test_runner/event_type.dart';

class Event {
  Event({required this.type});

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      type: EventType.getFromJson(json),
    );
  }

  final EventType type;
}
