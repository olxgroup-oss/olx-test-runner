import 'dart:io';

class TestUtils {
  static Future<String> getAbsolutePath(String path) async {
    final testDirectory = Directory(path);
    return testDirectory.absolute.path;
  }
}
