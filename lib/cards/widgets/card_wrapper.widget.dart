part of '../../main.dart';

class CardWrapper extends StatelessWidget {
  
  final Widget child;
  final EdgeInsets padding;

  const CardWrapper({Key key, this.child, this.padding: const EdgeInsets.all(0)}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: padding,
        child: child
      ),
    );
  }


}