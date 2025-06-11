import 'dart:io' as io;

import 'package:test_runner/utils/cli_logger.dart';

class ExitWrapper {
  factory ExitWrapper() {
    return _singleton;
  }

  ExitWrapper._internal();
  var _exitEnabled = true;

  static final ExitWrapper _singleton = ExitWrapper._internal();

  void exit(int code) {
    if (_exitEnabled) {
      io.exit(code);
    } else {
      CliLogger.logDebug('Exit disabled - ignoring $code');
    }
  }

  void setExitEnabled({required bool enabled}) {
    _exitEnabled = enabled;
  }
}
