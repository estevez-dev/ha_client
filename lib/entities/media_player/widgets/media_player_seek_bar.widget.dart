part of '../../../main.dart';

class MediaPlayerSeekBar extends StatefulWidget {
  @override
  _MediaPlayerSeekBarState createState() => _MediaPlayerSeekBarState();
}

class _MediaPlayerSeekBarState extends State<MediaPlayerSeekBar> {

  Timer _timer;
  bool _seekStarted = false;
  bool _changedHere = false;
  double _currentPosition = 0;
  int _savedPosition = 0;

  @override
  initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      if (!_seekStarted && !_changedHere) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final EntityModel entityModel = EntityModel.of(context);
    final MediaPlayerEntity entity = entityModel.entityWrapper.entity;

    if (entity.canCalculateActualPosition() && entity.state != EntityState.idle) {
      if (HomeAssistant().sendToPlayerId == entity.entityId  && HomeAssistant().savedPlayerPosition != null) {
        _savedPosition = HomeAssistant().savedPlayerPosition;
        HomeAssistant().savedPlayerPosition = null;
        HomeAssistant().sendToPlayerId = null;
      }
      if (entity.state == EntityState.playing && !_seekStarted &&
          !_changedHere) {
        _currentPosition = entity.getActualPosition();
      } else if (entity.state == EntityState.paused) {
        _currentPosition = entity.positionSeconds.toDouble();
      } else if (_changedHere) {
        _changedHere = false;
      }
      List<Widget> buttons = [];
      if (_savedPosition > 0) {
        buttons.add(
            RaisedButton(
              child: Text("Jump to ${Duration(seconds: _savedPosition).toString().split('.')[0]}"),
              color: Theme.of(context).accentColor,
              onPressed: () {
                ConnectionManager().callService(
                    domain: "media_player",
                    service: "media_seek",
                    entityId: entity.entityId,
                    data: {"seek_position": _savedPosition}
                );
                setState(() {
                  _savedPosition = 0;
                });
              },
            )
        );
      }
      return Padding(
        padding: EdgeInsets.fromLTRB(Sizes.leftWidgetPadding, 20, Sizes.rightWidgetPadding, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Text("00:00"),
                Expanded(
                  child: Text(
                    "${Duration(seconds: _currentPosition.toInt()).toString().split(".")[0]}",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.title.copyWith(
                      color: Colors.blue
                    )
                  ),
                ),
                Text("${Duration(seconds: entity.durationSeconds).toString().split(".")[0]}")
              ],
            ),
            UniversalSlider(
              min: 0,
              activeColor: Theme.of(context).accentColor,
              max: entity.durationSeconds.toDouble(),
              value: _currentPosition,
              onChangeStart: (val) {
                _seekStarted = true;
              },
              onChanged: (val) {
                setState(() {
                  _currentPosition = val;
                });
              },
              onChangeEnd: (val) {
                _seekStarted = false;
                Timer(Duration(milliseconds: 500), () {
                  if (!_seekStarted) {
                    ConnectionManager().callService(
                        domain: "media_player",
                        service: "media_seek",
                        entityId: entity.entityId,
                        data: {"seek_position": val}
                    );
                    setState(() {
                      _changedHere = true;
                      _currentPosition = val;
                    });
                  }
                });
              },
            ),
            ButtonBar(
              children: buttons,
            )
          ],
        ),
      );
    } else {
      return Container(width: 0, height: 0,);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

}