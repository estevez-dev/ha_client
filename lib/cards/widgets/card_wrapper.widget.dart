part of '../../main.dart';

class CardWrapper extends StatelessWidget {
  
  final Widget child;

  const CardWrapper({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: child,
    );
  }


}