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
    return context.dependOnInheritedWidgetOfExactType<EntityModel>();
  }

  @override
  bool updateShouldNotify(EntityModel oldWidget) {
    return entityWrapper.entity.lastUpdatedTimestamp != oldWidget.entityWrapper.entity.lastUpdatedTimestamp;
  }
}