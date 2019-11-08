part of '../../../main.dart';

class MediaPlayerWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final EntityModel entityModel = EntityModel.of(context);
    final MediaPlayerEntity entity = entityModel.entityWrapper.entity;
    //TheLogger.debug("stop: ${entity.supportStop}, seek: ${entity.supportSeek}");
    return Column(
      children: <Widget>[
        Stack(
          alignment: AlignmentDirectional.topEnd,
          children: <Widget>[
            _buildImage(entity),
            Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: Container(
                color: Colors.black45,
                child: _buildState(entity),
              ),
            ),
            Positioned(
                bottom: 0.0,
                left: 0.0,
                right: 0.0,
                child: MediaPlayerProgressBar()
            )
          ],
        ),
        MediaPlayerPlaybackControls()
      ]
    );
  }

  Widget _buildState(MediaPlayerEntity entity) {
    TextStyle style = TextStyle(
        fontSize: 14.0,
        color: Colors.white,
        fontWeight: FontWeight.normal,
        height: 1.2
    );
    List<Widget> states = [];
    states.add(Text("${entity.displayName}", style: style));
    String state = entity.state;
    if (state == null || state == EntityState.off || state == EntityState.unavailable || state == EntityState.idle) {
      states.add(Text("${entity.state}", style: style.apply(fontSizeDelta: 4.0),));
    }
    if (entity.attributes['media_title'] != null) {
      states.add(Text(
        "${entity.attributes['media_title']}",
        style: style.apply(fontSizeDelta: 6.0, fontWeightDelta: 50),
        maxLines: 1,
        softWrap: true,
        overflow: TextOverflow.ellipsis,
      ));
    }
    if (entity.attributes['media_content_type'] == "music") {
      states.add(Text("${entity.attributes['media_artist'] ?? entity.attributes['app_name']}", style: style.apply(fontSizeDelta: 4.0),));
    } else if (entity.attributes['app_name'] != null) {
      states.add(Text("${entity.attributes['app_name']}", style: style.apply(fontSizeDelta: 4.0),));
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(Sizes.leftWidgetPadding, Sizes.rowPadding, Sizes.rightWidgetPadding, Sizes.rowPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: states,
      ),
    );
  }

  Widget _buildImage(MediaPlayerEntity entity) {
    String state = entity.state;
    if (entity.entityPicture != null && state != EntityState.off && state != EntityState.unavailable && state != EntityState.idle) {
      return Container(
        color: Colors.black,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
              child: Image(
                image: CachedNetworkImageProvider("${entity.entityPicture}"),
                height: 240.0,
                //width: 320.0,
                fit: BoxFit.contain,
              ),
            )
          ],
        ),
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            MaterialDesignIcons.getIconDataFromIconName("mdi:movie"),
            size: 150.0,
            color: EntityColor.stateColor("$state"),
          )
        ],
      );
      /*return Container(
        color: Colors.blue,
        height: 80.0,
      );*/
    }
  }
}

class MediaPlayerPlaybackControls extends StatelessWidget {

  final bool showMenu;
  final bool showStop;

  const MediaPlayerPlaybackControls({Key key, this.showMenu: true, this.showStop: false}) : super(key: key);


  void _setPower(MediaPlayerEntity entity) {
      if (entity.state == EntityState.off) {
        ConnectionManager().callService(
            domain: entity.domain,
            service: "turn_on",
            entityId: entity.entityId
          );
      } else {
        ConnectionManager().callService(
            domain: entity.domain,
            service: "turn_off",
            entityId: entity.entityId
          );
      }
  }

  void _callAction(MediaPlayerEntity entity, String action) {
    Logger.d("${entity.entityId} $action");
    ConnectionManager().callService(
        domain: entity.domain,
        service: "$action",
        entityId: entity.entityId
      );
  }

