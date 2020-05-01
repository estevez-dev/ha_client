part of '../main.dart';

class EntityPageLayout extends StatelessWidget {

  final Entity entity;

  EntityPageLayout({Key key, this.entity}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EntityModel(
      entityWrapper: EntityWrapper(entity: entity),
      child: ListView(
          padding: EdgeInsets.all(0),
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: Sizes.rowPadding, left: Sizes.leftWidgetPadding),
              child: DefaultEntityContainer(state: entity._buildStatePartForPage(context)),
            ),
            LastUpdatedWidget(),
            Divider(),
            entity._buildAdditionalControlsForPage(context),
            Divider(),
            SpoilerCard(
              title: "State history",
              body: EntityHistoryWidget(),
            ),
            SpoilerCard(
              title: "Attributes",
              body: EntityAttributesList(),
            ),
          ]
      ),
      handleTap: false,
    );
  }
}