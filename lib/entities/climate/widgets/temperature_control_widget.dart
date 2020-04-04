part of '../../../main.dart';

class TemperatureControlWidget extends StatelessWidget {
  final double value;
  final bool active;
  final onInc;
  final onDec;

  TemperatureControlWidget(
      {Key key,
        @required this.value,
        @required this.onInc,
        @required this.onDec,
        //this.fontSize,
        this.active: false
      })
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          "$value",
          style: active ? Theme.of(context).textTheme.display2 : Theme.of(context).textTheme.display1,
        ),
        Column(
          children: <Widget>[
            IconButton(
              icon: Icon(MaterialDesignIcons.getIconDataFromIconName(
                  'mdi:chevron-up')),
              iconSize: 30.0,
              onPressed: () => onInc(),
            ),
            IconButton(
              icon: Icon(MaterialDesignIcons.getIconDataFromIconName(
                  'mdi:chevron-down')),
              iconSize: 30.0,
              onPressed: () => onDec(),
            )
          ],
        )
      ],
    );
  }
}