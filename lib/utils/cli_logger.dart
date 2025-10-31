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

  static void logInfo(String message, {bool loggerEnabled = true}) {
    if (!loggerEnabled) {
      return;
    }
    _logger.info(message);
  }

  static void logDebug(String message, {bool loggerEnabled = true}) {
    if (!loggerEnabled) {
      return;
    }
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
    bool loggerEnabled = true,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!loggerEnabled) {
      return;
    }
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

  static void logSuccess(String message, {bool loggerEnabled = true}) {
    if (!loggerEnabled) {
      return;
    }
    _logger.success(message);
  }

  static void logWarning(String message, {bool loggerEnabled = true}) {
    if (!loggerEnabled) {
      return;
    }
    _logger.warn(message, tag: '');
  }

  static CliLoggerProgress logProgress(String message, {bool loggerEnabled = true}) {
    return CliLoggerProgress(
        logger: _logger, initialMessage: message, loggerEnabled: loggerEnabled);
  }
}

class CliLoggerProgress {
  CliLoggerProgress(
      {required Logger logger, required String initialMessage, bool loggerEnabled = true})
      : _logger = logger {
    if (loggerEnabled) {
      _progress = _logger.progress(initialMessage);
    }
  }

  final Logger _logger;
  Progress? _progress;

  void update(String message) {
    _progress?.update(message);
  }

  void complete([String? message]) {
    _progress?.complete(message);
  }

  void fail([String? message]) {
    _progress?.fail(message);
  }
}
