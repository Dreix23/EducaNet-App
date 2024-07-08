class AppLogger {
  static bool _isLoggingEnabled = true; // Cambiar a false para producción
  static const String _defaultLogPrefix = "MyAppLog:";  // Prefijo personalizado por defecto

  static void log(String message, {String? prefix}) {
    final logPrefix = prefix ?? _defaultLogPrefix;
    if (_isLoggingEnabled) {
      print('$logPrefix $message');
    }
  }

  static void enableLogging(bool isEnabled) {
    _isLoggingEnabled = isEnabled;
  }
}
