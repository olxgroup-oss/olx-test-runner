import 'package:args/command_runner.dart';

class FakeCommandRunner extends CommandRunner<void> {
  // ignore: strict_raw_type
  FakeCommandRunner(Command command)
      : super(
          'test_runner',
          'A CLI tool for running Flutter tests.',
        ) {
    addCommand(command);
  }
}
