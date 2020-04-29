part of '../../main.dart';

enum AppSettingsSection {menu, connectionSettings, integrationSettings, lookAndFeel}

class AppSettingsPage extends StatefulWidget {
  final AppSettingsSection showSection;

  AppSettingsPage({Key key, this.showSection: AppSettingsSection.menu}) : super(key: key);

  @override
  _AppSettingsPageState createState() => new _AppSettingsPageState();
}

class _AppSettingsPageState extends State<AppSettingsPage> {

  var _currentSection;

  @override
  void initState() {
    super.initState();
    _currentSection = widget.showSection;
  }

  Widget _buildMenuItem(BuildContext context, IconData icon,String title, AppSettingsSection section) {
    return ListTile(
      title: Text(title, style: Theme.of(context).textTheme.subhead),
      leading: Icon(icon),
      trailing: Icon(Icons.keyboard_arrow_right),
      onTap: () {
        setState(() {
          _currentSection = section;
        });
      },
    );
  }

  Widget _buildMenu(BuildContext context) {
    return ListView(
      children: <Widget>[
        _buildMenuItem(context, MaterialDesignIcons.getIconDataFromIconName('mdi:network'), 'Connection settings', AppSettingsSection.connectionSettings),
        _buildMenuItem(context, MaterialDesignIcons.getIconDataFromIconName('mdi:cellphone-android'), 'Integration settings', AppSettingsSection.integrationSettings),
        _buildMenuItem(context, MaterialDesignIcons.getIconDataFromIconName('mdi:brush'), 'Look and feel', AppSettingsSection.lookAndFeel),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget section;
    String title;
    String helpUrl;
    switch (_currentSection) {
      case AppSettingsSection.menu: {
        section = _buildMenu(context);
        title = 'App settings';
        helpUrl = 'https://ha-client.app/help/';
        break;
      }
      case AppSettingsSection.connectionSettings: {
        section = ConnectionSettingsPage();
        title = 'App settings - Connection';
        helpUrl = 'https://ha-client.app/help/connection';
        break;
      }
      case AppSettingsSection.integrationSettings: {
        section = IntegrationSettingsPage();
        title = 'App settings - Integration';
        helpUrl = 'https://ha-client.app/help/mobile_app_integration';
        break;
      }
      case AppSettingsSection.lookAndFeel: {
        section = LookAndFeelSettingsPage();
        title = 'App settings - Look&Feel';
        helpUrl = 'https://ha-client.app/help/';
        break;
      }
      default:
        title = ':(';
        section = PageLoadingIndicator();
    }
    return WillPopScope(
      child: Scaffold(
        appBar: new AppBar(
          leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: (){
            if (_currentSection == AppSettingsSection.menu) {
              Navigator.pop(context);
            } else {
              setState(() {
                _currentSection = AppSettingsSection.menu;
              });
            }
          }),
          title: Text(title),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.help),
              onPressed: () {
                Launcher.launchURLInCustomTab(
                context: context,
                url: helpUrl
              );
              },
            )
          ],
        ),
        body: section
      ),
      onWillPop: () {
        if (_currentSection == AppSettingsSection.menu) {
          return Future.value(true);
        } else {
          setState(() {
            _currentSection = AppSettingsSection.menu;
          });
          return Future.value(false);
        }
      },
    );
  }
}