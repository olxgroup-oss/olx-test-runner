import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  group('Math Operations', () {
    test('Addition of two positive numbers', () {
      expect(2 + 3, equals(5));
    });

    test('Subtraction of two numbers', () {
      expect(10 - 8, equals(2));
    });

    test('Multiplication of two numbers', () {
      expect(4 * 3, equals(12));
    });

    test('Division of two numbers', () {
      expect(10 / 2, equals(5));
    });

    test('Division by zero throws an exception', () {
      expect(() => 1 ~/ 0, throwsA(isA<Exception>()));
    });
  });

  group('String Operations', () {
    test('String equality', () {
      expect('hello'.toUpperCase(), equals('HELLO'));
    });

    test('String contains a substring', () {
      expect('hello world'.contains('world'), isTrue);
    });

    test('String case sensitivity', () {
      expect('python', isNot(equals('PYTHON')));
    });

    test('Reversed string equality', () {
      final reversed = 'racecar'.split('').reversed.join();
      expect(reversed, equals('racecar'));
    });

    test('Explicit failure test', () {
      fail('This test is intentionally set to fail!');
    });
  });

  group('Edge Cases', () {
    test('Large number calculation', () {
      expect(1000000 * 1000, equals(1000000000));
    });

    test('Negative numbers addition', () {
      expect(-1 + -1, equals(-2));
    });

    test('Empty list length', () {
      final emptyList = <String>[];
      expect(emptyList.length, equals(0));
    });

    test('Empty map length', () {
      final emptyMap = <String, dynamic>{};
      expect(emptyMap.length, equals(0));
    });

    test('None/Null check', () {
      String? value; // nullable variable
      expect(value, isNull);
    });

    test('Truthy values', () {
      expect(1, isNotNull);
      expect(true, isTrue);
    });

    test('Falsy values', () {
      expect(false, isFalse);
      expect(
        0,
        equals(
          0,
        ),
      ); // 0 is a valid integer, not a "falsey" boolean value in Dart.
    });
  });

  group('Custom Logic', () {
    List<int>? data;

    setUp(() {
      data = [1, 2, 3, 4, 5];
    });

    tearDown(() {
      data = null;
    });

    test('Sum of list elements', () {
      expect(data?.reduce((a, b) => a + b), equals(15));
    });

    test('Average of list elements', () {
      final average = data!.reduce((a, b) => a + b) / data!.length;
      expect(average, equals(3));
    });
  });
}
