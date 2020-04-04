import 'package:flutter/material.dart';

class HAClientTheme {

  static const Color defaultFontColor = Colors.black87;

  static final HAClientTheme _instance = HAClientTheme
      ._internal();

  factory HAClientTheme() {
    return _instance;
  }

  HAClientTheme._internal();

  final ThemeData lightTheme = ThemeData.light().copyWith(
    textTheme: ThemeData.light().textTheme.copyWith(
      display1: TextStyle(fontSize: 34, fontWeight: FontWeight.normal, color: Colors.black54),
      display2: TextStyle(fontSize: 34, fontWeight: FontWeight.normal, color: Colors.redAccent),
      headline: TextStyle(fontSize: 24, fontWeight: FontWeight.normal, color: defaultFontColor),
      title: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: defaultFontColor),
      subhead: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: defaultFontColor),
      body1: TextStyle(fontSize: 15, fontWeight: FontWeight.normal, color: defaultFontColor),
      body2: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: defaultFontColor),
      subtitle: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black45),
      caption: TextStyle(fontSize: 13, fontWeight: FontWeight.normal, color: defaultFontColor),
      overline: TextStyle(fontSize: 10, fontWeight: FontWeight.normal, color: Colors.black54),
    )
  );

  final ThemeData darkTheme = ThemeData.dark();

}