  @override
  Widget build(BuildContext context) {
    final MediaPlayerEntity entity = EntityModel.of(context).entityWrapper.entity;
    List<Widget> result = [];
    if (entity.supportTurnOn || entity.supportTurnOff) {
      result.add(
          IconButton(
            icon: Icon(Icons.power_settings_new),
            onPressed: () => _setPower(entity),
            iconSize: Sizes.iconSize,
          )
      );
    } else {
      result.add(
          Container(
            width: Sizes.iconSize,
          )
      );
    }
    List <Widget> centeredControlsChildren = [];
    if (entity.supportPreviousTrack && entity.state != EntityState.off && entity.state != EntityState.unavailable) {
      centeredControlsChildren.add(
          IconButton(
            icon: Icon(Icons.skip_previous),
            onPressed: () => _callAction(entity, "media_previous_track"),
            iconSize: Sizes.iconSize,
          )
      );
    }
    if (entity.supportPlay || entity.supportPause) {
      if (entity.state == EntityState.playing) {
        centeredControlsChildren.add(
            IconButton(
              icon: Icon(Icons.pause_circle_filled),
              color: Colors.blue,
              onPressed: () => _callAction(entity, "media_pause"),
              iconSize: Sizes.iconSize*1.8,
            )
        );
      } else if (entity.state == EntityState.paused || entity.state == EntityState.idle) {
        centeredControlsChildren.add(
            IconButton(
              icon: Icon(Icons.play_circle_filled),
              color: Colors.blue,
              onPressed: () => _callAction(entity, "media_play"),
              iconSize: Sizes.iconSize*1.8,
            )
        );
      } else {
        centeredControlsChildren.add(
            Container(
              width: Sizes.iconSize*1.8,
              height: Sizes.iconSize*2.0,
            )
        );
      }
    }
    if (entity.supportNextTrack && entity.state != EntityState.off && entity.state != EntityState.unavailable) {
      centeredControlsChildren.add(
          IconButton(
            icon: Icon(Icons.skip_next),
            onPressed: () => _callAction(entity, "media_next_track"),
            iconSize: Sizes.iconSize,
          )
      );
    }
    if (centeredControlsChildren.isNotEmpty) {
      result.add(
          Expanded(
              child: Row(
                mainAxisAlignment: showMenu ? MainAxisAlignment.center : MainAxisAlignment.end,
                children: centeredControlsChildren,
              )
          )
      );
    } else {
      result.add(
          Expanded(
            child: Container(
              height: 10.0,
            ),
          )
      );
    }
    if (showMenu) {
      result.add(
          IconButton(
              icon: Icon(MaterialDesignIcons.getIconDataFromIconName(
                  "mdi:dots-vertical")),
              onPressed: () => eventBus.fire(new ShowEntityPageEvent(entity: entity))
          )
      );
    } else if (entity.supportStop && entity.state != EntityState.off && entity.state != EntityState.unavailable) {
      result.add(
          IconButton(
              icon: Icon(Icons.stop),
              onPressed: () => _callAction(entity, "media_stop")
          )
      );
    }
    return Row(
      children: result,
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }

}

class MediaPlayerControls extends StatefulWidget {
  @override
  _MediaPlayerControlsState createState() => _MediaPlayerControlsState();
}

class _MediaPlayerControlsState extends State<MediaPlayerControls> {

  double _newVolumeLevel;
  bool _changedHere = false;
  String _newSoundMode;
  String _newSource;

  void _setVolume(double value, String entityId) {
    setState(() {
      _changedHere = true;
      _newVolumeLevel = value;
      ConnectionManager().callService(
        domain: "media_player",
        service: "volume_set",
        entityId: entityId,
        data: {"volume_level": value}
      );
    });
  }

  void _setVolumeMute(bool isMuted, String entityId) {
    ConnectionManager().callService(
      domain: "media_player",
      service: "volume_mute",
      entityId: entityId,
      data: {"is_volume_muted": isMuted}
    );
  }

  void _setVolumeUp(String entityId) {
    ConnectionManager().callService(
      domain: "media_player",
      service: "volume_up",
      entityId: entityId
    );
  }

  void _setVolumeDown(String entityId) {
    ConnectionManager().callService(
      domain: "media_player",
      service: "volume_down",
      entityId: entityId
    );
  }

  void _setSoundMode(String value, String entityId) {
    setState(() {
      _newSoundMode = value;
      _changedHere = true;
      ConnectionManager().callService(
        domain: "media_player",
        service: "select_sound_mode",
        entityId: entityId,
        data: {"sound_mode": "$value"}
      );
    });
  }

