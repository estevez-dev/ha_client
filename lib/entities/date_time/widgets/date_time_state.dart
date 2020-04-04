part of '../../../main.dart';

class DateTimeStateWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final entityModel = EntityModel.of(context);
    final DateTimeEntity entity = entityModel.entityWrapper.entity;
    return Padding(
        padding: EdgeInsets.fromLTRB(0.0, 0.0, Sizes.rightWidgetPadding, 0.0),
        child: GestureDetector(
          child: Text("${entity.formattedState}",
              textAlign: TextAlign.right
            ),
          onTap: () => _handleStateTap(context, entity),
        ));
  }

  void _handleStateTap(BuildContext context, DateTimeEntity entity) {
    if (entity.hasDate) {
      _showDatePicker(context, entity).then((date) {
        if (date != null) {
          if (entity.hasTime) {
            _showTimePicker(context, entity).then((time) {
              entity.setNewState({
                "date": "${formatDate(date, [yyyy, '-', mm, '-', dd])}",
                "time":
                "${formatDate(DateTime(1970, 1, 1, time.hour, time.minute), [
                  HH,
                  ':',
                  nn
                ])}"
              });
            });
          } else {
            entity.setNewState({
              "date": "${formatDate(date, [yyyy, '-', mm, '-', dd])}"
            });
          }
        }
      });
    } else if (entity.hasTime) {
      _showTimePicker(context, entity).then((time) {
        if (time != null) {
          entity.setNewState({
            "time":
            "${formatDate(DateTime(1970, 1, 1, time.hour, time.minute), [
              HH,
              ':',
              nn
            ])}"
          });
        }
      });
    } else {
      Logger.w( "${entity.entityId} has no date and no time");
    }
  }

  Future _showDatePicker(BuildContext context, DateTimeEntity entity) {
    return showDatePicker(
        context: context,
        initialDate: entity.dateTimeState,
        firstDate: DateTime(1970),
        lastDate: DateTime(2037) //Unix timestamp will finish at Jan 19, 2038
    );
  }

  Future _showTimePicker(BuildContext context, DateTimeEntity entity) {
    return showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(entity.dateTimeState));
  }
}