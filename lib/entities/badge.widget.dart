part of '../main.dart';

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
          badgeIcon = entityModel.entityWrapper.entity.state == "below_horizon"
              ? Icon(
            MaterialDesignIcons.getIconDataFromIconCode(0xf0dc),
          )
              : Icon(
            MaterialDesignIcons.getIconDataFromIconCode(0xf5a8),
          );
          break;
        }
      case "camera":
      case "media_player":
      case "binary_sensor":
        {
          badgeIcon = EntityIcon(
            padding: EdgeInsets.all(0.0),
            color: Theme.of(context).textTheme.body1.color
          );
          break;
        }
      case "device_tracker":
      case "person":
        {
          badgeIcon = EntityIcon(
              padding: EdgeInsets.all(0.0),
              color: Theme.of(context).textTheme.body1.color
          );
          onBadgeTextValue = entityModel.entityWrapper.entity.displayState;
          break;
        }
      default:
        {
          onBadgeTextValue = entityModel.entityWrapper.unitOfMeasurement;
          badgeIcon = Text(
            "${entityModel.entityWrapper.entity.displayState}",
            overflow: TextOverflow.fade,
            softWrap: false,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.body1
          );
          break;
        }
    }
    Widget onBadgeText;
    if (onBadgeTextValue == null || onBadgeTextValue.length == 0) {
      onBadgeText = Container(width: 0.0, height: 0.0);
    } else {
      onBadgeText = Container(
          padding: EdgeInsets.fromLTRB(6.0, 2.0, 6.0, 2.0),
          child: Text("$onBadgeTextValue",
              style: Theme.of(context).textTheme.overline.copyWith(
                color: HAClientTheme().getOnBadgeTextColor()
              ),
              textAlign: TextAlign.center,
              softWrap: false,
              overflow: TextOverflow.fade),
          decoration: new BoxDecoration(
            color: iconColor,
            borderRadius: BorderRadius.circular(9.0),
          ));
    }
    return GestureDetector(
        child: Column(
          children: <Widget>[
            Container(
              //margin: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
              width: 45,
              height: 45,
              decoration: new BoxDecoration(
                // Circle shape
                shape: BoxShape.circle,
                color: Theme.of(context).cardColor,
                // The border you want
                border: new Border.all(
                  width: 2.0,
                  color: iconColor,
                ),
              ),
              child: Stack(
                overflow: Overflow.visible,
                children: <Widget>[
                  Positioned(
                    width: 45,
                    height: 45,
                    top: 0.0,
                    left: 0.0,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                      child: badgeIcon,
                    ),
                  ),
                  Positioned(
                    bottom: -9.0,
                    left: -10.0,
                    right: -10.0,
                    child: Center(
                      child: onBadgeText,
                    )
                  )
                ],
              ),
            ),
            Container(
              width: 60.0,
              child: Text(
                "${entityModel.entityWrapper.displayName}",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.caption,
                softWrap: true,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        onTap: () => entityModel.entityWrapper.handleTap(),
        onDoubleTap: () => entityModel.entityWrapper.handleDoubleTap(),
        onLongPress: () => entityModel.entityWrapper.handleHold(),
    );
  }
}