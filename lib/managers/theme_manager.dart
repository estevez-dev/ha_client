import 'package:flutter/material.dart';

class HAClientTheme {

  static const TextTheme textTheme = TextTheme(
    display1: TextStyle(fontSize: 34, fontWeight: FontWeight.normal),
    display2: TextStyle(fontSize: 34, fontWeight: FontWeight.normal),
    headline: TextStyle(fontSize: 24, fontWeight: FontWeight.normal),
    title: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
    subhead: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
    body1: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
    body2: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
    subtitle: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
    caption: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
    overline: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.normal,
      letterSpacing: 1,
    ),
    button: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
  );

  static final HAClientTheme _instance = HAClientTheme
      ._internal();

  factory HAClientTheme() {
    return _instance;
  }

  HAClientTheme._internal();

  final ThemeData lightTheme = ThemeData.light().copyWith(
    textTheme: ThemeData.light().textTheme.copyWith(
      display1: textTheme.display1.copyWith(color: Colors.black54),
      display2: textTheme.display2.copyWith(color: Colors.redAccent),
      headline: textTheme.headline.copyWith(color: Colors.black87),
      title: textTheme.title.copyWith(color: Colors.black87),
      subhead: textTheme.subhead.copyWith(color: Colors.black54),
      body1: textTheme.body1.copyWith(color: Colors.black87),
      body2: textTheme.body2.copyWith(color: Colors.black87),
      subtitle: textTheme.subtitle.copyWith(color: Colors.black45),
      caption: textTheme.caption.copyWith(color: Colors.black45),
      overline: textTheme.overline.copyWith(color: Colors.black26),
      button: textTheme.button.copyWith(color: Colors.white),
    )
  );

  final ThemeData darkTheme = ThemeData.dark().copyWith(
    textTheme: ThemeData.light().textTheme.copyWith(
      display1: textTheme.display1.copyWith(color: Colors.white70),
      display2: textTheme.display2.copyWith(color: Colors.redAccent),
      headline: textTheme.headline.copyWith(color: Colors.white),
      title: textTheme.title.copyWith(color: Colors.white),
      subhead: textTheme.subhead.copyWith(color: Colors.white70),
      body1: textTheme.body1.copyWith(color: Colors.white),
      body2: textTheme.body2.copyWith(color: Colors.white),
      subtitle: textTheme.subtitle.copyWith(color: Colors.white70),
      caption: textTheme.caption.copyWith(color: Colors.white70),
      overline: textTheme.overline.copyWith(color: Colors.white54),
      button: textTheme.button.copyWith(color: Colors.white),
    )
  );

}