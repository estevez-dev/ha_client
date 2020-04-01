part of '../main.dart';

class ZhaPage extends StatefulWidget {
  ZhaPage({Key key}) : super(key: key);

  @override
  _ZhaPageState createState() => new _ZhaPageState();
}

class _ZhaPageState extends State<ZhaPage> {

  List data = [];
  String error = "";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() async {
    setState(() {
      data.clear();
      error = "";
    });
    ConnectionManager().sendSocketMessage(
      type: 'zha_map/devices'
    ).then((response){
      setState(() {
        data = response['devices'];
      });
    }).catchError((e){
      setState(() {
        error = '$e';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (error.isNotEmpty) {
      body = PageLoadingError(errorText: error,);
    } else if (data.isEmpty) {
      body = PageLoadingIndicator();
    } else {
      List<Widget> devicesListWindet = [];
      data.forEach((device) {
        devicesListWindet.add(
          Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CardHeader(
                  name: '${device['ieee']}',
                  subtitle: Text('${device['manufacturer']}'),
                ),
                Text('${device['device_type']}'),
                Text('model: ${device['model']}'),
                Text('offline: ${device['offline']}'),
                Text('neighbours: ${device['neighbours'].length}'),
                Text('raw: $device'),
              ],
            ),
          )
        );
      });
      body = ListView(
        children: devicesListWindet
      );
    }
    return new Scaffold(
      appBar: new AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: (){
          Navigator.pop(context);
        }),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => _loadData(),
          )
        ],
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text('ZHA'),
      ),
      body: body
    );
  }
}