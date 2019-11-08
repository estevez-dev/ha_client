part of '../../../main.dart';

class CoverStateWidget extends StatelessWidget {
  void _open(CoverEntity entity) {
    ConnectionManager().callService(
        domain: entity.domain,
        service: "open_cover",
        entityId: entity.entityId
      );
  }

  void _close(CoverEntity entity) {
    ConnectionManager().callService(
        domain: entity.domain,
        service: "close_cover",
        entityId: entity.entityId
      );
  }

  void _stop(CoverEntity entity) {
    ConnectionManager().callService(
        domain: entity.domain,
        service: "stop_cover",
        entityId: entity.entityId
      );
  }

  @override
  Widget build(BuildContext context) {
    final entityModel = EntityModel.of(context);
    final CoverEntity entity = entityModel.entityWrapper.entity;
    List<Widget> buttons = [];
    if (entity.supportOpen) {
      buttons.add(IconButton(
          icon: Icon(
            MaterialDesignIcons.getIconDataFromIconName("mdi:arrow-up"),
            size: Sizes.iconSize,
          ),
          onPressed: entity.canBeOpened ? () => _open(entity) : null));
    } else {
      buttons.add(Container(
        width: Sizes.iconSize + 20.0,
      ));
    }
    if (entity.supportStop) {
      buttons.add(IconButton(
          icon: Icon(
            MaterialDesignIcons.getIconDataFromIconName("mdi:stop"),
            size: Sizes.iconSize,
          ),
          onPressed: () => _stop(entity)));
    } else {
      buttons.add(Container(
        width: Sizes.iconSize + 20.0,
      ));
    }
    if (entity.supportClose) {
      buttons.add(IconButton(
          icon: Icon(
            MaterialDesignIcons.getIconDataFromIconName("mdi:arrow-down"),
            size: Sizes.iconSize,
          ),
          onPressed: entity.canBeClosed ? () => _close(entity) : null));
    } else {
      buttons.add(Container(
        width: Sizes.iconSize + 20.0,
      ));
    }

    return Row(
      children: buttons,
    );
  }
}