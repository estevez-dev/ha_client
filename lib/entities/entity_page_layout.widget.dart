part of '../main.dart';

class EntityPageLayout extends StatelessWidget {

  final bool showClose;
  final Entity entity;

  const EntityPageLayout({Key key, @required this.entity, this.showClose: false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EntityModel(
      entityWrapper: EntityWrapper(entity: this.entity),
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
                        this.entity.displayName,
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
              child: DefaultEntityContainer(state: this.entity._buildStatePartForPage(context)),
            ),
            LastUpdatedWidget(),
            Divider(),
            this.entity._buildAdditionalControlsForPage(context),
            Divider(),
            EntityHistoryWidget(),
            EntityAttributesList()
          ]
      ),
      handleTap: false,
    );
  }
}
