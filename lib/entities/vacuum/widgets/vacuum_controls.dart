part of '../../../main.dart';

class VacuumControls extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    VacuumEntity entity = EntityModel.of(context).entityWrapper.entity;
    return Padding(
      padding: EdgeInsets.only(left: Sizes.leftWidgetPadding, right: Sizes.rightWidgetPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildStatusAndBattery(entity),
          _buildCommands(entity),
          _buildFanSpeed(entity),
          _buildAdditionalInfo(entity)
        ],
      ),
    );
  }

  Widget _buildStatusAndBattery(VacuumEntity entity) {
    List<Widget> result = [];
    if (entity.supportStatus) {
      result.addAll(
          <Widget>[
            Text("Status:", style: TextStyle(fontSize: Sizes.stateFontSize),),
            Container(width: 6,),
            Expanded(
              //flex: 1,
              child: Text(
                "${entity.status}",
                maxLines: 1,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: Sizes.stateFontSize,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),
          ]
      );
    }
    if (entity.supportBattery && entity.batteryLevel != null) {
      String iconName = entity.batteryIcon ?? "mdi:battery";
      int batteryLevel = entity.batteryLevel ?? 100;
      result.addAll(<Widget>[
        Icon(MaterialDesignIcons.getIconDataFromIconName(iconName)),
        Container(width: 6,),
        Text("$batteryLevel %", style: TextStyle(fontSize: Sizes.stateFontSize))
      ]
      );
    }

    if (result.isEmpty) {
      return Container(width: 0, height: 0);
    }

    return Padding(
      padding: EdgeInsets.only(bottom: Sizes.doubleRowPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: result,
      ),
    );
  }

  Widget _buildCommands(VacuumEntity entity) {
    List<Widget> commandButtons = [];
    double iconSize = 32;
    if (entity.supportStart) {
      commandButtons.add(
          IconButton(
            icon: Icon(MaterialDesignIcons.getIconDataFromIconName("mdi:play")),
            iconSize: iconSize,
            onPressed: () => ConnectionManager().callService(
                domain: "vacuum",
                entityId: entity.entityId,
                service: "start"
            ),
          )
      );
    }
    if (entity.supportPause && !entity.supportStart) {
      commandButtons.add(
        IconButton(
          icon: Icon(MaterialDesignIcons.getIconDataFromIconName("mdi:play-pause")),
          iconSize: iconSize,
          onPressed: () => ConnectionManager().callService(
              domain: "vacuum",
              entityId: entity.entityId,
              service: "start_pause"
          ),
        )
      );
    } else if (entity.supportPause) {
      commandButtons.add(
          IconButton(
            icon: Icon(MaterialDesignIcons.getIconDataFromIconName("mdi:pause")),
            iconSize: iconSize,
            onPressed: () => ConnectionManager().callService(
                domain: "vacuum",
                entityId: entity.entityId,
                service: "pause"
            ),
          )
      );
    }
    if (entity.supportStop) {
      commandButtons.add(
          IconButton(
            icon: Icon(MaterialDesignIcons.getIconDataFromIconName("mdi:stop")),
            iconSize: iconSize,
            onPressed: () => ConnectionManager().callService(
                domain: "vacuum",
                entityId: entity.entityId,
                service: "stop"
            ),
          )
      );
    }
    if (entity.supportCleanSpot) {
      commandButtons.add(
          IconButton(
            icon: Icon(MaterialDesignIcons.getIconDataFromIconName("mdi:broom")),
            iconSize: iconSize,
            onPressed: () => ConnectionManager().callService(
                domain: "vacuum",
                entityId: entity.entityId,
                service: "clean_spot"
            ),
          )
      );
    }
    if (entity.supportLocate) {
      commandButtons.add(
          IconButton(
            icon: Icon(MaterialDesignIcons.getIconDataFromIconName("mdi:map-marker")),
            iconSize: iconSize,
            onPressed: () => ConnectionManager().callService(
                domain: "vacuum",
                entityId: entity.entityId,
                service: "locate"
            ),
          )
      );
    }
    if (entity.supportReturnHome) {
      commandButtons.add(
          IconButton(
            icon: Icon(MaterialDesignIcons.getIconDataFromIconName("mdi:home-map-marker")),
            iconSize: iconSize,
            onPressed: () => ConnectionManager().callService(
                domain: "vacuum",
                entityId: entity.entityId,
                service: "return_to_base"
            ),
          )
      );
    }

    if (commandButtons.isEmpty) {
      return Container(width: 0, height: 0,);
    }

    return Padding(
      padding: EdgeInsets.only(bottom: Sizes.doubleRowPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Vacuum cleaner commands:", style: TextStyle(fontSize: Sizes.stateFontSize)),
          Container(height: Sizes.rowPadding,),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: commandButtons.map((button) => Expanded(
              child: button,
            )).toList(),
          )
        ],
      ),
    );
  }

  Widget _buildFanSpeed(VacuumEntity entity) {
    if (entity.supportFanSpeed) {
      return Padding(
        padding: EdgeInsets.only(bottom: Sizes.doubleRowPadding),
        child: ModeSelectorWidget(
            caption: "Fan speed",
            options: entity.fanSpeedList,
            value: entity.fanSpeed,
            onChange: (val) => ConnectionManager().callService(
                domain: "vacuum",
                entityId: entity.entityId,
                service: "set_fan_speed",
                additionalServiceData: {"fan_speed": val}
            )
        ),
      );
    } else {
      return Container(width: 0, height: 0,);
    }

  }

  Widget _buildAdditionalInfo(VacuumEntity entity) {
    List<Widget> rows = [];
    if (entity.cleanedArea != null) {
      rows.add(
        Text("Cleaned area: ${entity.cleanedArea}")
      );
    }

    if (rows.isEmpty) {
      return Container(width: 0, height: 0,);
    }

    return Padding(
      padding: EdgeInsets.only(bottom: Sizes.doubleRowPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rows,
      ),
    );

  }
}
