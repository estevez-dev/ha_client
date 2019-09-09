part of '../../main.dart';

class EntityPageContainer extends StatelessWidget {
  EntityPageContainer({Key key, @required this.children}) : super(key: key);

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: children,
    );
  }
}