part of '../main.dart';

class Badges extends StatelessWidget {
  final BadgesData badges;

  const Badges({Key key, this.badges}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<EntityWrapper> entitiesToShow = badges.getEntitiesToShow();
    
    if (entitiesToShow.isNotEmpty) {
      if (ConnectionManager().scrollBadges) {
        return ConstrainedBox(
          constraints: BoxConstraints.tightFor(height: 112),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: entitiesToShow.map((entity) =>
                EntityModel(
                  entityWrapper: entity,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
                    child: BadgeWidget(),
                  ),
                  handleTap: true,
                )).toList()
            ),
          )
        );
      } else {
        return Padding(
          padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 10.0,
            runSpacing: 5,
            children: entitiesToShow.map((entity) =>
                EntityModel(
                  entityWrapper: entity,
                  child: BadgeWidget(),
                  handleTap: true,
                )).toList(),
          )
        );
      }
    }
    return Container(height: 0.0, width: 0.0,);
  }
}

class BadgeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final entityModel = EntityModel.of(context);
    Widget badgeIcon;
    String onBadgeTextValue;
    Color iconColor = HAClientTheme().getBadgeColor(entityModel.entityWrapper.entity.domain);
    switch (entityModel.entityWrapper.entity.domain) {
      case "sun":
        {
          IconData iconData;
          if (entityModel.entityWrapper.entity.state == "below_horizon") {
            iconData = MaterialDesignIcons.getIconDataFromIconCode(0xf0dc);
          } else {
            iconData = MaterialDesignIcons.getIconDataFromIconCode(0xf5a8);
          }
          badgeIcon = Padding(
            padding: EdgeInsets.all(10),
            child: Icon(
              iconData,
            )
          );
          break;
        }
      case "camera":
      case "media_player":
      case "binary_sensor":
        {
          badgeIcon = EntityIcon(
            imagePadding: EdgeInsets.all(0.0),
            iconPadding: EdgeInsets.all(10),
            color: Theme.of(context).textTheme.body2.color
          );
          break;
        }
      case "device_tracker":
      case "person":
        {
          badgeIcon = EntityIcon(
            imagePadding: EdgeInsets.all(0.0),
            iconPadding: EdgeInsets.all(10),
            color: Theme.of(context).textTheme.body2.color
          );
          onBadgeTextValue = entityModel.entityWrapper.entity.displayState;
          break;
        }
      default:
        {
          onBadgeTextValue = entityModel.entityWrapper.unitOfMeasurement;
          badgeIcon = Padding(
            padding: EdgeInsets.all(4),
            child: Text(
              "${entityModel.entityWrapper.entity.displayState}",
              overflow: TextOverflow.fade,
              softWrap: false,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.body1
            )
          );
          break;
        }
    }
    Widget onBadgeText;
    if (onBadgeTextValue == null || onBadgeTextValue.length == 0) {
      onBadgeText = Container(width: 0.0, height: 0.0);
    } else {
      onBadgeText = Container(
        constraints: BoxConstraints(maxWidth: 50),
        padding: EdgeInsets.fromLTRB(6.0, 2.0, 6.0, 2.0),
        child: Text("$onBadgeTextValue",
            style: Theme.of(context).textTheme.overline.copyWith(
              color: HAClientTheme().getOnBadgeTextColor()
            ),
            textAlign: TextAlign.center,
            softWrap: false,
            overflow: TextOverflow.ellipsis
          ),
        decoration: new BoxDecoration(
          color: iconColor,
          borderRadius: BorderRadius.circular(9.0),
        )
      );
    }
    return GestureDetector(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Stack(
              overflow: Overflow.visible,
              alignment: Alignment.center,
              children: <Widget>[
                Container(
                  width: 45,
                  height: 45,
                  decoration: new BoxDecoration(
                    // Circle shape
                    shape: BoxShape.circle,
                    color: Theme.of(context).cardColor,
                    // The border you want
                    border: Border.all(
                      width: 2.0,
                      color: iconColor,
                    ),
                  ),
                ),
                SizedBox(
                  width: 41,
                  height: 41,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    child: badgeIcon,
                  )
                ),
                Positioned(
                  bottom: -6,
                  child: onBadgeText
                )
              ],
            ),
            Container(
              constraints: BoxConstraints(maxWidth: 45),
              padding: EdgeInsets.only(top: 10),
              child: Text(
                "${entityModel.entityWrapper.displayName}",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.caption.copyWith(
                  fontSize: 10
                ),
                softWrap: true,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            )
          ],
        ),
        onTap: () => entityModel.entityWrapper.handleTap(),
        onDoubleTap: () => entityModel.entityWrapper.handleDoubleTap(),
        onLongPress: () => entityModel.entityWrapper.handleHold(),
    );
  }
}