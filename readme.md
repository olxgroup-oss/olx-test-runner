# Test runner

The Test Runner library is an solution designed to speed up unit tests on slow machines. For developers working on Flutter projects, running tests can often become a time-consuming task, especially when working with diverse environments that may not have optimal performance.
This library addresses the issue by combining individual tests into test groups, boosting the efficiency and reducing the execution time of your test suite. By leveraging smarter grouping and execution, Test Runner ensures your testing workflow is streamlined and faster, allowing you to focus on development and iteration rather than waiting for slow tests to complete.

#### Key Features:
- Improved testing speed: Combines tests into groups, minimizing overhead and speeding up execution even on low-performing machines.
- Command-Line Interface (CLI): A robust CLI tool specially tailored for Flutter projects, enabling seamless integration and easy usage.
- Optimized workflows: Focuses on providing a productive and efficient testing experience, crucial for teams working with large codebases or in challenging environments.

This library solves an ongoing problem in the Flutter community, as outlined in the issue Flutter #69429. It is your go-to tool for ensuring unit tests run swiftly.

#### Documentation:

///TODO:
Documentation can be found ![here]()

## How to use:

To activate locally, go to the path with `test_runner` directory and then run this
command:

```shell
dart pub global activate test_runner --source path
```

This will hook package from local directory into dart runtime.

To activate (not locally) latest released version, setup your ![jFrog token](https://jfrog.com/blog/how-to-use-pub-repositories-in-artifactory/) and then run this command:

```shell
dart pub global activate test_runner
```

## Commands:

### Test Group Generation Command :dart:
The Test Group Generation is a core feature of the Test Runner library that helps you generate optimized test groups for your Flutter project. This functionality is designed to make it easy to structure and execute your tests efficiently.
#### Command Overview
The command can be executed with the following syntax:
```
dart pub global run test_runner generate <options>
```
This command allows you to customize the test grouping process using various options to best fit the needs of your test environment.
#### Available Options
- `--shard-index` (Optional):
  Specifies the index of the shard to generate test groups for. This is especially useful in scenarios like distributed test execution or CI pipelines.
- `--shard-count` (Optional):
  Indicates the total number of shards, enabling a test distribution strategy that ensures all tests are executed across multiple runners efficiently.
- `--seed` (Optional):
  A numeric value used to randomize the test groups. By providing a seed, you can ensure reproducibility of the grouping process for consistent test execution.
- `--test-path` (Required):
  The path pointing to the location of your test files. This option ensures that Test Runner knows where to find and process your test suite.

Running this command will generate test groups file inside your `test-path` directory.

### Test Command :test_tube:
The Test Command is an all-in-one solution for generating, running, and displaying the results of test groups within your Flutter project's test suite. It simplifies and optimizes the entire testing process, ensuring a smooth and efficient workflow.
#### Command Overview
You can launch the test command using the following syntax:
```
dart pub global run test_runner test <options>
```
The test command handles three key tasks:
1. Generating Test Groups: Automatically organizes tests into logical groups for efficient execution.
2. Executing tests: Runs the grouped tests while offering support for additional features like coverage collection.
3. Result reporting: Displays the results of the tests and optionally saves them in specified file paths.
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


### Validate Command :white_check_mark:
The Validate Command is a powerful utility designed to ensure your tests are properly set up and conform to best practices. This command analyzes your test suite for common issues and provides a detailed report highlighting any problems. It’s an essential tool to maintain the quality and organization of your tests.
#### Command Overview
You can run the validate command using the following syntax:
```
dart pub global run test_runner validate <options>
```
After execution, the command will analyze test files and provide verbose output indicating any issues or confirming that the test files are valid.
#### Example Output
```
some_file.dart is invalid, detected 8 warning(s).
- setUp found outside of a group at line 15
- test found outside of a group at line 25
- test found outside of a group at line 40
- test found outside of a group at line 55
- test found outside of a group at line 70
- test found outside of a group at line 85
- test found outside of a group at line 100
- No test group found, but standalone test or setup methods exist.
another_test.dart is valid.

```
#### Available Options
- `--test-path` (Required):
  Specifies the path to the directory containing the test files to be validated. This ensures only relevant tests are targeted during validation.

## Support


## Example usage

Generate test groups:
```bash
dart pub global activate test_runner
dart pub global run test_runner generate --test-path ./test --seed 54382123 --shard-count 3
```

Run tests:
```bash
dart pub global activate test_runner
dart pub global run test_runner test --test-path ./test --seed 54382123 --shard-count 3 --result-path . --coverage
```

Validate test groups:
```bash
dart pub global activate test_runner
dart pub global run test_runner validate --test-path ./test -

```