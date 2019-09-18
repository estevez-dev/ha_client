part of '../main.dart';

class EntityModel extends InheritedWidget {
  const EntityModel({
    Key key,
    @required this.entityWrapper,
    @required this.handleTap,
    @required Widget child,
  }) : super(key: key, child: child);

  final EntityWrapper entityWrapper;
  final bool handleTap;

  static EntityModel of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(EntityModel);
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }
}