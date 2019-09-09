part of '../main.dart';

class BadgeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final entityModel = EntityModel.of(context);
    double iconSize = 26.0;
    Widget badgeIcon;
    String onBadgeTextValue;
    Color iconColor = EntityColor.badgeColors[entityModel.entityWrapper.entity.domain] ??
        EntityColor.badgeColors["default"];
    switch (entityModel.entityWrapper.entity.domain) {
      case "sun":
        {
          badgeIcon = entityModel.entityWrapper.entity.state == "below_horizon"
              ? Icon(
            MaterialDesignIcons.getIconDataFromIconCode(0xf0dc),
            size: iconSize,
          )
              : Icon(
            MaterialDesignIcons.getIconDataFromIconCode(0xf5a8),
            size: iconSize,
          );
          break;
        }
      case "camera":
      case "media_player":
      case "binary_sensor":
        {
          badgeIcon = EntityIcon(
            padding: EdgeInsets.all(0.0),
            size: iconSize,
            color: Colors.black
          );
          break;
        }
      case "device_tracker":
      case "person":
        {
          badgeIcon = EntityIcon(
              padding: EdgeInsets.all(0.0),
              size: iconSize,
              color: Colors.black
          );
          onBadgeTextValue = entityModel.entityWrapper.entity.displayState;
          break;
        }
      default:
        {
          double stateFontSize;
          if (entityModel.entityWrapper.entity.displayState.length <= 3) {
            stateFontSize = 18.0;
          } else if (entityModel.entityWrapper.entity.displayState.length <= 4) {
            stateFontSize = 15.0;
          } else if (entityModel.entityWrapper.entity.displayState.length <= 6) {
            stateFontSize = 10.0;
          } else if (entityModel.entityWrapper.entity.displayState.length <= 10) {
            stateFontSize = 8.0;
          }
          onBadgeTextValue = entityModel.entityWrapper.unitOfMeasurement;
          badgeIcon = Center(
            child: Text(
              "${entityModel.entityWrapper.entity.displayState}",
              overflow: TextOverflow.fade,
              softWrap: false,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: stateFontSize),
            ),
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
              style: TextStyle(fontSize: 12.0, color: Colors.white),
              textAlign: TextAlign.center,
              softWrap: false,
              overflow: TextOverflow.fade),
          decoration: new BoxDecoration(
            // Circle shape
            //shape: BoxShape.circle,
            color: iconColor,
            borderRadius: BorderRadius.circular(9.0),
          ));
    }
    return GestureDetector(
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
              width: 50.0,
              height: 50.0,
              decoration: new BoxDecoration(
                // Circle shape
                shape: BoxShape.circle,
                color: Colors.white,
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
                    width: 46.0,
                    height: 46.0,
                    top: 0.0,
                    left: 0.0,
                    child: badgeIcon,
                  ),
                  Positioned(
                    //width: 50.0,
                      bottom: -9.0,
                      left: -10.0,
                      right: -10.0,
                      child: Center(
                        child: onBadgeText,
                      ))
                ],
              ),
            ),
            Container(
              width: 60.0,
              child: Text(
                "${entityModel.entityWrapper.displayName}",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.0),
                softWrap: true,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        onTap: () =>
            eventBus.fire(new ShowEntityPageEvent(entityModel.entityWrapper.entity)));
  }
}