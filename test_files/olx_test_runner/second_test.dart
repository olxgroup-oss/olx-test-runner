// ignore_for_file: equal_elements_in_set

import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  group('Collection Tests', () {
    test('Check if list contains specific elements', () {
      final numbers = [1, 2, 3, 4, 5];
      expect(numbers, contains(3));
    });

    test('List equality check', () {
      final list1 = [1, 2, 3];
      final list2 = [1, 2, 3];
      expect(list1, equals(list2));
    });

    test('Set uniqueness', () {
      final set = {1, 2, 2, 3};
      expect(set.length, equals(3));
    });

    test('Map key existence', () {
      final map = {'name': 'Alice', 'age': 25};
      expect(map.containsKey('name'), isTrue);
    });

    test('Empty collection tests', () {
      expect(<int>[], isEmpty);
      expect(<String, dynamic>{}, isEmpty);
    });
  });

  group('Async Tests', () {
    test('Async operation completes after a delay', () async {
      Future<String> delayedOperation() async {
        await Future<void>.delayed(const Duration(seconds: 1));
        return 'Done';
      }

      expect(await delayedOperation(), equals('Done'));
    });

    test('Stream emits correct sequence of values', () async {
      Stream<int> generateSequence() async* {
        yield 1;
        yield 2;
        yield 3;
      }

      expect(await generateSequence().toList(), equals([1, 2, 3]));
    });
  });

  group('Exception Tests', () {
    test('Division by zero throws exception', () {
      expect(() => 10 ~/ 0, throwsA(isA<Exception>()));
    });

    test('Invalid type cast throws exception', () {
      const dynamic number = 42;
      expect(() => number as String, throwsA(isA<TypeError>()));
    });
  });

  group('Real-World Logic Examples', () {
    // Logical Operation: Palindrome Checker
    test('Palindrome Checker', () {
      bool isPalindrome(String word) {
        return word == word.split('').reversed.join();
      }

      expect(isPalindrome('racecar'), isTrue);
      expect(isPalindrome('hello'), isFalse);
    });

    // Prime Number Check
    test('Check if a number is prime', () {
      bool isPrime(int n) {
        if (n < 2) return false;
        for (var i = 2; i <= n ~/ 2; i++) {
          if (n % i == 0) return false;
        }
        return true;
      }

      expect(isPrime(2), isTrue);
      expect(isPrime(4), isFalse);
      expect(isPrime(17), isTrue);
    });

    // Temperature Conversion
    test('Temperature conversion from Celsius to Fahrenheit', () {
      double celsiusToFahrenheit(double celsius) => celsius * 9 / 5 + 32;

      expect(celsiusToFahrenheit(0), equals(32));
      expect(celsiusToFahrenheit(100), equals(212));
    });

    // Fibonacci Testing
    test('Fibonacci Sequence', () {
      int fibonacci(int n) {
        if (n <= 1) return n;
        return fibonacci(n - 1) + fibonacci(n - 2);
      }

      expect(fibonacci(0), equals(0));
      expect(fibonacci(1), equals(1));
      expect(fibonacci(5), equals(5));
      expect(fibonacci(10), equals(55));
    });
  });

  group('Logical Assertions', () {
    test('True and False Assertions', () {
      expect(1 > 0, isTrue);
      expect(0 > 1, isFalse);
      expect(true, isTrue);
      expect(false, isFalse);
    });

    test('Custom Matchers', () {
      const number = 42;
      expect(number, greaterThan(10));
      expect(number, lessThan(100));
      expect(number, isA<int>());
    });

    test('Equality and Inequality', () {
      expect(3 + 3, equals(6));
      expect(3 * 3, isNot(equals(10)));
    });
  });
}
