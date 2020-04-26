part of '../main.dart';

class EntityButtonCard extends StatelessWidget {

  final ButtonCardData card;

  EntityButtonCard({
    Key key, this.card
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    EntityWrapper entityWrapper = card.entity;
    if (entityWrapper.entity.statelessType == StatelessEntityType.missed) {
      return EntityModel(
        entityWrapper: card.entity,
        child: MissedEntityWidget(),
        handleTap: false,
      );
    } else if (entityWrapper.entity.statelessType != StatelessEntityType.ghost && entityWrapper.entity.statelessType != StatelessEntityType.none) {
      return Container(width: 0.0, height: 0.0,);
    }
    double widthBase =  math.min(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height) / 6;
    
    Widget buttonIcon;
    if (!card.showIcon) {
      buttonIcon = Container(height: Sizes.rowPadding, width: 10);
    } else {
      buttonIcon = EntityIcon(
        padding: EdgeInsets.fromLTRB(2.0, 6.0, 2.0, 2.0),
        size: widthBase / (card.depth * 0.5),
      );
    }

    return CardWrapper(
      child: EntityModel(
        entityWrapper: card.entity,
        child: InkWell(
          onTap: () => entityWrapper.handleTap(),
          onLongPress: () => entityWrapper.handleHold(),
          onDoubleTap: () => entityWrapper.handleDoubleTap(),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                buttonIcon,
                _buildName()
              ],
            )
          ),
        ),
        handleTap: true
      )
    );
  }

  Widget _buildName() {
    if (card.showName) {
      return EntityName(
        padding: EdgeInsets.fromLTRB(Sizes.buttonPadding, 0.0, Sizes.buttonPadding, Sizes.rowPadding),
        textOverflow: TextOverflow.ellipsis,
        maxLines: 3,
        wordsWrap: true,
        textAlign: TextAlign.center
      );
    }
    return Container(width: 0, height: 0);
  }
}