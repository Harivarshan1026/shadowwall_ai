/// Application logger with structured output.
///
/// Wraps the [logger] package for consistent log formatting
/// across the entire application. Logs are local-only.
library;

import 'package:logger/logger.dart' as log_pkg;

class AppLogger {
  static final log_pkg.Logger _logger = log_pkg.Logger(
    printer: log_pkg.PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      noBoxingByDefault: true,
    ),
  );

  /// Verbose / trace level log.
  static void verbose(String message) {
    _logger.t(message);
  }

  /// Debug level log.
  static void debug(String message) {
    _logger.d(message);
  }

  /// Info level log.
  static void info(String message) {
    _logger.i(message);
  }

  /// Warning level log.
  static void warning(String message) {
    _logger.w(message);
  }

  /// Error level log with optional error and stack trace.
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Log a scan event.
  static void scan(String scanType, String input) {
    _logger.i('SCAN [$scanType] → ${input.length > 50 ? '${input.substring(0, 50)}...' : input}');
  }

  /// Log an AI analysis event.
  static void ai(String operation, {double? score, String? category}) {
    _logger.i('AI [$operation] Score: $score | Category: $category');
  }
}
