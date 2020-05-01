import 'package:date_format/date_format.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

enum ErrorLevel {ERROR, WARNING, DEBUG}

class Logger {

  static List<String> _log = [];

  static String getLog() {
    String res = '';
    _log.forEach((line) {
      res += "$line\n";
    });
    return res;
  }

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
    } else if (!skipCrashlytics) {
      Crashlytics.instance.recordError('$message', stacktrace);
    }
    DateTime t = DateTime.now();
    _log.add("${formatDate(t, ["mm","dd"," ","HH",":","nn",":","ss"])} [$level] :  $message");
    if (_log.length > 100) {
      _log.removeAt(0);
    }
  }

}