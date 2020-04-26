part of '../main.dart';

class HorizontalStackCard extends StatelessWidget {
  final HorizontalStackCardData card;

  const HorizontalStackCard({Key key, this.card}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (card.childCards.isNotEmpty) {
      List<Widget> children = [];
      children = card.childCards.map((childCard) => Flexible(
          fit: FlexFit.tight,
          child: childCard.buildCardWidget()
        )
      ).toList();
      return IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      );
    }
    return Container(height: 0.0, width: 0.0,);
  }

  
}