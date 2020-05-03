part of '../main.dart';

class QuickStartPage extends StatefulWidget {
  QuickStartPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _QuickStartPageState createState() => new _QuickStartPageState();
}

class _QuickStartPageState extends State<QuickStartPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        leading: Container(),
        title: Text('Quick start'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.help),
            onPressed: () {
              Launcher.launchURLInCustomTab(
                context: context,
                url: 'https://ha-client.app/help'
              );
            },
          )
        ],
      ),
      body: ConnectionSettingsPage(
        quickStart: true,
      )
    );
    
  }

  @override
  void dispose() {
    super.dispose();
  }
}
