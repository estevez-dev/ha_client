part of '../main.dart';

class ConnectionSettingsPage extends StatefulWidget {
  ConnectionSettingsPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ConnectionSettingsPageState createState() => new _ConnectionSettingsPageState();
}

class _ConnectionSettingsPageState extends State<ConnectionSettingsPage> {
  String _hassioDomain = "";
  String _newHassioDomain = "";
  String _hassioPort = "";
  String _newHassioPort = "";
  String _socketProtocol = "wss";
  String _newSocketProtocol = "wss";
  String _longLivedToken = "";
  String _newLongLivedToken = "";
  bool _useLovelace = true;
  bool _newUseLovelace = true;

  String oauthUrl;
  bool useOAuth = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();

  }

  _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final storage = new FlutterSecureStorage();

    try {
      useOAuth = prefs.getBool("oauth-used") ?? true;
    } catch (e) {
      useOAuth = true;
    }

    if (!useOAuth) {
      try {
        _longLivedToken = _newLongLivedToken =
        await storage.read(key: "hacl_llt");
      } catch (e) {
        _longLivedToken = _newLongLivedToken = "";
        await storage.delete(key: "hacl_llt");
      }
    }

    setState(() {
      _hassioDomain = _newHassioDomain = prefs.getString("hassio-domain")?? "";
      _hassioPort = _newHassioPort = prefs.getString("hassio-port") ?? "";
      _socketProtocol = _newSocketProtocol = prefs.getString("hassio-protocol") ?? 'wss';
      try {
        _useLovelace = _newUseLovelace = prefs.getBool("use-lovelace") ?? true;
      } catch (e) {
        _useLovelace = _newUseLovelace = true;
      }
    });
  }

  bool _checkConfigChanged() {
    return (
      (_newHassioPort != _hassioPort) ||
      (_newHassioDomain != _hassioDomain) ||
      (_newSocketProtocol != _socketProtocol) ||
      (_newUseLovelace != _useLovelace) ||
      (_newLongLivedToken != _longLivedToken));

  }

  _saveSettings() async {
    _newHassioDomain = _newHassioDomain.trim();
    if (_newHassioDomain.startsWith("http") && _newHassioDomain.indexOf("//") > 0) {
      _newHassioDomain.startsWith("https") ? _newSocketProtocol = "wss" : _newSocketProtocol = "ws";
      _newHassioDomain = _newHassioDomain.split("//")[1];
    }
    _newHassioDomain = _newHassioDomain.split("/")[0];
    if (_newHassioDomain.contains(":")) {
      List<String> domainAndPort = _newHassioDomain.split(":");
      _newHassioDomain = domainAndPort[0];
      _newHassioPort = domainAndPort[1];
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final storage = new FlutterSecureStorage();
    if (_newLongLivedToken.isNotEmpty) {
      _newLongLivedToken = _newLongLivedToken.trim();
      prefs.setBool("oauth-used", false);
      await storage.write(key: "hacl_llt", value: _newLongLivedToken);
    } else if (!useOAuth) {
      await storage.delete(key: "hacl_llt");
    }
    prefs.setString("hassio-domain", _newHassioDomain);
    if (_newHassioPort == null || _newHassioPort.isEmpty) {
      _newHassioPort = _newSocketProtocol == "wss" ? "443" : "80";
    } else {
      _newHassioPort = _newHassioPort.trim();
    }
    prefs.setString("hassio-port", _newHassioPort);
    prefs.setString("hassio-protocol", _newSocketProtocol);
    prefs.setString("hassio-res-protocol", _newSocketProtocol == "wss" ? "https" : "http");
    prefs.setBool("use-lovelace", _newUseLovelace);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: (){
          Navigator.pop(context);
        }),
        title: new Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: (){
              if (_checkConfigChanged()) {
                Logger.d("Settings changed. Saving...");
                _saveSettings().then((r) {
                  Navigator.pop(context);
                  eventBus.fire(SettingsChangedEvent(true));
                });
              } else {
                Logger.d("Settings was not changed");
                Navigator.pop(context);
              }
            }
          )
        ],
      ),
      body: ListView(
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.all(20.0),
        children: <Widget>[
          Text(
              "Connection settings",
              style: Theme.of(context).textTheme.headline,
          ),
          new Row(
            children: [
              Text("Use ssl (HTTPS)"),
              Switch(
                value: (_newSocketProtocol == "wss"),
                onChanged: (value) {
                  setState(() {
                    _newSocketProtocol = value ? "wss" : "ws";
                  });
                },
              )
            ],
          ),
          new TextField(
            decoration: InputDecoration(
              labelText: "Home Assistant domain or ip address"
            ),
            controller: TextEditingController.fromValue(TextEditingValue(text: _newHassioDomain)),
            onChanged: (value) {
              _newHassioDomain = value;
            }
          ),
          new TextField(
            decoration: InputDecoration(
              labelText: "Home Assistant port (default is 8123)"
            ),
            controller: TextEditingController.fromValue(TextEditingValue(text: _newHassioPort)),
            onChanged: (value) {
              _newHassioPort = value;
            }
          ),
          new Text(
            "Try ports 80 and 443 if default is not working and you don't know why.",
            style: Theme.of(context).textTheme.caption,
          ),
          Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: Text(
              "UI",
              style: Theme.of(context).textTheme.headline,
            ),
          ),
          new Row(
            children: [
              Text("Use Lovelace UI"),
              Switch(
                value: _newUseLovelace,
                onChanged: (value) {
                  setState(() {
                    _newUseLovelace = value;
                  });
                },
              )
            ],
          ),
          Text(
            "Authentication settings",
            style: Theme.of(context).textTheme.headline,
          ),
          Container(height: 10.0,),
          Text(
            "You can leave this field blank to make app generate new long-lived token automatically by asking you to login to your Home Assistant. Use this field only if you still want to use manually generated long-lived token. Leave it blank if you don't understand what we are talking about.",
            style: Theme.of(context).textTheme.body1.copyWith(
              color: Colors.redAccent
            ),
          ),
          new TextField(
              decoration: InputDecoration(
                  labelText: "Long-lived token"
              ),
              controller: TextEditingController.fromValue(TextEditingValue(text: _newLongLivedToken)),
              onChanged: (value) {
                _newLongLivedToken = value;
              }
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
