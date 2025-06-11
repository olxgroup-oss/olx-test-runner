import 'package:mason_logger/mason_logger.dart';

class CliLogger {
  static Logger _logger = Logger();

  static void setup({
    bool verboseLogging = false,
    bool disableLogging = false,
  }) {
    _logger = Logger(
      level: disableLogging
          ? Level.quiet
          : verboseLogging
              ? Level.verbose
              : Level.info,
    );
  }

  static void logInfo(String message) {
    _logger.info(message);
  }

  static void logDebug(String message) {
    final size = message.length;
    if (size > 200) {
      var currentIndex = 0;
      while (currentIndex * 200 < size) {
        final start = currentIndex * 200;
        var end = (currentIndex + 1) * 200;
        if (end > size) {
          end = size;
        }
        _logger.detail(message.substring(start, end));
        currentIndex += 1;
      }
    }

    _logger.detail(message);
  }

  static void logError(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.err(message);

    if (error != null || stackTrace != null) {
      _logger.err('=====================');
      if (error != null) {
        _logger.err(error.toString());
      }
      if (stackTrace != null) {
        _logger.err(stackTrace.toString());
      }
    }
  }

  static void logSuccess(String message) {
    _logger.success(message);
  }

  static void logWarning(String message) {
    _logger.warn(message, tag: '');
  }

  static Progress logProgress(String message) {
    return _logger.progress(message);
  }
}
