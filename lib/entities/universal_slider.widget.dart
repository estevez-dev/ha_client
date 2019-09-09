part of '../main.dart';

class UniversalSlider extends StatelessWidget {

  final onChanged;
  final onChangeEnd;
  final Widget leading;
  final Widget closing;
  final String title;
  final double min;
  final double max;
  final double value;
  final EdgeInsets padding;

  const UniversalSlider({Key key, this.onChanged, this.onChangeEnd, this.leading, this.closing, this.title, this.min, this.max, this.value, this.padding: const EdgeInsets.fromLTRB(Sizes.leftWidgetPadding, Sizes.rowPadding, Sizes.rightWidgetPadding, 0.0)}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List <Widget> row = [];
    if (leading != null) {
      row.add(leading);
    }
    row.add(
        Flexible(
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: (value) => onChanged(value),
            onChangeEnd: (value) => onChangeEnd(value),
          ),
        )
    );
    if (closing != null) {
      row.add(closing);
    }
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(height: Sizes.rowPadding,),
          Text(
            "$title",
            style: TextStyle(fontSize: Sizes.stateFontSize),
          ),
          Container(height: Sizes.rowPadding,),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: row,
          ),
          Container(height: Sizes.rowPadding,)
        ],
      ),
    );
  }

}