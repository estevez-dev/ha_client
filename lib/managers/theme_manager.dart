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
    primaryColor: Colors.lightBlue,
    textTheme: ThemeData.light().textTheme.copyWith(
      display1: TextStyle(fontSize: 34, fontWeight: FontWeight.normal, color: Colors.black54),
      display2: TextStyle(fontSize: 34, fontWeight: FontWeight.normal, color: Colors.redAccent),
      headline: TextStyle(fontSize: 24, fontWeight: FontWeight.normal, color: defaultFontColor),
      title: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: defaultFontColor),
      subhead: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black54),
      body1: TextStyle(fontSize: 15, fontWeight: FontWeight.normal, color: defaultFontColor),
      body2: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: defaultFontColor),
      subtitle: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black45),
      caption: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black26),
      overline: TextStyle(fontSize: 10, fontWeight: FontWeight.normal, color: Colors.black26),
    )
  );

  final ThemeData darkTheme = ThemeData.dark();

}