import 'package:test/test.dart';

import 'global_object.dart';

void main() {
  group('Third test', () {
    test('checking global state', () {
      expect(GlobalObject.instance.changed, isFalse);
    });
  });
}
