part of '../main.dart';

class MapCard extends StatefulWidget {
  final MapCardData card;

  const MapCard({Key key, this.card}) : super(key: key);

  @override
  _MapCardState createState() => _MapCardState();
}

class _MapCardState extends State<MapCard> {

  @override
  Widget build(BuildContext context) {

    return CardWrapper(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            CardHeader(name: widget.card.title),
            EntitiesMap(
              aspectRatio: 1,
              entities: widget.card.entities,
            )
          ],
        )
    );
  }
}