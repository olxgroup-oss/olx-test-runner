import 'package:cli_launcher/cli_launcher.dart';
import 'package:test_runner/command_runner/command_runner.dart';

Future<void> main(List<String> arguments) async => launchExecutable(
      arguments,
      LaunchConfig(
        name: ExecutableName('test_runner'),
        launchFromSelf: false,
        entrypoint: testRunnerEntryPoint,
      ),
    );
