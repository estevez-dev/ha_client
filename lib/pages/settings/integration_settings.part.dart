part of '../../main.dart';

class IntegrationSettingsPage extends StatefulWidget {
  IntegrationSettingsPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _IntegrationSettingsPageState createState() => new _IntegrationSettingsPageState();
}

class _IntegrationSettingsPageState extends State<IntegrationSettingsPage> {

  static const platform = const MethodChannel('com.keyboardcrumbs.hassclient/native');
  static final locationAccuracy = {
    100: "Highest",
    102: "Balanced (about 100 meters)",
    104: "Low (up to 10 kilometers)",
    105: "Passive (last known location)",
  };

  int _locationInterval = AppSettings().defaultLocationUpdateIntervalMinutes;
  int _activeLocationInterval = AppSettings().defaultActiveLocationUpdateIntervalSeconds;
  bool _locationTrackingEnabled = false;
  bool _foregroundLocationTrackingEnabled = false;
  bool _wait = false;
  bool _changedHere = false;
  int _accuracy = 102;

  @override
  void initState() {
    super.initState();
    _loadSettings();

  }

  _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        _locationTrackingEnabled = prefs.getBool("location-enabled") ?? false;
        _accuracy = prefs.getInt("location-updates-priority") ?? 102;
        _foregroundLocationTrackingEnabled = (prefs.getInt("location-updates-state") ?? 0) > 0;
        _locationInterval = prefs.getInt("location-interval") ??
          AppSettings().defaultLocationUpdateIntervalMinutes;
        _activeLocationInterval = prefs.getInt("location-updates-interval") ??
            AppSettings().defaultActiveLocationUpdateIntervalSeconds;
        if (_locationInterval < 15) {
          _locationInterval = 15;
        } else if (_locationInterval % 5 != 0) {
          _locationInterval = 5 * (_locationInterval ~/ 5);
        }
      });
    });
  }

  void _incLocationInterval() {
    if (_locationInterval < 720) {
      setState(() {
        _locationInterval = _locationInterval + 5;
        _changedHere = true;
      });
    }
  }

  void _decLocationInterval() {
    if (_locationInterval > 15) {
      setState(() {
        _locationInterval = _locationInterval - 5;
        _changedHere = true;
      });
    }
  }

  void _incActiveLocationInterval() {
    if (_activeLocationInterval < 7200) {
      setState(() {
        _activeLocationInterval = _activeLocationInterval + 5;
        _changedHere = true;
      });
    }
  }

  void _decActiveLocationInterval() {
    if (_activeLocationInterval > 5) {
      setState(() {
        _activeLocationInterval = _activeLocationInterval - 5;
        _changedHere = true;
      });
    }
  }

  _switchLocationTrackingState(bool state) async {
    if (state) {
      await LocationManager().updateDeviceLocation();
    }
    await LocationManager().setSettings(_locationTrackingEnabled, _locationInterval);
    setState(() {
      _wait = false;
    });
  }

  _switchForegroundLocationTrackingState(bool state) async {
    await AppSettings().save({'location-updates-interval': _activeLocationInterval, 'location-updates-priority': _accuracy});
    if (state) {
      try {
        await platform.invokeMethod('startLocationService');
      } catch (e) {
        _foregroundLocationTrackingEnabled = false;
      }
    } else {
      await platform.invokeMethod('stopLocationService');
    }
    setState(() {
      _wait = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.vertical,
      padding: const EdgeInsets.all(20.0),
      children: <Widget>[
        Text("Passive location tracking", style: Theme.of(context).textTheme.title),
        Text("Works in background not affecting phone battery. Usually sends last known device location. Can't be more frequent than once in 15 minutes.",
            style: Theme.of(context).textTheme.caption,
            softWrap: true,
        ),
        Container(height: Sizes.rowPadding,),
        Row(
          children: <Widget>[
            Text("Enable"),
            Switch(
              value: _locationTrackingEnabled,
              onChanged: _wait ? null : (value) {
                setState(() {
                  _locationTrackingEnabled = value;
                  _wait = true;
                });
                _switchLocationTrackingState(value);
              },
            ),
          ],
        ),
        Container(height: Sizes.rowPadding),
        Text("Send device location every"),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            //Expanded(child: Container(),),
            FlatButton(
              padding: EdgeInsets.all(0.0),
              child: Text("-", style: Theme.of(context).textTheme.title),
              onPressed: () => _decLocationInterval(),
            ),
            Text("$_locationInterval minutes", style: Theme.of(context).textTheme.title),
            FlatButton(
              padding: EdgeInsets.all(0.0),
              child: Text("+", style: Theme.of(context).textTheme.title),
              onPressed: () => _incLocationInterval(),
            ),
          ],
        ),
        Container(height: Sizes.rowPadding),
        Text("Active location tracking", style: Theme.of(context).textTheme.title),
        Container(height: Sizes.rowPadding),
        Row(
          children: <Widget>[
            Text("Enable"),
            Switch(
              value: _foregroundLocationTrackingEnabled,
              onChanged: _wait ? null : (value) {
                setState(() {
                  _foregroundLocationTrackingEnabled = value;
                  _wait = true;
                });
                _switchForegroundLocationTrackingState(value);
              },
            ),
          ],
        ),
        Container(height: Sizes.rowPadding),
        Text("Accuracy:", style: Theme.of(context).textTheme.body2),
        Container(height: Sizes.rowPadding),
        DropdownButton<int>(
          value: _accuracy,
          iconSize: 30.0,
          isExpanded: true,
          items: locationAccuracy.keys.map((value) {
            return new DropdownMenuItem<int>(
              value: value,
              child: Text('${locationAccuracy[value]}'),
            );
          }).toList(),
          onChanged: _foregroundLocationTrackingEnabled ? null : (val) {
            setState(() {
              _accuracy = val;
            });
          },
        ),
        Container(height: Sizes.rowPadding),
        Text("Update intervals"),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            //Expanded(child: Container(),),
            FlatButton(
              padding: EdgeInsets.all(0.0),
              child: Text("-", style: Theme.of(context).textTheme.title),
              onPressed: _foregroundLocationTrackingEnabled ? null : () => _decActiveLocationInterval(),
            ),
            Text("$_activeLocationInterval seconds",
                style: _foregroundLocationTrackingEnabled ? Theme.of(context).textTheme.title.copyWith(color: HAClientTheme().getDisabledStateColor(context)) : Theme.of(context).textTheme.title),
            FlatButton(
              padding: EdgeInsets.all(0.0),
              child: Text("+", style: Theme.of(context).textTheme.title),
              onPressed: _foregroundLocationTrackingEnabled ? null : () => _incActiveLocationInterval(),
            ),
          ],
        ),
      ]
    );
  }

  @override
  void dispose() {
    LocationManager().setSettings(_locationTrackingEnabled, _locationInterval);
    super.dispose();
  }
}
