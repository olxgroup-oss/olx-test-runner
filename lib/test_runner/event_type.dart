enum EventType {
  error,
  group,
  testStart,
  testDone,
  unknown;

  static EventType getFromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    return switch (type) {
      'group' => EventType.group,
      'testStart' => EventType.testStart,
      'testDone' => EventType.testDone,
      'error' => EventType.error,
      null || String() => EventType.unknown
    };
  }
}
