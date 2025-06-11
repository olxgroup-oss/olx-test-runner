import 'package:test/test.dart';

void main() {
  group('some group', () {
    // This is valid
    setUpAll(() {});

    // This is valid
    setUp(() {});

    test('some test', () {});
  });
}
