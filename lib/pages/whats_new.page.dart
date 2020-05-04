part of '../main.dart';

class WhatsNewPage extends StatefulWidget {
  WhatsNewPage({Key key}) : super(key: key);

  @override
  _WhatsNewPageState createState() => new _WhatsNewPageState();
}

class _WhatsNewPageState extends State<WhatsNewPage> {

  String data = "";
  String error = "";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() async {
    setState(() {
      data = "";
      error = "";
    });
    http.Response response;
    response = await http.get("http://ha-client.app/service/whats_new_1.0.0_beta.md");
    if (response.statusCode == 200) {
      setState(() {
        data = response.body;
      });
    } else {
      setState(() {
        error = "Can't load changelog";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (error.isNotEmpty) {
      body = PageLoadingError(errorText: error,);
    } else if (data.isEmpty) {
      body = PageLoadingIndicator();
    } else {
      body = Markdown(
        data: data,
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
        title: new Text("What's new"),
      ),
      body: body
    );
  }
}
