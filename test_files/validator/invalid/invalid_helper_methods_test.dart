import 'package:test/test.dart';

void main() {
  // This is wrong
  setUpAll(() {});

  // This is wrong
  setUp(() {});

  // This is wrong
  tearDown(() {});

  // This is wrong
  tearDownAll(() {});

  group('some group', () {
    test('some test', () {});
  });
}
