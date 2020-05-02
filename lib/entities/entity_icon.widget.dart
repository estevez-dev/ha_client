part of '../main.dart';

class EntityIcon extends StatelessWidget {

  final EdgeInsetsGeometry padding;
  final double size;
  final Color color;

  const EntityIcon({Key key, this.color, this.size: Sizes.iconSize, this.padding: const EdgeInsets.all(0.0)}) : super(key: key);

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

  Widget buildIcon(BuildContext context, EntityWrapper data, Color color) {
    Widget result;
    if (data == null) {
      return null;
    }
    if (data.entityPicture != null) {
      result = Container(
        height: size+12,
        width: size+12,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              fit:BoxFit.cover,
              image: CachedNetworkImageProvider(
                "${data.entityPicture}"
              ),
            )
        ),
      );
    } else {
      String iconName = data.icon;
      int iconCode = 0;
      if (iconName.length > 0) {
        iconCode = MaterialDesignIcons.getIconCodeByIconName(iconName);
      } else {
        iconCode = getDefaultIconByEntityId(data.entity.entityId,
            data.entity.deviceClass, data.entity.state); //
      }
      result = Icon(
        IconData(iconCode, fontFamily: 'Material Design Icons'),
        size: size,
        color: color,
      );
      if (data.entity is LightEntity &&
        (data.entity as LightEntity).supportColor &&
        (data.entity as LightEntity).color != null
        ) {
        Color lightColor = (data.entity as LightEntity).color.toColor();
        if (lightColor == Colors.white) {
          return result;
        }  
        result = Stack(
          children: <Widget>[
            result,
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
      }
    }
    return result;
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
    return Padding(
      padding: padding,
      child: buildIcon(
        context,
        entityWrapper,
        iconColor 
      ),
    );
  }
}