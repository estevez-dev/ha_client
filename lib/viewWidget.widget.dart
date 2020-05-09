part of 'main.dart';

class ViewWidget extends StatelessWidget {
  final HAView view;

  const ViewWidget({
    Key key,
    this.view
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (this.view.isPanel) {
      return FractionallySizedBox(
        widthFactor: 1,
        heightFactor: 1,
        child: _buildPanelChild(context),
      );
    } else {
      Widget cardsContainer;
      if (this.view.cards.isNotEmpty) {
        cardsContainer = DynamicMultiColumnLayout(
          minColumnWidth: Sizes.minViewColumnWidth,
          children: this.view.cards.map((card) {
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
            return card.buildCardWidget();
          }).toList(),
        );
      } else {
        cardsContainer = Container();
      }
      return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          padding: EdgeInsets.all(0),
          child: cardsContainer
      );
    }
  }

  Widget _buildPanelChild(BuildContext context) {
    if (this.view.cards != null && this.view.cards.isNotEmpty) {
      return this.view.cards[0].buildCardWidget();
    } else {
      return Container(width: 0, height: 0);
    }
  }

}