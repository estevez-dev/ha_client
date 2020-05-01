part of '../main.dart';

class ErrorCard extends StatelessWidget {
  final ErrorCardData card;

  const ErrorCard({Key key, this.card}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CardWrapper(
      child: Padding(
        padding: EdgeInsets.fromLTRB(Sizes.leftWidgetPadding, Sizes.rowPadding, Sizes.rightWidgetPadding, Sizes.rowPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'There was an error rendering card: ${card.type}. Please copy card config to clipboard and report this issue. Thanks!',
              textAlign: TextAlign.center,
            ),
            RaisedButton(
              onPressed: () {
                Clipboard.setData(new ClipboardData(text: card.cardConfig));
              },
              child: Text('Copy card config'),
            ),
            RaisedButton(
              onPressed: () {
                Launcher.launchURLInBrowser("https://github.com/estevez-dev/ha_client/issues/new?assignees=&labels=&template=bug_report.md&title=");
              },
              child: Text('Report issue'),
            )
          ],
        ),
      )
    );
  }  
}