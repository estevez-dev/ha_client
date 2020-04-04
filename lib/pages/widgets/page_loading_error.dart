part of '../../main.dart';

class PageLoadingError extends StatelessWidget {

  final String errorText;

  const PageLoadingError({Key key, this.errorText: "Error"}) : super(key: key);

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
                child: Icon(
                    Icons.error,
                    color: Colors.redAccent,
                    size: 48.0
                )
            ),
            Text(this.errorText, style: Theme.of(context).textTheme.subtitle)
          ],
        )
      ],
    );
  }
}
