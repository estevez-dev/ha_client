part of '../../../main.dart';

class CoverStateWidget extends StatelessWidget {
  void _open(CoverEntity entity) {
    ConnectionManager().callService(
        entity.domain, "open_cover", entity.entityId, null);
  }

  void _close(CoverEntity entity) {
    ConnectionManager().callService(
        entity.domain, "close_cover", entity.entityId, null);
  }

  void _stop(CoverEntity entity) {
    ConnectionManager().callService(
        entity.domain, "stop_cover", entity.entityId, null);
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