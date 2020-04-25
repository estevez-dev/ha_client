part of '../main.dart';

class EntitiesCard extends StatelessWidget {
  final HACard card;

  const EntitiesCard({Key key, this.card}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<EntityWrapper> entitiesToShow = card.getEntitiesToShow();
    if (entitiesToShow.isEmpty && !card.showEmpty) {
      return Container(height: 0.0, width: 0.0,);
    }
    List<Widget> body = [];
    Widget headerSwitch;
    if (card.showHeaderToggle) {
      bool headerToggleVal = entitiesToShow.any((EntityWrapper en){ return en.entity.state == EntityState.on; });
      List<String> entitiesToToggle = entitiesToShow.where((EntityWrapper enw) {
        return <String>["switch", "light", "automation", "input_boolean"].contains(enw.entity.domain);
      }).map((EntityWrapper en) {
          return en.entity.entityId;
      }).toList();
      headerSwitch = Switch(
            value: headerToggleVal,
            onChanged: (val) {
              if (entitiesToToggle.isNotEmpty) {
                ConnectionManager().callService(
                  domain: "homeassistant",
                  service: val ? "turn_on" : "turn_off",
                  entityId: entitiesToToggle
                );
              }
            },
          );
    }
    body.add(
      CardHeader(
        name: card.name,
        trailing: headerSwitch,
        emptyPadding: Sizes.rowPadding
      )
    );
    body.addAll(
      entitiesToShow.map((EntityWrapper entity) {
        return Padding(
            padding: EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 4.0),
            child: EntityModel(
                entityWrapper: entity,
                handleTap: true,
                child: entity.entity.buildDefaultWidget(context)
            ),
          );
      })  
    );
    return CardWrapper(
        child: Padding(
          padding: EdgeInsets.only(
            right: Sizes.rightWidgetPadding,
            left: Sizes.leftWidgetPadding,
            bottom: Sizes.rowPadding,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: body
          ),
        )
    );
  }

  
}