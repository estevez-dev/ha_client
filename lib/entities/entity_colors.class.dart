part of '../main.dart';

class EntityColor {

  static const defaultStateColor = Color.fromRGBO(68, 115, 158, 1.0);

  static const badgeColors = {
    "default": Color.fromRGBO(223, 76, 30, 1.0),
    "binary_sensor": Color.fromRGBO(3, 155, 229, 1.0)
  };

  static const _stateColors = {
    EntityState.on: Colors.amber,
    "auto": Colors.amber,
    EntityState.active: Colors.amber,
    EntityState.playing: Colors.amber,
    EntityState.paused: Colors.amber,
    "above_horizon": Colors.amber,
    EntityState.home:  Colors.amber,
    EntityState.open:  Colors.amber,
    EntityState.off: defaultStateColor,
    EntityState.closed: defaultStateColor,
    "below_horizon": defaultStateColor,
    "default": defaultStateColor,
    EntityState.idle: defaultStateColor,
    "heat": Colors.redAccent,
    "cool": Colors.lightBlue,
    EntityState.unavailable: Colors.black26,
    EntityState.unknown: Colors.black26,
    EntityState.alarm_disarmed: Colors.green,
    EntityState.alarm_armed_away: Colors.redAccent,
    EntityState.alarm_armed_custom_bypass: Colors.redAccent,
    EntityState.alarm_armed_home: Colors.redAccent,
    EntityState.alarm_armed_night: Colors.redAccent,
    EntityState.alarm_triggered: Colors.redAccent,
    EntityState.alarm_arming: Colors.amber,
    EntityState.alarm_disarming: Colors.amber,
    EntityState.alarm_pending: Colors.amber,
  };

  static Color stateColor(String state) {
    return _stateColors[state] ?? _stateColors["default"];
  }

  static charts.Color chartHistoryStateColor(String state, int id) {
    Color c = _stateColors[state];
    if (c != null) {
      return charts.Color(
          r: c.red,
          g: c.green,
          b: c.blue,
          a: c.alpha
      );
    } else {
      double r = id.toDouble() % 10;
      return charts.MaterialPalette.getOrderedPalettes(10)[r.round()].shadeDefault;
    }
  }

  static Color historyStateColor(String state, int id) {
    Color c = _stateColors[state];
    if (c != null) {
      return c;
    } else {
      if (id > -1) {
        double r = id.toDouble() % 10;
        charts.Color c1 = charts.MaterialPalette.getOrderedPalettes(10)[r.round()].shadeDefault;
        return Color.fromARGB(c1.a, c1.r, c1.g, c1.b);
      } else {
        return _stateColors[EntityState.on];
      }
    }
  }

}