  void _setSource(String source, String entityId) {
    setState(() {
      _newSource = source;
      _changedHere = true;
      ConnectionManager().callService(
        domain: "media_player",
        service: "select_source",
        entityId: entityId,
        data: {"source": "$source"}
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final MediaPlayerEntity entity = EntityModel.of(context).entityWrapper.entity;
    List<Widget> children = [
      MediaPlayerPlaybackControls(
        showMenu: false,
      )
    ];
    if (entity.state != EntityState.off && entity.state != EntityState.unknown && entity.state != EntityState.unavailable) {
      if (entity.supportSeek) {
        children.add(MediaPlayerSeekBar());
      } else {
        children.add(MediaPlayerProgressBar());
      }
      Widget muteWidget;
      Widget volumeStepWidget;
      if (entity.supportVolumeMute  || entity.attributes["is_volume_muted"] != null) {
        bool isMuted = entity.attributes["is_volume_muted"] ?? false;
        muteWidget =
            IconButton(
                icon: Icon(isMuted ? Icons.volume_up : Icons.volume_off),
                onPressed: () => _setVolumeMute(!isMuted, entity.entityId)
            );
      } else {
        muteWidget = Container(width: 0.0, height: 0.0,);
      }
      if (entity.supportVolumeStep) {
        volumeStepWidget = Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
                icon: Icon(MaterialDesignIcons.getIconDataFromIconName("mdi:plus")),
                onPressed: () => _setVolumeUp(entity.entityId)
            ),
            IconButton(
                icon: Icon(MaterialDesignIcons.getIconDataFromIconName("mdi:minus")),
                onPressed: () => _setVolumeDown(entity.entityId)
            )
          ],
        );
      } else {
        volumeStepWidget = Container(width: 0.0, height: 0.0,);
      }
      if (entity.supportVolumeSet) {
        if (!_changedHere) {
          _newVolumeLevel = entity._getDoubleAttributeValue("volume_level");
        } else {
          _changedHere = false;
        }
        children.add(
            UniversalSlider(
              leading: muteWidget,
              closing: volumeStepWidget,
              title: "Volume",
              onChanged: (value) {
                setState(() {
                  _changedHere = true;
                  _newVolumeLevel = value;
                });
              },
              value: _newVolumeLevel,
              onChangeEnd: (value) => _setVolume(value, entity.entityId),
              max: 1.0,
              min: 0.0,
            )
        );
      } else {
        children.add(Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            muteWidget,
            volumeStepWidget
          ],
        ));
      }

      if (entity.supportSelectSoundMode && entity.soundModeList != null) {
        if (!_changedHere) {
          _newSoundMode = entity.attributes["sound_mode"];
        } else {
          _changedHere = false;
        }
        children.add(
          ModeSelectorWidget(
              options: entity.soundModeList,
              caption: "Sound mode",
              value: _newSoundMode,
              onChange: (value) => _setSoundMode(value, entity.entityId)
          )
        );
      }

      if (entity.supportSelectSource && entity.sourceList != null) {
        if (!_changedHere) {
          _newSource = entity.attributes["source"];
        } else {
          _changedHere = false;
        }
        children.add(
            ModeSelectorWidget(
                options: entity.sourceList,
                caption: "Source",
                value: _newSource,
                onChange: (value) => _setSource(value, entity.entityId)
            )
        );
      }
      if (entity.state == EntityState.playing || entity.state == EntityState.paused) {
        children.add(
            ButtonBar(
              children: <Widget>[
                RaisedButton(
                  child: Text("Duplicate to"),
                  color: Colors.blue,
                  textColor: Colors.white,
                  onPressed: () => _duplicateTo(entity),
                ),
                RaisedButton(
                  child: Text("Switch to"),
                  color: Colors.blue,
                  textColor: Colors.white,
                  onPressed: () => _switchTo(entity),
                )
              ],
            )
        );
      }
    }
    return Column(
      children: children,
    );
  }

  void _duplicateTo(entity) {
    HomeAssistant().savedPlayerPosition = entity.getActualPosition().toInt();
    Navigator.of(context).pushNamed("/play-media", arguments: {
        "url": entity.attributes["media_content_id"],
        "type": entity.attributes["media_content_type"]
      });
  }

  void _switchTo(entity) {
    HomeAssistant().sendFromPlayerId = entity.entityId;
    _duplicateTo(entity);
  }

}