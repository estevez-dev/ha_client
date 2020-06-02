part of '../main.dart';

class ErrorCard extends StatelessWidget {
  final ErrorCardData card;
  final String errorText;
  final bool showReportButton;

  const ErrorCard({Key key, this.card, this.errorText, this.showReportButton: true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String error;
    if (errorText == null) {
      error = 'There was an error showing ${card?.type}';
    } else {
      error = errorText;
    }
    return CardWrapper(
      color: Theme.of(context).errorColor,
      child: Padding(
        padding: EdgeInsets.fromLTRB(Sizes.leftWidgetPadding, Sizes.rowPadding, Sizes.rightWidgetPadding, Sizes.rowPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              error,
              textAlign: TextAlign.center,
            ),
            card != null ?
            RaisedButton(
              onPressed: () {
                Clipboard.setData(new ClipboardData(text: card.cardConfig));
              },
              child: Text('Copy card config'),
            ) :
            Container(width: 0, height: 0),
            showReportButton ?
            RaisedButton(
              onPressed: () {
                Launcher.launchURLInBrowser("https://github.com/estevez-dev/ha_client/issues/new?assignees=&labels=&template=bug_report.md&title=");
              },
              child: Text('Report issue'),
            ) :
            Container(width: 0, height: 0)
          ],
        ),
      )
    );
  }  
}