part of '../main.dart';

class LovelaceCard extends StatelessWidget {

  final HACard card;

  const LovelaceCard({
    Key key,
    this.card
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (card.linkedEntityWrapper!= null) {
      if (card.linkedEntityWrapper.entity.isHidden) {
        return Container(width: 0.0, height: 0.0,);
      }
      if (card.linkedEntityWrapper.entity.statelessType == StatelessEntityType.missed) {
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
        return EntitiesCard(card: card);
      }

      case CardType.GLANCE: {
        return GlanceCard(card: card);
      }

      case CardType.MEDIA_CONTROL: {
        return MediaControlsCard(card: card);
      }

      case CardType.ENTITY_BUTTON: {
        return EntityButtonCard(card: card);
      }

      case CardType.BUTTON: {
        return EntityButtonCard(card: card);
      }

      case CardType.GAUGE: {
        return GaugeCard(card: card);
      }

      case CardType.MARKDOWN: {
        return MarkdownCard(card: card);
      }

      case CardType.ALARM_PANEL: {
        return AlarmPanelCard(card: card);
      }

      case CardType.HORIZONTAL_STACK: {
        return HorizontalStackCard(card: card);
      }

      case CardType.VERTICAL_STACK: {
        return VerticalStackCard(card: card);
      }

      default: {
        if ((card.linkedEntityWrapper == null) && (card.entities.isNotEmpty)) {
          return EntitiesCard(card: card);
        } else {
          return UnsupportedCard(card: card);
        }
      }

    }
  }

}
