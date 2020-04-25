part of '../main.dart';

class VerticalStackCard extends StatelessWidget {
  final HACard card;

  const VerticalStackCard({Key key, this.card}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (card.childCards.isNotEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: card.childCards.map(
          (childCard) => LovelaceCard(card: childCard)
        ).toList(),
      );
    }
    return Container(height: 0.0, width: 0.0,);
  }

  
}