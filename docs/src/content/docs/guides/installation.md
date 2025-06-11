---
title: Installation
description: How to install Test Runner.
---
## Latest release


To install Test Runner, you need to run this in bash:

```shell
dart pub global activate test_runner
```

Make sure you have valid [jFrog token](https://jfrog.com/blog/how-to-use-pub-repositories-in-artifactory/) token active before running this command. 

## Locally

To use Test Runner from local path, invoke this command from the directory which contains `test_runner` sub directory.

```shell
dart pub global activate test_runner --source path
```