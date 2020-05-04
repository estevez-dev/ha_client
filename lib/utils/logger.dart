import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

enum ErrorLevel {ERROR, WARNING, DEBUG}

class Logger {

  static bool get isInDebugMode {
    bool inDebugMode = false;

    assert(inDebugMode = true);

    return inDebugMode;
  }

  static void p(data) {
    print(data);
  }

  static void e(String message, {dynamic stacktrace, bool skipCrashlytics: false}) {
    _writeToLog(ErrorLevel.ERROR, message, stacktrace, skipCrashlytics);
  }

  static void w(String message) {
    _writeToLog(ErrorLevel.WARNING, message, null, true);
  }

  static void d(String message) {
    _writeToLog(ErrorLevel.DEBUG, message, null, true);
  }

  static void _writeToLog(ErrorLevel level, String message, dynamic stacktrace, bool skipCrashlytics) {
    if (isInDebugMode) {
      debugPrint('$message');
      if (stacktrace != null) {
        debugPrint('$stacktrace');
      }
    } else if (!skipCrashlytics) {
      Crashlytics.instance.recordError('$message', stacktrace);
    }
  }

}