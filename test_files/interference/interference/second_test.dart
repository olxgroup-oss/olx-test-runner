import 'package:test/test.dart';

import 'global_object.dart';

void main() {
  group('First test', () {
    setUpAll(() {
      GlobalObject.instance.changed = true;
    });

    test('checking global state', () {
      expect(true, isTrue);
    });
  });
}
