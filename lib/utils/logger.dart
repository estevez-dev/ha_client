import 'package:date_format/date_format.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';


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

  static void e(String message) {
    _writeToLog("Error", message);
  }

  static void w(String message) {
    _writeToLog("Warning", message);
  }

  static void d(String message) {
    _writeToLog("Debug", message);
  }

  static void _writeToLog(String level, String message) {
    if (isInDebugMode) {
      debugPrint('$message');
    }
    DateTime t = DateTime.now();
    _log.add("${formatDate(t, ["mm","dd"," ","HH",":","nn",":","ss"])} [$level] :  $message");
    if (_log.length > 100) {
      _log.removeAt(0);
    }
  }

}