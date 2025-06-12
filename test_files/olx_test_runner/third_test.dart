import 'package:test/test.dart';

void main() {
  group('Parameterized Tests', () {
    test('Addition with parameterized inputs', () {
      final testData = [
        [1, 2, 3],
        [2, 3, 5],
        [-1, 1, 0],
        [0, 0, 0],
      ];
      for (final test in testData) {
        final a = test[0];
        final b = test[1];
        final expected = test[2];
        expect(a + b, equals(expected));
      }
    });
    test('Multiplication of numbers with parameterized inputs', () {
      final testData = [
        [2, 3, 6],
        [0, 5, 0],
        [-2, 3, -6],
        [10, 1, 10],
      ];
      for (final test in testData) {
        final a = test[0];
        final b = test[1];
        final expected = test[2];
        expect(a * b, equals(expected));
      }
    });
  });
  group('State Management Tests', () {
    late List<int> numbers;
    setUp(() {
      numbers = [1, 2, 3];
    });
    test('Add an element to the list', () {
      numbers.add(4);
      expect(numbers, equals([1, 2, 3, 4]));
    });
    test('Remove an element from the list', () {
      numbers.remove(2);
      expect(numbers, equals([1, 3]));
    });
    test('Clear the list', () {
      numbers.clear();
      expect(numbers, isEmpty);
    });
  });
  group('Advanced Collection Tests', () {
    test('Sorting a list of numbers', () {
      final numbers = [5, 3, 8, 1];
      // ignore: cascade_invocations
      numbers.sort();
      expect(numbers, equals([1, 3, 5, 8]));
    });
    test('Reversing a list', () {
      final numbers = [1, 2, 3];
      expect(numbers.reversed.toList(), equals([3, 2, 1]));
    });
    test('Filtering a list of numbers', () {
      final numbers = [1, 2, 3, 4, 5];
      final evenNumbers = numbers.where((n) => n.isEven).toList();
      expect(evenNumbers, equals([2, 4]));
    });
  });
  group('Error and Assertion Tests', () {
    test('Throw a custom exception', () {
      void throwError() => throw const FormatException('Invalid format!');
      expect(throwError, throwsA(isA<FormatException>()));
    });
    test('Fail with a custom error message', () {
      const result = false;
      if (!result) {
        fail('The result is not as expected!');
      }
    });
    test('Assert greater and less than', () {
      expect(5, greaterThan(2));
      expect(3, lessThan(7));
      expect(10, isNot(lessThan(5)));
    });
  });
  group('Async and Future-Based Tests', () {
    test('Async operation completes successfully', () async {
      Future<int> fetchData() async =>
          Future.delayed(const Duration(milliseconds: 500), () => 42);
      expect(await fetchData(), equals(42));
    });
    test('Async exception is thrown as expected', () async {
      Future<void> throwError() async =>
          throw Exception('Something went wrong!');
      expect(throwError, throwsA(isA<Exception>()));
    });
    test('Stream emits a sequence of values', () async {
      Stream<int> fetchNumbers() async* {
        yield 1;
        yield 2;
        yield 3;
      }

      final collectedNumbers = await fetchNumbers().toList();
      expect(collectedNumbers, equals([1, 2, 3]));
    });
  });
  group('Real-World Logic Tests', () {
    test('Check if a number is even', () {
      bool isEven(int value) => value.isEven;
      expect(isEven(2), isTrue);
      expect(isEven(3), isFalse);
    });
    test('Calculate factorial of a number', () {
      int factorial(int n) {
        if (n <= 1) return 1;
        return n * factorial(n - 1);
      }

      expect(factorial(0), equals(1));
      expect(factorial(5), equals(120));
      expect(factorial(3), equals(6));
    });

    test('Calculate greatest common divisor (GCD)', () {
      int gcd(int a, int b) {
        while (b != 0) {
          final temp = b;
          // ignore: parameter_assignments
          b = a % b;
          // ignore: parameter_assignments
          a = temp;
        }
        return a;
      }

      expect(gcd(12, 8), equals(4));
      expect(gcd(100, 25), equals(25));
      expect(gcd(42, 56), equals(14));
    });
  });
  group('Advanced String Tests', () {
    test('Capitalize the first letter of a string', () {
      String capitalize(String input) =>
          input[0].toUpperCase() + input.substring(1);
      expect(capitalize('hello'), equals('Hello'));
      expect(capitalize('dart'), equals('Dart'));
    });
    test('String splitting and joining', () {
      const text = 'hello world';
      final splitWords = text.split(' ');
      final joinedWords = splitWords.join('-');
      expect(splitWords, equals(['hello', 'world']));
      expect(joinedWords, equals('hello-world'));
    });
    test('Remove white spaces from a string', () {
      const text = '  hello world  ';
      expect(text.trim(), equals('hello world'));
    });
  });
}
