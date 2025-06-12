import 'package:cli_launcher/cli_launcher.dart';
import 'package:olx_test_runner/command_runner/command_runner.dart';

Future<void> main(List<String> arguments) async => launchExecutable(
      arguments,
      LaunchConfig(
        name: ExecutableName('olx_test_runner'),
        launchFromSelf: false,
        entrypoint: testRunnerEntryPoint,
      ),
    );
