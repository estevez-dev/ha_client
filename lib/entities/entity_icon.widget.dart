part of '../main.dart';

class EntityIcon extends StatelessWidget {

  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry iconPadding;
  final EdgeInsetsGeometry imagePadding;
  final double size;
  final Color color;

  const EntityIcon({Key key, this.color, this.size: Sizes.iconSize, this.padding: const EdgeInsets.all(0.0), this.iconPadding, this.imagePadding}) : super(key: key);

  int getDefaultIconByEntityId(String entityId, String deviceClass, String state) {
    if (entityId == null) {
      return 0;
    }
    String domain = entityId.split(".")[0];
    String iconNameByDomain = MaterialDesignIcons.defaultIconsByDomains["$domain.$state"] ?? MaterialDesignIcons.defaultIconsByDomains["$domain"];
    String iconNameByDeviceClass;
    if (deviceClass != null) {
      iconNameByDeviceClass = MaterialDesignIcons.defaultIconsByDeviceClass["$domain.$deviceClass.$state"] ?? MaterialDesignIcons.defaultIconsByDeviceClass["$domain.$deviceClass"];
    }
    String iconName = iconNameByDeviceClass ?? iconNameByDomain;
    if (iconName != null) {
      return MaterialDesignIcons.iconsDataMap[iconName] ?? 0;
    } else {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final EntityWrapper entityWrapper = EntityModel.of(context).entityWrapper;
    Color iconColor;
    if (color != null) {
      iconColor = color;
    } else if (entityWrapper.stateColor) {
      iconColor = HAClientTheme().getColorByEntityState(entityWrapper.entity.state, context);
    } else {
      iconColor = HAClientTheme().getOffStateColor(context);
    }
    Widget iconWidget;
    bool isPicture = false;
    if (entityWrapper == null) {
      iconWidget = Container(
        width: size,
        height: size,
      );
    } else {
      if (entityWrapper.entityPicture != null) {
        iconWidget = Container(
          height: size+12,
          width: size+12,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                fit:BoxFit.cover,
                image: CachedNetworkImageProvider(
                  "${entityWrapper.entityPicture}"
                ),
              )
          ),
        );
        isPicture = true;
      } else {
        String iconName = entityWrapper.icon;
        int iconCode = 0;
        if (iconName.length > 0) {
          iconCode = MaterialDesignIcons.getIconCodeByIconName(iconName);
        } else {
          iconCode = getDefaultIconByEntityId(entityWrapper.entity.entityId,
              entityWrapper.entity.deviceClass, entityWrapper.entity.state); //
        }
        if (entityWrapper.entity is LightEntity &&
          (entityWrapper.entity as LightEntity).supportColor &&
          (entityWrapper.entity as LightEntity).color != null &&
          (entityWrapper.entity as LightEntity).color.toColor() != Colors.white
          ) {
          Color lightColor = (entityWrapper.entity as LightEntity).color.toColor();  
          iconWidget = Stack(
            children: <Widget>[
              Icon(
                IconData(iconCode, fontFamily: 'Material Design Icons'),
                size: size,
                color: iconColor,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: size / 3,
                  height: size / 3,
                  decoration: BoxDecoration(
                    color: lightColor,
                    shape: BoxShape.circle,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        spreadRadius: 0,
                        blurRadius: 0,
                        offset: Offset(0.3, 0.3)
                      )
                    ]
                  ),
                ),
              )
            ],
          );
        } else {
          iconWidget = Icon(
            IconData(iconCode, fontFamily: 'Material Design Icons'),
            size: size,
            color: iconColor,
          );
        }
      }
    }
    EdgeInsetsGeometry computedPadding;
    if (isPicture && imagePadding != null) {
      computedPadding = imagePadding;
    } else if (!isPicture && iconPadding != null) {
      computedPadding = iconPadding;
    } else {
      computedPadding = padding;
    }
    return Padding(
      padding: computedPadding,
      child: iconWidget,
    );
  }
}