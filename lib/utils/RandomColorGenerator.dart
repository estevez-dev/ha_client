part of '../main.dart';

class RandomColorGenerator {
  static const colorsList = [
    Colors.green,
    Colors.purple,
    Colors.indigo,
    Colors.red,
    Colors.orange,
    Colors.cyan
  ];

  int _index = 0;

  Color getCurrent() {
    return colorsList[_index];
  }

  Color getNext() {
    if (_index < colorsList.length - 1) {
      _index += 1;
    } else {
      _index = 1;
    }
    return getCurrent();
  }

}