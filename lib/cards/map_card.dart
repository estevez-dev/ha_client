part of '../main.dart';

class MapCard extends StatefulWidget {
  final MapCardData card;

  const MapCard({Key key, this.card}) : super(key: key);

  @override
  _MapCardState createState() => _MapCardState();
}

class _MapCardState extends State<MapCard> {

  void _openMap(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (bc) {
          return Scaffold(
            primary: false,
              /*appBar: new AppBar(
                backgroundColor: Colors.transparent,
                leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: (){
                  Navigator.pop(context);
                }),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.fullscreen),
                    onPressed: () {},
                  )
                ],
                // Here we take the value from the MyHomePage object that was created by
                // the App.build method, and use it to set our appbar title.
                title: new Text("${widget.card.title ?? ""}"),
              ),*/
              body: Container(
                  color: Theme.of(context).primaryColor,
                  child: SafeArea(
                    child: Stack(
                      children: <Widget>[
                        EntitiesMap(
                            entities: widget.card.entities,
                            interactive: true
                        ),
                        Positioned(
                            top: 0,
                            left: 0,
                            child: IconButton(icon: Icon(Icons.arrow_back), onPressed: (){
                              Navigator.pop(context);
                            })
                        )
                      ],
                    )
                )
              )
          );
        }
    ));
  }

  @override
  Widget build(BuildContext context) {
    return CardWrapper(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            CardHeader(name: widget.card.title),
            Stack(
              children: <Widget>[
                GestureDetector(
                    onTap: () => _openMap(context),
                    child: EntitiesMap(
                      aspectRatio: 1,
                      interactive: false,
                      entities: widget.card.entities,
                    )
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Text('Tap to open interactive map', style: Theme.of(context).textTheme.caption)
                )
              ],
            ),
          ],
        )
    );
  }
}