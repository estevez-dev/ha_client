part of '../main.dart';

class MissedEntityWidget extends StatelessWidget {
  MissedEntityWidget({
    Key key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final EntityModel entityModel = EntityModel.of(context);
    return Container(
        child: Padding(
          padding: EdgeInsets.all(5.0),
          child: Text("Entity not available: ${entityModel.entityWrapper.entity.entityId}"),
        ),
        color: Colors.amber[100],
    );
  }
}