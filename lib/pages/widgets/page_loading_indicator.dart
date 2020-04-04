part of '../../main.dart';

class PageLoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Column(
          children: <Widget>[
            Padding(
                padding: EdgeInsets.only(top: 40.0, bottom: 20.0),
                child: CircularProgressIndicator()
            ),
            Text("Loading...", style: Theme.of(context).textTheme.subtitle)
          ],
        )
      ],
    );
  }
}
