part of '../../main.dart';

class LinkToWebConfig extends StatelessWidget {

  final String name;
  final String url;

  const LinkToWebConfig({Key key, @required this.name, @required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text("${this.name}",
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headline),
            subtitle: Text("Tap to open web version"),
            onTap: () {
              Launcher.launchAuthenticatedWebView(context: context, url: this.url, title: this.name);
            },
          )
        ],
      ),
    );
  }
}
