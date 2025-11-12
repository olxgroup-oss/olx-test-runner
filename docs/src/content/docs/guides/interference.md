---
title: Interference detection command
description: Overview of interference detection command
---
## Overview
Interference detection is a crucial aspect of maintaining reliable and consistent test suites. The `olx_test_runner` package provides a command to validate test files for potential interference issues that could lead to flaky tests.
This command analyzes test files to identify the test which may cause interference. If the interference is detected, it provides the test name for easy identification and resolution.

## Command reference

You can run the interference detection command using the following syntax:
```
dart pub global run olx_test_runner test-group-interference-detection <options>
```

#### Available Options
- `--shard-index` (Optional):
  Specifies the index of the shard to generate test groups for. This is especially useful in scenarios like distributed test execution or CI pipelines.
- `--shard-count` (Optional):
  Indicates the total number of shards, enabling a test distribution strategy that ensures all tests are executed across multiple runners efficiently.
- `--seed` (Optional):
  A numeric value used to randomize the test groups. By providing a seed, you can ensure reproducibility of the grouping process for consistent test execution.
- `--test-path` (Required):
  The path pointing to the location of your test files. This option ensures that OLX Test Runner knows where to find and process your test suite.


## Example
```shell
dart pub global run olx_test_runner test-group-interference-detection --test-path ./test_files 
```


```shell
⠧ Running test group to gather data...... (1.4s)
Test interference detected on test: third_test_61b5a55f.main()

The first failing test is third_test.dart
⠧ Testing interference 1/3.... (2.1s)
No interference solution detected in this run.
⠧ Testing interference 2/3.... (2.8s)
No interference solution detected in this run.
✓ Testing completed (3.6s)
========= INTERFERENCE DETECTED =========
Test file located in third_test.dart has interference with second_test.dart
This means that second_test.dart should be investigated for side effects.
=========================================

```