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
    
    double iconSize = math.max(card.iconHeightPx, card.iconHeightRem * Theme.of(context).textTheme.body1.fontSize);
    
    Widget buttonIcon;
    if (!card.showIcon) {
      buttonIcon = Container(height: Sizes.rowPadding, width: 10);
    } else if (iconSize > 0) {
      buttonIcon = SizedBox(
        height: iconSize,
        child: FractionallySizedBox(
          widthFactor: 0.5,
          child: FittedBox(
            fit: BoxFit.contain,
            child: EntityIcon(
              //padding: EdgeInsets.only(top: 6),
            ),
          )
        ),
      );
    } else {
      buttonIcon = AspectRatio(
        aspectRatio: 2,
        child: FractionallySizedBox(
          widthFactor: 0.5,
          child: FittedBox(
            fit: BoxFit.fitWidth,
            child: EntityIcon(
              //padding: EdgeInsets.only(top: 6),
            ),
          )
        ),
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
            child: Padding(
              padding: EdgeInsets.only(top: 5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  buttonIcon,
                  _buildName(context)
                ],
              )
            )
          ),
        ),
        handleTap: true
      )
    );
  }

  Widget _buildName(BuildContext context) {
    if (card.showName) {
      return EntityName(
        padding: EdgeInsets.fromLTRB(Sizes.buttonPadding, 0.0, Sizes.buttonPadding, Sizes.rowPadding),
        textOverflow: TextOverflow.ellipsis,
        maxLines: 3,
        textStyle: Theme.of(context).textTheme.subhead,
        wordsWrap: true,
        textAlign: TextAlign.center
      );
    }
    return Container(width: 0, height: 0);
  }
}