part of '../main.dart';

class EntityIcon extends StatelessWidget {

  final EdgeInsetsGeometry padding;
  final double size;
  final Color color;

  const EntityIcon({Key key, this.color, this.size: Sizes.iconSize, this.padding: const EdgeInsets.all(0.0)}) : super(key: key);

  int getDefaultIconByEntityId(String entityId, String deviceClass, String state) {
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

  Widget buildIcon(EntityWrapper data, Color color) {
    if (data == null) {
      return null;
    }
    if (data.entityPicture != null) {
      return Container(
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
    }
    String iconName = data.icon;
    int iconCode = 0;
    if (iconName.length > 0) {
      iconCode = MaterialDesignIcons.getIconCodeByIconName(iconName);
    } else {
      iconCode = getDefaultIconByEntityId(data.entity.entityId,
          data.entity.deviceClass, data.entity.state); //
    }
    return Padding(
        padding: EdgeInsets.fromLTRB(6.0, 6.0, 6.0, 6.0),
        child: Icon(
          IconData(iconCode, fontFamily: 'Material Design Icons'),
          size: size,
          color: color,
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    final EntityWrapper entityWrapper = EntityModel.of(context).entityWrapper;
    return Padding(
      padding: padding,
      child: buildIcon(
          entityWrapper,
          color ?? EntityColor.stateColor(entityWrapper.entity.state)
      ),
    );
  }
}