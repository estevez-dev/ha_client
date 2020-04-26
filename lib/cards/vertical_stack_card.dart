part of '../main.dart';

class VerticalStackCard extends StatelessWidget {
  final VerticalStackCardData card;

  const VerticalStackCard({Key key, this.card}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (card.childCards.isNotEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: card.childCards.map<Widget>(
          (childCard) => childCard.buildCardWidget()
        ).toList(),
      );
    }
    return Container(height: 0.0, width: 0.0,);
  }

  
}