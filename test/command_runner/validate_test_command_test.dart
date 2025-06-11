import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:test_runner/command_runner/validate_test_command.dart';
import 'package:test_runner/test_validator/test_validator.dart';
import 'package:test_runner/test_validator/validation_summary.dart';
import 'package:test_runner/utils/exit.dart';

import 'fake_command_runner.dart';

class TestValidatorMock extends Mock implements TestValidator {}

class ExitWrapperMock extends Mock implements ExitWrapper {}

void main() {
  group('$ValidateTestCommand', () {
    late TestValidatorMock mockTestValidator;
    late ExitWrapperMock mockExitWrapper;
    late FakeCommandRunner commandRunner;
    setUp(() {
      mockTestValidator = TestValidatorMock();
      when(() => mockTestValidator.validate(any())).thenAnswer(
        (_) async => Future.value(ValidationSummary(results: [])),
      );
      mockExitWrapper = ExitWrapperMock();
      when(() => mockExitWrapper.exit(any())).thenAnswer((_) => {});
      commandRunner = FakeCommandRunner(
        ValidateTestCommand(
          testValidator: mockTestValidator,
          exitWrapper: mockExitWrapper,
        ),
      );
    });

    test('should not run validator if test path is missing', () async {
      await commandRunner.run([
        'validate',
      ]);

      verifyNever(() => mockTestValidator.validate(any()));
      verify(() => mockExitWrapper.exit(1));
    });

    test('should run validator if test path is provided', () async {
      await commandRunner.run(['validate', '--test-path', 'test']);

      verify(() => mockTestValidator.validate(any()));
      verifyNever(() => mockExitWrapper.exit(1));
    });

    test('should return exit code 1 when validation fails', () async {
      when(() => mockTestValidator.validate(any())).thenAnswer(
        (_) async =>
            Future.value(ValidationSummary(results: [], isFailed: true)),
      );

      await commandRunner.run(['validate', '--test-path', 'test']);

      verify(() => mockExitWrapper.exit(1));
    });
  });
}
