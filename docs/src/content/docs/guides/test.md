---
title: Test command
description: Overview of test command.
---
## Overview
Test command generates test groups and runs these test groups. 

## Command reference

You can launch the `test` command using the following syntax:
```
dart pub global run test_runner test <options>
```

#### Available Options
- `--shard-index` (Optional):
  Specifies the shard index to execute. Useful for optimizing distributed test execution.
- `--shard-count` (Optional):
  Indicates the total count of shards for distributing the test execution.
- `--seed` (Optional):
  A seed value for randomizing test groups, ensuring reproducibility of the execution process.
- `--result-path` (Optional):
  Specifies a path to save machine-readable test results. Useful for post-test analysis or integration with external systems.
- `--coverage-path` (Optional):
  Specifies the path where the coverage file should be saved.
- `--coverage` (Optional):
  Enables code coverage generation for the test run.
- `--test-path` (Required):
  Points to the directory containing your test files, ensuring only the relevant files are picked up for process execution.
- `keep-generated-test-groups` (Optional)
    Whether to keep generated test groups file.


## Example:

```shell
dart pub global run test_runner test --test-path ./test_files --coverage 
```

```shell
Building package executable... 
Built test_runner:test_runner.
Generating test groups for `./test_files`. Test group index: 0, total groups: 1 
✓ Generated test group file: ./test_files/generated_test_group_0.dart (3ms)
✓ Files generated. Running tests. (7ms)
Running test group: 1/1
✓ Test: loading /Users/jakub.homlala/StudioProjects/test_runner/test_files/generated_test_group_0.dart - success (0.5s)
Running group: Collection Tests
✓ Test: Collection Tests Check if list contains specific elements - success (3ms)
✓ Test: Collection Tests List equality check - success (1ms)
✓ Test: Collection Tests Set uniqueness - success (1ms)
✓ Test: Collection Tests Map key existence - success (1ms)
✓ Test: Collection Tests Empty collection tests - success (1ms)
Running group: Async Tests
✓ Test: Async Tests Async operation completes after a delay - success (1.0s)
✓ Test: Async Tests Stream emits correct sequence of values - success (5ms)
Running group: Exception Tests
✓ Test: Exception Tests Division by zero throws exception - success (3ms)
✓ Test: Exception Tests Invalid type cast throws exception - success (2ms)
Running group: Real-World Logic Examples
✓ Test: Real-World Logic Examples Palindrome Checker - success (2ms)
✓ Test: Real-World Logic Examples Check if a number is prime - success (2ms)
✓ Test: Real-World Logic Examples Temperature conversion from Celsius to Fahrenheit - success (2ms)
✓ Test: Real-World Logic Examples Fibonacci Sequence - success (1ms)
Running group: Logical Assertions
✓ Test: Logical Assertions True and False Assertions - success (1ms)
✓ Test: Logical Assertions Custom Matchers - success (1ms)
✓ Test: Logical Assertions Equality and Inequality - success (1ms)
Running group: Math Operations
✓ Test: Math Operations Addition of two positive numbers - success (1ms)
✓ Test: Math Operations Subtraction of two numbers - success (1ms)
✓ Test: Math Operations Multiplication of two numbers - success (1ms)
✓ Test: Math Operations Division of two numbers - success (1ms)
✓ Test: Math Operations Division by zero throws an exception - success (1ms)
Running group: String Operations
✓ Test: String Operations String equality - success (1ms)
✓ Test: String Operations String contains a substring - success (1ms)
✓ Test: String Operations String case sensitivity - success (1ms)
✓ Test: String Operations Reversed string equality - success (1ms)
✗ Test: String Operations Explicit failure test - fail (9ms)
✗ Test: String Operations Explicit failure test - fail (9ms)
Running group: Edge Cases
✓ Test: Edge Cases Large number calculation - success (0ms)
✓ Test: Edge Cases Negative numbers addition - success (1ms)
✓ Test: Edge Cases Empty list length - success (1ms)
✓ Test: Edge Cases Empty map length - success (1ms)
✓ Test: Edge Cases None/Null check - success (1ms)
✓ Test: Edge Cases Truthy values - success (1ms)
✓ Test: Edge Cases Falsy values - success (1ms)
Running group: Custom Logic
✓ Test: Custom Logic Sum of list elements - success (1ms)
✓ Test: Custom Logic Average of list elements - success (1ms)
Running group: Parameterized Tests
✓ Test: Parameterized Tests Addition with parameterized inputs - success (1ms)
✓ Test: Parameterized Tests Multiplication of numbers with parameterized inputs - success (1ms)
Running group: State Management Tests
✓ Test: State Management Tests Add an element to the list - success (1ms)
✓ Test: State Management Tests Remove an element from the list - success (1ms)
✓ Test: State Management Tests Clear the list - success (1ms)
Running group: Advanced Collection Tests
✓ Test: Advanced Collection Tests Sorting a list of numbers - success (1ms)
✓ Test: Advanced Collection Tests Reversing a list - success (1ms)
✓ Test: Advanced Collection Tests Filtering a list of numbers - success (1ms)
Running group: Error and Assertion Tests
✓ Test: Error and Assertion Tests Throw a custom exception - success (1ms)
✗ Test: Error and Assertion Tests Fail with a custom error message - fail (2ms)
✗ Test: Error and Assertion Tests Fail with a custom error message - fail (2ms)
✓ Test: Error and Assertion Tests Assert greater and less than - success (1ms)
Running group: Async and Future-Based Tests
✓ Test: Async and Future-Based Tests Async operation completes successfully - success (0.5s)
✓ Test: Async and Future-Based Tests Async exception is thrown as expected - success (8ms)
✓ Test: Async and Future-Based Tests Stream emits a sequence of values - success (3ms)
Running group: Real-World Logic Tests
✓ Test: Real-World Logic Tests Check if a number is even - success (2ms)
✓ Test: Real-World Logic Tests Calculate factorial of a number - success (2ms)
✓ Test: Real-World Logic Tests Calculate greatest common divisor (GCD) - success (2ms)
Running group: Advanced String Tests
✓ Test: Advanced String Tests Capitalize the first letter of a string - success (1ms)
✓ Test: Advanced String Tests String splitting and joining - success (2ms)
✓ Test: Advanced String Tests Remove white spaces from a string - success (2ms)
Running group: some group
✓ Test: some group some test - success (1ms)
✓ Test: some test - success (1ms)
Running group: some group
✓ Test: some group some test - success (1ms)
Completed test group 1/1
 
Running tests completed in 0:00:02.644000
1/1 - test count: 59 - success: 57 - failure: 2 - completed with failure in 0:00:02.644000
```