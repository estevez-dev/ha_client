part of '../../main.dart';

class CardHeader extends StatelessWidget {

  final String name;
  final Widget trailing;
  final Widget leading;
  final Widget subtitle;
  final double emptyPadding;

  const CardHeader({Key key, this.name, this.leading, this.emptyPadding: 0, this.trailing, this.subtitle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var result;
    if ((name != null) && (name.trim().length > 0)) {
      result = new ListTile(
        trailing: trailing,
        leading: leading,
        subtitle: subtitle,
        title: Text("$name",
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headline),
      );
    } else {
      result = new Container(width: 0.0, height: emptyPadding);
    }
    return result;
  }

}