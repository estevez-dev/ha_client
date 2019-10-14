part of '../main.dart';

class CardWidget extends StatelessWidget {

  final HACard card;

  const CardWidget({
    Key key,
    this.card
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (card.linkedEntityWrapper!= null) {
      if (card.linkedEntityWrapper.entity.isHidden) {
        return Container(width: 0.0, height: 0.0,);
      }
      if (card.linkedEntityWrapper.entity.statelessType == StatelessEntityType.MISSED) {
        return EntityModel(
          entityWrapper: card.linkedEntityWrapper,
          child: MissedEntityWidget(),
          handleTap: false,
        );
      }
    }

    if (card.conditions.isNotEmpty) {
      bool showCardByConditions = true;
      for (var condition in card.conditions) {
        Entity conditionEntity = HomeAssistant().entities.get(condition['entity']);
        if (conditionEntity != null &&
            ((condition['state'] != null && conditionEntity.state != condition['state']) ||
            (condition['state_not'] != null && conditionEntity.state == condition['state_not']))
          ) {
          showCardByConditions = false;
          break;
        }
      }
      if (!showCardByConditions) {
        return Container(width: 0.0, height: 0.0,);
      }
    }

    switch (card.type) {

      case CardType.ENTITIES: {
        return _buildEntitiesCard(context);
      }

      case CardType.GLANCE: {
        return _buildGlanceCard(context);
      }

      case CardType.MEDIA_CONTROL: {
        return _buildMediaControlsCard(context);
      }

      case CardType.ENTITY_BUTTON: {
        return _buildEntityButtonCard(context);
      }

      case CardType.GAUGE: {
        return _buildGaugeCard(context);
      }

/*      case CardType.LIGHT: {
        return _buildLightCard(context);
      }*/

      case CardType.MARKDOWN: {
        return _buildMarkdownCard(context);
      }

      case CardType.ALARM_PANEL: {
        return _buildAlarmPanelCard(context);
      }

      case CardType.HORIZONTAL_STACK: {
        if (card.childCards.isNotEmpty) {
          List<Widget> children = [];
          card.childCards.forEach((card) {
            if (card.getEntitiesToShow().isNotEmpty || card.showEmpty) {
              children.add(
                  Flexible(
                    fit: FlexFit.tight,
                    child: card.build(context),
                  )
              );
            }
          });
          return Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          );
        }
        return Container(height: 0.0, width: 0.0,);
      }

      case CardType.VERTICAL_STACK: {
        if (card.childCards.isNotEmpty) {
          List<Widget> children = [];
          card.childCards.forEach((card) {
            children.add(
                card.build(context)
            );
          });
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: children,
          );
        }
        return Container(height: 0.0, width: 0.0,);
      }

      default: {
        if ((card.linkedEntityWrapper == null) && (card.entities.isNotEmpty)) {
          return _buildEntitiesCard(context);
        } else {
          return _buildUnsupportedCard(context);
        }
      }

    }
  }

  Widget _buildEntitiesCard(BuildContext context) {
    List<EntityWrapper> entitiesToShow = card.getEntitiesToShow();
    if (entitiesToShow.isEmpty && !card.showEmpty) {
      return Container(height: 0.0, width: 0.0,);
    }
    List<Widget> body = [];
    body.add(CardHeader(name: card.name));
    entitiesToShow.forEach((EntityWrapper entity) {
      body.add(
          Padding(
            padding: EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 4.0),
            child: EntityModel(
                entityWrapper: entity,
                handleTap: true,
                child: entity.entity.buildDefaultWidget(context)
            ),
          ));
    });
    return Card(
        child: Padding(
          padding: EdgeInsets.only(right: Sizes.rightWidgetPadding, left: Sizes.leftWidgetPadding),
          child: Column(mainAxisSize: MainAxisSize.min, children: body),
        )
    );
  }

  Widget _buildMarkdownCard(BuildContext context) {
    if (card.content == null) {
      return Container(height: 0.0, width: 0.0,);
    }
    List<Widget> body = [];
    body.add(CardHeader(name: card.name));
    body.add(MarkdownBody(data: card.content));
    return Card(
        child: Padding(
          padding: EdgeInsets.fromLTRB(Sizes.leftWidgetPadding, Sizes.rowPadding, Sizes.rightWidgetPadding, Sizes.rowPadding),
          child: new Column(mainAxisSize: MainAxisSize.min, children: body),
        )
    );
  }

  Widget _buildAlarmPanelCard(BuildContext context) {
    List<Widget> body = [];
    body.add(CardHeader(
      name: card.name ?? "",
      subtitle: Text("${card.linkedEntityWrapper.entity.displayState}",
        style: TextStyle(
            color: Colors.grey
        ),
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
                    onPressed: () => eventBus.fire(new ShowEntityPageEvent(entity: card.linkedEntityWrapper.entity))
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
    return Card(
        child: EntityModel(
            entityWrapper: card.linkedEntityWrapper,
            handleTap: null,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: body
            )
        )
    );
  }

  Widget _buildGlanceCard(BuildContext context) {
    List<EntityWrapper> entitiesToShow = card.getEntitiesToShow();
    if (entitiesToShow.isEmpty && !card.showEmpty) {
      return Container(height: 0.0, width: 0.0,);
    }
    List<Widget> rows = [];
    rows.add(CardHeader(name: card.name));

    int columnsCount = entitiesToShow.length >= card.columnsCount ? card.columnsCount : entitiesToShow.length;

    rows.add(
        Padding(
          padding: EdgeInsets.only(bottom: Sizes.rowPadding, top: Sizes.rowPadding),
          child: FractionallySizedBox(
            widthFactor: 1,
            child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  List<Widget> buttons = [];
                  double buttonWidth = constraints.maxWidth / columnsCount;
                  entitiesToShow.forEach((EntityWrapper entity) {
                    buttons.add(
                        SizedBox(
                          width: buttonWidth,
                          child: EntityModel(
                              entityWrapper: entity,
                              child: GlanceCardEntityContainer(
                                showName: card.showName,
                                showState: card.showState,
                              ),
                              handleTap: true
                          ),
                        )
                    );
                  });
                  return Wrap(
                    //spacing: 5.0,
                    //alignment: WrapAlignment.spaceEvenly,
                    runSpacing: Sizes.doubleRowPadding,
                    children: buttons,
                  );
                }
            ),
          ),
        )
    );

    return Card(
        child: Column(
            mainAxisSize: MainAxisSize.min,
            children: rows
        )
    );
  }

  Widget _buildMediaControlsCard(BuildContext context) {
    return Card(
        child: EntityModel(
            entityWrapper: card.linkedEntityWrapper,
            handleTap: null,
            child: MediaPlayerWidget()
        )
    );
  }

  Widget _buildEntityButtonCard(BuildContext context) {
    card.linkedEntityWrapper.displayName = card.name?.toUpperCase() ??
        card.linkedEntityWrapper.displayName.toUpperCase();
    return Card(
        child: EntityModel(
            entityWrapper: card.linkedEntityWrapper,
            child: EntityButtonCardBody(),
            handleTap: true
        )
    );
  }

  Widget _buildGaugeCard(BuildContext context) {
    card.linkedEntityWrapper.displayName = card.name ??
        card.linkedEntityWrapper.displayName;
    card.linkedEntityWrapper.unitOfMeasurement = card.unit ??
        card.linkedEntityWrapper.unitOfMeasurement;
    return Card(
        child: EntityModel(
            entityWrapper: card.linkedEntityWrapper,
            child: GaugeCardBody(
              min: card.min,
              max: card.max,
              severity: card.severity,
            ),
            handleTap: true
        )
    );
  }

  Widget _buildLightCard(BuildContext context) {
    card.linkedEntityWrapper.displayName = card.name ??
        card.linkedEntityWrapper.displayName;
    return Card(
        child: EntityModel(
            entityWrapper: card.linkedEntityWrapper,
            child: LightCardBody(
              min: card.min,
              max: card.max,
              severity: card.severity,
            ),
            handleTap: true
        )
    );
  }

  Widget _buildUnsupportedCard(BuildContext context) {
    List<Widget> body = [];
    body.add(CardHeader(name: card.name ?? ""));
    List<Widget> result = [];
    if (card.linkedEntityWrapper != null) {
      result.addAll(<Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(0.0, Sizes.rowPadding, 0.0, Sizes.rowPadding),
          child: EntityModel(
              entityWrapper: card.linkedEntityWrapper,
              handleTap: true,
              child: card.linkedEntityWrapper.entity.buildDefaultWidget(context)
          ),
        )
      ]);
    } else {
      result.addAll(<Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(Sizes.leftWidgetPadding, Sizes.rowPadding, Sizes.rightWidgetPadding, Sizes.rowPadding),
          child: Text("'${card.type}' card is not supported yet"),
        ),
      ]);
    }
    body.addAll(result);
    return Card(
        child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: body
        )
    );
  }

}
