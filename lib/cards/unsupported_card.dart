part of '../main.dart';

class UnsupportedCard extends StatelessWidget {
  final CardData card;

  const UnsupportedCard({Key key, this.card}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CardWrapper(
      child: Padding(
        padding: EdgeInsets.fromLTRB(Sizes.leftWidgetPadding, Sizes.rowPadding, Sizes.rightWidgetPadding, Sizes.rowPadding),
        child: Text("'${card.type}' card is not supported yet"),
      )
    );
  }  
}