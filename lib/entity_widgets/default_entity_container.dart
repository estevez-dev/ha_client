part of '../main.dart';

class DefaultEntityContainer extends StatelessWidget {
  DefaultEntityContainer({
    Key key,
    @required this.state
  }) : super(key: key);

  final Widget state;

  @override
  Widget build(BuildContext context) {
    final EntityModel entityModel = EntityModel.of(context);
    if (entityModel.entityWrapper.entity.statelessType == StatelessEntityType.MISSED) {
      return MissedEntityWidget();
    }
    if (entityModel.entityWrapper.entity.statelessType == StatelessEntityType.DIVIDER) {
      return Divider(
        color: Colors.black45,
      );
    }
    if (entityModel.entityWrapper.entity.statelessType == StatelessEntityType.SECTION) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Divider(
            color: Colors.black45,
          ),
          Text(
              "${entityModel.entityWrapper.entity.displayName}",
            style: TextStyle(color: Colors.blue),
          )
        ],
      );
    }
    Widget result = Row(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        EntityIcon(),

        Flexible(
          fit: FlexFit.tight,
          flex: 3,
          child: EntityName(
            padding: EdgeInsets.fromLTRB(10.0, 2.0, 10.0, 2.0),
          ),
        ),
        state
      ],
    );
    if (entityModel.handleTap) {
      return InkWell(
        onLongPress: () {
          if (entityModel.handleTap) {
            entityModel.entityWrapper.handleHold();
          }
        },
        onTap: () {
          if (entityModel.handleTap) {
            entityModel.entityWrapper.handleTap();
          }
        },
        child: result,
      );
    } else {
      return result;
    }
  }
}