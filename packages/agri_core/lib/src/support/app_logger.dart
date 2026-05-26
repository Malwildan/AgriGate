import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error }

/// Lightweight structured logger (debug console only; wire Crashlytics/Sentry later).
class AppLogger {
  const AppLogger._();

  static void log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (kReleaseMode && level == LogLevel.debug) {
      return;
    }

    final prefix = tag == null ? '[AgriGate]' : '[AgriGate/$tag]';
    final line = '$prefix ${level.name.toUpperCase()}: $message';

    switch (level) {
      case LogLevel.debug:
        debugPrint(line);
      case LogLevel.info:
        debugPrint(line);
      case LogLevel.warning:
        debugPrint(line);
      case LogLevel.error:
        debugPrint(line);
        if (error != null) {
          debugPrint('$prefix ERROR_DETAIL: $error');
        }
        if (stackTrace != null) {
          debugPrint('$prefix STACK: $stackTrace');
        }
    }
  }

  static void d(String message, {String? tag}) =>
      log(LogLevel.debug, message, tag: tag);

  static void i(String message, {String? tag}) =>
      log(LogLevel.info, message, tag: tag);

  static void w(String message, {String? tag, Object? error}) =>
      log(LogLevel.warning, message, tag: tag, error: error);

  static void e(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) =>
      log(
        LogLevel.error,
        message,
        tag: tag,
        error: error,
        stackTrace: stackTrace,
      );
}
