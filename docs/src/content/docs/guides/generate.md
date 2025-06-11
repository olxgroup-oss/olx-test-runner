---
title: Generate command
description: Overview of generate command.
---
## Overview
Generate command creates optimized test group based on the test files. It will create new dart file which later can be used with `flutter test` command.

## Command reference

The command can be executed with the following syntax:
```
dart pub global run test_runner generate <options>
```

#### Available Options
- `--shard-index` (Optional):
  Specifies the index of the shard to generate test groups for. This is especially useful in scenarios like distributed test execution or CI pipelines.
- `--shard-count` (Optional):
  Indicates the total number of shards, enabling a test distribution strategy that ensures all tests are executed across multiple runners efficiently.
- `--seed` (Optional):
  A numeric value used to randomize the test groups. By providing a seed, you can ensure reproducibility of the grouping process for consistent test execution.
- `--test-path` (Required):
  The path pointing to the location of your test files. This option ensures that Test Runner knows where to find and process your test suite.

## Example:

```shell
dart pub global run test_runner generate --shard-index 1 --shard-count 1 --seed 12345 --test-path test_files/test_runner
```



```dart
// Test Runner generated file
// TEST GROUP 1/1
import 'first_test.dart' as first_test_6b37a5f5;
import 'second_test.dart' as second_test_043b5507;
import 'third_test.dart' as third_test_3ac19fec;

void main() {
  first_test_6b37a5f5.main();
  second_test_043b5507.main();
  third_test_3ac19fec.main();
}

```