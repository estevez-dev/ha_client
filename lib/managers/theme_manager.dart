part of '../main.dart';

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

  static const _stateColors = {
    EntityState.on: Colors.amber,
    "auto": Colors.amber,
    EntityState.active: Colors.amber,
    EntityState.playing: Colors.amber,
    EntityState.paused: Colors.amber,
    "above_horizon": Colors.amber,
    EntityState.home:  Colors.amber,
    EntityState.open:  Colors.amber,
    EntityState.cleaning:  Colors.amber,
    EntityState.returning:  Colors.amber,
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

  static const defaultStateColor = Color.fromRGBO(68, 115, 158, 1.0);

  static const badgeColors = {
    "default": Color.fromRGBO(223, 76, 30, 1.0),
    "binary_sensor": Color.fromRGBO(3, 155, 229, 1.0)
  };

  static final HAClientTheme _instance = HAClientTheme
      ._internal();

  factory HAClientTheme() {
    return _instance;
  }

  HAClientTheme._internal();

  final ThemeData lightTheme = ThemeData.from(
    colorScheme: ColorScheme(
      primary: Color.fromRGBO(112, 154, 193, 1),
      primaryVariant: Color.fromRGBO(68, 115, 158, 1),
      secondary: Color.fromRGBO(253, 216, 53, 1),
      secondaryVariant: Color.fromRGBO(222, 181, 2, 1),
      background: Colors.white,
      surface: Colors.white,
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.black87,
      onBackground: Colors.black87,
      onSurface: Colors.black87,
      onError: Colors.white,
      brightness: Brightness.light
    ),
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

  Color stateColor(String state) {
    return _stateColors[state] ?? _stateColors["default"];
  }

  charts.Color chartHistoryStateColor(String state, int id) {
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

  Color historyStateColor(String state, int id) {
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