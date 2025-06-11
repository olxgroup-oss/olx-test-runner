import 'dart:async';
import 'package:args/command_runner.dart';
import 'package:cli_launcher/cli_launcher.dart';
import 'package:test_runner/command_runner/test_group_generator_command.dart';
import 'package:test_runner/command_runner/test_runner_command.dart';
import 'package:test_runner/command_runner/validate_test_command.dart';

class TestRunnerCommandRunner extends CommandRunner<void> {
  TestRunnerCommandRunner()
      : super(
          'test_runner',
          'A CLI tool for running Flutter tests with speed of light.',
        ) {
    addCommand(TestGroupGeneratorCommand());
    addCommand(ValidateTestCommand());
    addCommand(TestRunnerCommand());
  }
}

FutureOr<void> testRunnerEntryPoint(
  List<String> arguments,
  LaunchContext context,
) async {
  await TestRunnerCommandRunner().run(arguments);
}
