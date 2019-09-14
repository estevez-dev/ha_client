part of '../main.dart';

class EntityPageLayout extends StatelessWidget {

  final bool showClose;
  final Entity entity;

  EntityPageLayout({Key key, this.showClose: false, this.entity}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EntityModel(
      entityWrapper: EntityWrapper(entity: entity),
      child: ListView(
          padding: EdgeInsets.all(0),
          children: <Widget>[
            showClose ?
            Container(
              color: Colors.blue[300],
              height: 36,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Text(
                        entity.displayName,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 22
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.all(0),
                    icon: Icon(Icons.close),
                    color: Colors.white,
                    iconSize: 30.0,
                    onPressed: () {
                      eventBus.fire(ShowEntityPageEvent());
                    },
                  )
                ],
              ),
            ) :
            Container(height: 0, width: 0,),
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