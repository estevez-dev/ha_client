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
    if (entityModel.entityWrapper.entity.statelessType == StatelessEntityType.missed) {
      return MissedEntityWidget();
    }
    if (entityModel.entityWrapper.entity.statelessType == StatelessEntityType.divider) {
      return Divider();
    }
    if (entityModel.entityWrapper.entity.statelessType == StatelessEntityType.section) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Divider(),
          Text(
              "${entityModel.entityWrapper.entity.displayName}",
            style: HAClientTheme().getLinkTextStyle(context).copyWith(
              decoration: TextDecoration.none
            )
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
        onDoubleTap: () {
          if (entityModel.handleTap) {
            entityModel.entityWrapper.handleDoubleTap();
          }
        },
        child: result,
      );
    } else {
      return result;
    }
  }
}