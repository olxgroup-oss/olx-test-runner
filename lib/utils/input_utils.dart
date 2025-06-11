import 'dart:io';

class InputUtils {
  static bool isNumericPositive(String input) =>
      (int.tryParse(input) ?? -1) >= 0;

  static bool isNumericGreaterThanZero(String input) =>
      (int.tryParse(input) ?? -1) >= 1;

  static bool validateDirExists(String path) {
    final directory = Directory(path);
    return directory.existsSync();
  }
}
