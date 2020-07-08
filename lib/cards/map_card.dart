part of '../main.dart';

class MapCard extends StatelessWidget {
  final MapCardData card;

  const MapCard({Key key, this.card}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CardWrapper(
        child: Padding(
          padding: EdgeInsets.fromLTRB(Sizes.leftWidgetPadding, Sizes.rowPadding, Sizes.rightWidgetPadding, Sizes.rowPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              CardHeader(name: card.title)
            ],
          ),
        )
    );
  }

  
}