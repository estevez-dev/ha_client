part of '../../main.dart';

class ConnectionSettingsPage extends StatefulWidget {
  ConnectionSettingsPage({Key key, this.title, this.quickStart: false}) : super(key: key);

  final String title;
  final bool quickStart;

  @override
  _ConnectionSettingsPageState createState() => new _ConnectionSettingsPageState();
}

class _ConnectionSettingsPageState extends State<ConnectionSettingsPage> {
  String _homeAssistantUrl = '';
  String _deviceName;
  bool _loaded = false;
  bool _includeDeviceName = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (!widget.quickStart) {
      _loadSettings();
    } else {
      _deviceName = MobileAppIntegrationManager.getDefaultDeviceName();
      _includeDeviceName = true;
      _loaded = true;
    }
  }

  _loadSettings() async {
    _includeDeviceName = widget.quickStart || ConnectionManager().webhookId == null;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String domain = prefs.getString('hassio-domain')?? '';
    String port = prefs.getString('hassio-port') ?? '';
    String urlProtocol = prefs.getString('hassio-res-protocol') ?? 'https';
    _homeAssistantUrl = '$urlProtocol://$domain:$port';
    _deviceName = prefs.getString('app-integration-device-name') ?? MobileAppIntegrationManager.getDefaultDeviceName();
    setState(() {
      _loaded = true;
    });
  }

  _saveSettings() async {
    _homeAssistantUrl = _homeAssistantUrl.trim();
    String socketProtocol;
    String domain;
    String port;
    if (_homeAssistantUrl.startsWith("http") && _homeAssistantUrl.indexOf("//") > 0) {
      _homeAssistantUrl.startsWith("https") ? socketProtocol = "wss" : socketProtocol = "ws";
      domain = _homeAssistantUrl.split("//")[1];
    } else {
      domain = _homeAssistantUrl;
    }
    domain = domain.split("/")[0];
    if (domain.contains(":")) {
      List<String> domainAndPort = domain.split(":");
      domain = domainAndPort[0];
      port = domainAndPort[1];
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("hassio-domain", domain);
    if (port == null || port.isEmpty) {
      port = socketProtocol == "wss" ? "443" : "80";
    } else {
      port = port.trim();
    }
    await prefs.setString("hassio-port", port);
    await prefs.setString("hassio-protocol", socketProtocol);
    await prefs.setString("hassio-res-protocol", socketProtocol == "wss" ? "https" : "http");
    if (_includeDeviceName) {
      await prefs.setString('app-integration-device-name', _deviceName);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return PageLoadingIndicator();
    }
    List<Widget> formChildren = <Widget>[
      Text(
          "Home Assistant url:",
          style: Theme.of(context).textTheme.headline,
      ),
      TextFormField(
        initialValue: _homeAssistantUrl,
        decoration: InputDecoration(
          hintText: "Please enter url",
          contentPadding: EdgeInsets.all(0),
          hintStyle: Theme.of(context).textTheme.subhead.copyWith(
            color: Theme.of(context).textTheme.overline.color
          )
        ),
        onSaved: (newValue) {
          _homeAssistantUrl = newValue;
        },
        validator: (value) {
          if (value.isEmpty) {
            return 'Url is required';
          }
          return null;
        },
      ),
      Container(
        height: 10,
      ),
      Text(
          "For example:",
          style: Theme.of(context).textTheme.body1,
      ),
      Text(
          "192.186.2.14:8123",
          style: Theme.of(context).textTheme.subhead,
      ),
      Text(
          "http://myhome.duckdns.org:8123",
          style: Theme.of(context).textTheme.subhead,
      ),
      Text(
          "https://efkmfrwk3r4fsfwrfrg5.ui.nabu.casa/",
          style: Theme.of(context).textTheme.subhead,
      ),
    ];

    if (_includeDeviceName) {
      formChildren.addAll(<Widget>[
        Container(
          height: 30,
        ),
        Text(
            "Device name:",
            style: Theme.of(context).textTheme.headline,
        ),
        TextFormField(
          initialValue: _deviceName,
          onSaved: (newValue) {
            _deviceName = newValue;
          },
          decoration: InputDecoration(
            hintText: 'Please enter device name',
            contentPadding: EdgeInsets.all(0),
            hintStyle: Theme.of(context).textTheme.subhead.copyWith(
              color: Theme.of(context).textTheme.overline.color
            )
          ),
          validator: (value) {
            if (value.isEmpty) {
              return 'Device name is required';
            }
            return null;
          },
        ),
      ]);
    }

    formChildren.addAll(<Widget>[
      Container(
        height: 30,
      ),
      ButtonTheme(
        height: 60,
        child: RaisedButton(
          child: Text(widget.quickStart ? 'Engage' : 'Apply', style: Theme.of(context).textTheme.button.copyWith(fontSize: 20)),
          color: Theme.of(context).primaryColor,
          onPressed: () {
            if (_formKey.currentState.validate()) {
              _formKey.currentState.save();
              _saveSettings().then((r) {
                if (widget.quickStart) {
                  Navigator.pushReplacementNamed(context, '/');
                } else {
                  Navigator.pop(context);
                }
                eventBus.fire(SettingsChangedEvent(true));
              });
            }
          },
        )
      )
    ]);

    return Form(
      key: _formKey,
      child: ListView(
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.all(20.0),
        children: formChildren,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
