---
title: Validate command
description: Overview of validate command.
---
## Overview
Validate command validates whether tests are properly formatted.

All tests should:
1. Be wrapped in groups.
2. Have `setUp`, `setUpAll`, `tearDown`, `tearDownAll` functions in groups.

Not following these will result in flaky tests.

## Command reference

You can run the validate command using the following syntax:
```
dart pub global run test_runner validate <options>
```

#### Available Options
- `--test-path` (Required):
  Specifies the path to the directory containing the test files to be validated. This ensures only relevant tests are targeted during validation.


## Example
```shell
dart pub global run test_runner validate --test-path ./test_files 
```


```shell
Building package executable... 
Built test_runner:test_runner.
Validating tests at ./test_files
✓ Completed validation (78ms)
./test_files/test_runner/second_test.dart is valid.
./test_files/test_runner/first_test.dart is valid.
./test_files/test_runner/third_test.dart is valid.
./test_files/validator/valid/valid_test.dart is valid.
./test_files/validator/invalid/group_less_test.dart is invalid, detected 2 warning(s).
- test found outside of a group at line 5
- No test group found, but standalone test or setup methods exist.
./test_files/validator/invalid/invalid_helper_methods_test.dart is invalid, detected 4 warning(s).
- setUpAll found outside of a group at line 5
- setUp found outside of a group at line 8
- tearDown found outside of a group at line 11
- tearDownAll found outside of a group at line 14
Total 6 validated files, found 0 error(s) and 6 warning(s).
```