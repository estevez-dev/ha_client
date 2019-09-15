part of '../../../main.dart';

class MediaPlayerProgressBar extends StatefulWidget {
  @override
  _MediaPlayerProgressBarState createState() => _MediaPlayerProgressBarState();
}

class _MediaPlayerProgressBarState extends State<MediaPlayerProgressBar> {

  Timer _timer;

  @override
  initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final EntityModel entityModel = EntityModel.of(context);
    final MediaPlayerEntity entity = entityModel.entityWrapper.entity;
    double progress;
    int currentPosition;
    if (entity.canCalculateActualPosition()) {
      currentPosition = entity.getActualPosition().toInt();
      progress = (currentPosition <= entity.durationSeconds) ? currentPosition / entity.durationSeconds : 100;
    } else {
      progress = 0;
    }
    return LinearProgressIndicator(
      value: progress,
      backgroundColor: Colors.black45,
      valueColor: AlwaysStoppedAnimation<Color>(EntityColor.stateColor(EntityState.on)),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

}