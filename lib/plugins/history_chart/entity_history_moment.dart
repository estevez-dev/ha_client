part of '../../main.dart';

class EntityHistoryMoment {
  final DateTime startTime;
  final DateTime endTime;
  final double value;
  final double previousValue;
  final int id;
  final int colorId;
  final String state;
  final bool hiddenDot;
  final bool hiddenLine;

  EntityHistoryMoment({
    this.value,
    this.previousValue,
    this.hiddenDot,
    this.hiddenLine,
    this.state,
    @required this.startTime,
    this.endTime,
    @required this.id,
    this.colorId
  });
}