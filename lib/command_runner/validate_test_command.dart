import 'package:args/command_runner.dart';
import 'package:test_runner/test_validator/test_validator.dart';
import 'package:test_runner/utils/cli_logger.dart';
import 'package:test_runner/utils/exit.dart';

class ValidateTestCommand extends Command<void> {
  ValidateTestCommand({TestValidator? testValidator, ExitWrapper? exitWrapper})
      : _testValidator = testValidator ?? TestValidator(),
        _exitWrapper = exitWrapper ?? ExitWrapper() {
    argParser.addOption(
      'test-path',
      help: 'Path to the tests.',
    );
  }

  final TestValidator _testValidator;
  final ExitWrapper _exitWrapper;

  @override
  String get description => 'Validate tests whether they have correct format.';

  @override
  String get name => 'validate';

  @override
  Future<void> run() async {
    final path = argResults?.option('test-path');

    if (path == null || path.isEmpty == true) {
      CliLogger.logError(
        'Invalid test path. Please provide it via --test-path option.',
      );
      return _exitWrapper.exit(1);
    }

    final summary = await _testValidator.validate(path);
    if (summary.isFailed) {
      _exitWrapper.exit(1);
    }
  }
}
