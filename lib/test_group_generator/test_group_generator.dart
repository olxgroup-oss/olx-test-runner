import 'dart:io';
import 'dart:math';

import 'package:mason_logger/mason_logger.dart';
import 'package:test_runner/utils/cli_logger.dart';
import 'package:test_runner/utils/input_utils.dart';

class TestGroupGenerator {
  String? generateTestGroup({
    required int shardIndex,
    required int shardCount,
    required String testPath,
    int? seed,
  }) {
    Progress? progress;
    try {
      CliLogger.logInfo(
        'Generating test groups for `$testPath`. Test group index: $shardIndex, total groups:'
        ' $shardCount ${seed != null ? 'Seed: $seed.' : ''}',
      );

      if (!InputUtils.validateDirExists(testPath)) {
        CliLogger.logError('The path: `$testPath` does not exist.');
        return null;
      }
      progress = CliLogger.logProgress('Searching for test files...');

      final testFiles = _getTestFiles(testPath);

      if (seed != null) {
        progress.update('Shuffling...');
        testFiles.shuffle(Random(seed));
      }

      if (testFiles.isEmpty) {
        progress.fail(
          '${shardIndex + 1}/$shardCount No test files found. Make sure on provided path with '
          '--testPath, there are files with `_test.dart`.',
        );
        return null;
      }

      progress.update('Creating test groups...');

      final groups =
          _createGroups(testFiles: testFiles, shardCount: shardCount);

      progress.update('Building test group file');

      final file = _createTestGroupFile(
        shardIndex: shardIndex,
        shardCount: shardCount,
        testPath: testPath,
        groups: groups,
      );

      progress.complete('Generated test group file: ${file.path}');
      return file.path;
    } catch (error, stackTrace) {
      CliLogger.logError(
        'Failed to generate test groups',
        error: error,
        stackTrace: stackTrace,
      );
      progress?.fail('Generate test group failed');
      return null;
    }
  }

  List<List<FileSystemEntity>> _createGroups({
    required List<FileSystemEntity> testFiles,
    required int shardCount,
  }) {
    final filesPerGroup = (testFiles.length / shardCount).ceil();
    final groups = <List<FileSystemEntity>>[];

    for (var index = 0; index < shardCount; index++) {
      groups.add(
        testFiles.skip(index * filesPerGroup).take(filesPerGroup).toList(),
      );
    }
    return groups;
  }

  List<String> generateTestGroups({
    required int shardCount,
    required String testPath,
    int? seed,
  }) {
    final filePaths = <String>[];
    if (!InputUtils.validateDirExists(testPath)) {
      CliLogger.logError('The path: `$testPath` does not exist.');
      return filePaths;
    }

    for (var shardIndex = 0; shardIndex < shardCount; shardIndex++) {
      final filePath = generateTestGroup(
        shardIndex: shardIndex,
        shardCount: shardCount,
        seed: seed,
        testPath: testPath,
      );
      if (filePath != null) {
        filePaths.add(filePath);
      }
    }
    return filePaths;
  }

  File _createTestGroupFile({
    required int shardIndex,
    required int shardCount,
    required String testPath,
    required List<List<FileSystemEntity>> groups,
  }) {
    final buffer = StringBuffer()
      ..writeln('// Test Runner generated file')
      ..writeln('// TEST GROUP ${shardIndex + 1}/$shardCount');

    for (final file in groups[shardIndex]) {
      final relativePath = file.path.replaceFirst('$testPath/', '');
      final alias = _generateAlias(file.path);
      buffer.writeln("import '$relativePath' as $alias;");
    }

    buffer
      ..writeln()
      ..writeln('void main() {');

    for (final file in groups[shardIndex]) {
      final alias = _generateAlias(file.path);
      buffer.writeln('  $alias.main();');
    }
    buffer.writeln('}');

    return _createFile(testPath: testPath, shardIndex: shardIndex)
      ..writeAsStringSync(buffer.toString());
  }

  List<FileSystemEntity> _getTestFiles(String testPath) {
    final testDirectory = Directory(testPath);

    final testGroups = testDirectory
        .listSync(recursive: true)
        .where(
          (entity) => entity is File && entity.path.endsWith('_test.dart'),
        )
        .toList()
      ..sort((item1, item2) => item1.path.compareTo(item2.path));

    return testGroups;
  }

  File _createFile({required String testPath, required int shardIndex}) {
    final file = File('$testPath/generated_test_group_$shardIndex.dart');
    if (file.existsSync()) {
      file.deleteSync();
    }
    file.createSync();
    return file;
  }

  /// Generates alias for provided [filePath] to distinguish imports.
  String _generateAlias(String filePath) {
    var hash = 0;

    for (var i = 0; i < filePath.length; i++) {
      final charCode = filePath.codeUnitAt(i);
      hash = ((hash << 5) - hash) + charCode;
      hash = hash & 0x7FFFFFFF;
    }

    final hashHex = hash.toRadixString(16).padLeft(8, '0');

    final path = filePath.split('/').last.replaceAll('.dart', '');

    return '${path}_$hashHex';
  }
}
