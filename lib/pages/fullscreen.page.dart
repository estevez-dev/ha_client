part of '../main.dart';

class FullScreenPage extends StatelessWidget {

  final Widget child;

  const FullScreenPage({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: this.child,
      ),
    );
  }
}