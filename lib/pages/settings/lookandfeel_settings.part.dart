part of '../../main.dart';

class LookAndFeelSettingsPage extends StatefulWidget {
  LookAndFeelSettingsPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LookAndFeelSettingsPageState createState() => new _LookAndFeelSettingsPageState();
}

class _LookAndFeelSettingsPageState extends State<LookAndFeelSettingsPage> {

  AppTheme _currentTheme;
  bool _scrollBadges = false;
  DisplayMode _displayMode;

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
        _currentTheme = AppTheme.values[prefs.getInt('app-theme') ?? AppTheme.defaultTheme.index];
        _displayMode = DisplayMode.values[prefs.getInt('display-mode') ?? DisplayMode.normal.index];
        _scrollBadges = prefs.getBool('scroll-badges') ?? true;
      });
    });
  }

  _saveTheme(AppTheme theme) {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt('app-theme', theme.index);
      prefs.setBool('scroll-badges', _scrollBadges);
      setState(() {
        _currentTheme = theme;
        eventBus.fire(ChangeThemeEvent(_currentTheme));
      });
    });
  }

  Future _saveBadgesSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    AppSettings().scrollBadges = _scrollBadges;
    await prefs.setBool('scroll-badges', _scrollBadges);
  }

  Future _saveDisplayMode(DisplayMode mode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    AppSettings().displayMode = mode;
    await prefs.setInt('display-mode', mode.index);
    if (mode == DisplayMode.fullscreen) {
      SystemChrome.setEnabledSystemUIOverlays([]);
    } else {
      SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    }
  }

  Map appThemeName = {
    AppTheme.defaultTheme: 'Default',
    AppTheme.haTheme: 'Home Assistant theme',
    AppTheme.darkTheme: 'Dark theme'
  };

  Map DisplayModeName = {
    DisplayMode.normal: 'Normal',
    DisplayMode.fullscreen: 'Fullscreen'
  };

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.vertical,
      padding: const EdgeInsets.all(20.0),
      children: <Widget>[
          Text("Application theme:", style: Theme.of(context).textTheme.body2),
          Container(height: Sizes.rowPadding),
          DropdownButton<AppTheme>(
            value: _currentTheme,
            iconSize: 30.0,
            isExpanded: true,
            style: Theme.of(context).textTheme.title,
            items: AppTheme.values.map((value) {
              return new DropdownMenuItem<AppTheme>(
                value: value,
                child: Text('${appThemeName[value]}'),
              );
            }).toList(),
            onChanged: (theme) => _saveTheme(theme),
          ),
          Container(height: Sizes.doubleRowPadding),
          Text("Badges display:", style: Theme.of(context).textTheme.body2),
          Container(height: Sizes.rowPadding),
          DropdownButton<bool>(
            value: _scrollBadges,
            iconSize: 30.0,
            isExpanded: true,
            style: Theme.of(context).textTheme.title,
            items: [true, false].map((value) {
              return new DropdownMenuItem<bool>(
                value: value,
                child: Text('${value ? 'Horizontal scroll' : 'In rows'}'),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                _scrollBadges = val;
              });
              _saveBadgesSettings();
            },
          ),
          Container(height: Sizes.doubleRowPadding),
          Text("Fullscreen mode:", style: Theme.of(context).textTheme.body2),
          Container(height: Sizes.rowPadding),
          DropdownButton<DisplayMode>(
            value: _displayMode,
            iconSize: 30.0,
            isExpanded: true,
            style: Theme.of(context).textTheme.title,
            items: DisplayMode.values.map((value) {
              return new DropdownMenuItem<DisplayMode>(
                value: value,
                child: Text('${DisplayModeName[value]}'),
              );
            }).toList(),
            onChanged: (DisplayMode val) {
              setState(() {
                _displayMode = val;
              });
              _saveDisplayMode(val);
            },
          ),
        ]
      );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
