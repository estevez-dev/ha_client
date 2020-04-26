part of '../main.dart';

class AlarmPanelCard extends StatelessWidget {
  final AlarmPanelCardData card;

  const AlarmPanelCard({Key key, this.card}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (card.entity.entity.statelessType == StatelessEntityType.missed) {
      return EntityModel(
        entityWrapper: card.entity,
        child: MissedEntityWidget(),
        handleTap: false,
      );
    }
    List<Widget> body = [];
    body.add(CardHeader(
      name: card.name ?? "",
      subtitle: Text("${card.entity.entity.displayState}",
    ),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        EntityIcon(
          size: 50.0,
        ),
        Container(
            width: 26.0,
            child: IconButton(
                padding: EdgeInsets.all(0.0),
                alignment: Alignment.centerRight,
                icon: Icon(MaterialDesignIcons.getIconDataFromIconName(
                    "mdi:dots-vertical")),
                onPressed: () => eventBus.fire(new ShowEntityPageEvent(entity: card.entity.entity))
            )
        )
      ]
    ),
    ));
    body.add(
        AlarmControlPanelControlsWidget(
          extended: true,
          states: card.states,
        )
    );
    return CardWrapper(
        child: EntityModel(
            entityWrapper: card.entity,
            handleTap: null,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: body
            )
        )
    );
  }

  
}