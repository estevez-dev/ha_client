part of '../../../main.dart';

class TimerState extends StatefulWidget  {
  //final bool expanded;
  //final TextAlign textAlign;
  //final EdgeInsetsGeometry padding;
  //final int maxLines;

  const TimerState({Key key}) : super(key: key);

  @override
  _TimerStateState createState() => _TimerStateState();

}

class _TimerStateState extends State<TimerState> {

  Timer timer;
  Duration remaining = Duration(seconds: 0);

  void checkState(TimerEntity entity) {
    if (entity.state == EntityState.active) {
      //Logger.d("Timer is active");
      if (timer == null || !timer.isActive) {
        timer = Timer.periodic(Duration(seconds: 1), (timer) {
          setState(() {
            try {
              int passed = DateTime
                  .now()
                  .difference(entity.lastUpdatedTimestamp)
                  .inSeconds;
              remaining = Duration(seconds: entity.duration.inSeconds - passed);
            } catch (e, stacktrace) {
              Logger.e("Error calculating ${entity.entityId} remaining time: $e", stacktrace: stacktrace);
              remaining = Duration(seconds: 0);
            }
          });
        });
      }
    } else {
      timer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    EntityModel model = EntityModel.of(context);
    TimerEntity entity = model.entityWrapper.entity;
    checkState(entity);
    if (entity.state != EntityState.active) {
      return SimpleEntityState();
    } else {
      return SimpleEntityState(
        customValue: "${remaining.toString().split('.')[0]}",
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

}