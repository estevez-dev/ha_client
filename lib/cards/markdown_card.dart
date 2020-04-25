part of '../main.dart';

class MarkdownCard extends StatelessWidget {
  final HACard card;

  const MarkdownCard({Key key, this.card}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (card.content == null) {
      return Container(height: 0.0, width: 0.0,);
    } else if (card.content == '***') {
      return Container(height: Sizes.rowPadding, width: 0.0,);
    }
    return CardWrapper(
        child: Padding(
          padding: EdgeInsets.fromLTRB(Sizes.leftWidgetPadding, Sizes.rowPadding, Sizes.rightWidgetPadding, Sizes.rowPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              CardHeader(name: card.name),
              MarkdownBody(
                data: card.content,
              )
            ],
          ),
        )
    );
  }

  
}