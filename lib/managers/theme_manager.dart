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

  static const offEntityStates = [
    EntityState.off,
    EntityState.closed,
    "below_horizon",
    "default",
    EntityState.idle,
    EntityState.alarm_disarmed,
  ];

  static const onEntityStates = [
    EntityState.on,
    "auto",
    EntityState.active,
    EntityState.playing,
    EntityState.paused,
    "above_horizon",
    EntityState.home,
    EntityState.open,
    EntityState.cleaning,
    EntityState.returning,
    "cool",
    EntityState.alarm_arming,
    EntityState.alarm_disarming,
    EntityState.alarm_pending,
  ];

  static const disabledEntityStates = [
    EntityState.unavailable,
    EntityState.unknown,
  ];

  static const alarmEntityStates = [
    EntityState.alarm_armed_away,
    EntityState.alarm_armed_custom_bypass,
    EntityState.alarm_armed_home,
    EntityState.alarm_armed_night,
    EntityState.alarm_triggered,
    "heat",
  ];

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
      background: Color.fromRGBO(250, 250, 250, 1),
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

  final ThemeData darkTheme = ThemeData.from(
    colorScheme: ColorScheme(
      primary: Color.fromRGBO(112, 154, 193, 1),
      primaryVariant: Color.fromRGBO(68, 115, 158, 1),
      secondary: Color.fromRGBO(253, 216, 53, 1),
      secondaryVariant: Color.fromRGBO(222, 181, 2, 1),
      background: Color.fromRGBO(47, 49, 54, 1),
      surface: Color.fromRGBO(54, 57, 63, 1),
      error: Color.fromRGBO(183, 109, 109, 1),
      onPrimary: Colors.white,
      onSecondary: Colors.black87,
      onBackground: Color.fromRGBO(220, 221, 222, 1),
      onSurface: Colors.white,
      onError: Colors.white,
      brightness: Brightness.dark
    ),
    textTheme: textTheme
  );

  Color getOnStateColor(BuildContext context) {
    return Theme.of(context).colorScheme.secondary;
  }

  Color getOffStateColor(BuildContext context) {
    return Theme.of(context).colorScheme.primaryVariant;
  }

  Color getDisabledStateColor(BuildContext context) {
    return Theme.of(context).disabledColor;
  }

  Color getAlertStateColor(BuildContext context) {
    return Theme.of(context).colorScheme.error;
  }

  Color getColorByEntityState(String state, BuildContext context) {
    if (onEntityStates.contains(state)) {
      return getOnStateColor(context);
    } else if (disabledEntityStates.contains(state)) {
      return getDisabledStateColor(context);
    } else if (alarmEntityStates.contains(state)) {
      return getAlertStateColor(context);
    } else {
      return getOffStateColor(context);
    }
  }

  charts.Color chartHistoryStateColor(String state, int id, BuildContext context) {
    Color c = getColorByEntityState(state, context);
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

  Color historyStateColor(String state, int id, BuildContext context) {
    Color c = getColorByEntityState(state, context);
    if (c != null) {
      return c;
    } else {
      if (id > -1) {
        double r = id.toDouble() % 10;
        charts.Color c1 = charts.MaterialPalette.getOrderedPalettes(10)[r.round()].shadeDefault;
        return Color.fromARGB(c1.a, c1.r, c1.g, c1.b);
      } else {
        return getOnStateColor(context);
      }
    }
  }

}