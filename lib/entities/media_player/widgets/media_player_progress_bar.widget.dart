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
    DateTime lastUpdated = DateTime.tryParse("${entity.attributes["media_position_updated_at"]}")?.toLocal();
    if (lastUpdated != null) {
      Duration duration = Duration(seconds: entity._getIntAttributeValue("media_duration") ?? 1);
      Duration position = Duration(seconds: entity._getIntAttributeValue("media_position") ?? 0);
      int currentPosition = position.inSeconds;
      int differenceInSeconds = DateTime
          .now()
          .difference(lastUpdated)
          .inSeconds;
      currentPosition = currentPosition + differenceInSeconds;
      progress = (currentPosition <= duration.inSeconds) ? currentPosition / duration.inSeconds : 100;
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