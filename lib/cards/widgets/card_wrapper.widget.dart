part of '../../main.dart';

class CardWrapper extends StatelessWidget {
  
  final Widget child;
  final EdgeInsets padding;
  final Color color;

  const CardWrapper({Key key, this.child, this.color, this.padding: const EdgeInsets.all(0)}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: Padding(
        padding: padding,
        child: child
      ),
    );
  }


}