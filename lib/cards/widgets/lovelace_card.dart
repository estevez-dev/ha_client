part of '../../main.dart';

class LovelaceCard extends StatelessWidget {
  
  final Widget child;

  const LovelaceCard({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: child,
    );
  }


}