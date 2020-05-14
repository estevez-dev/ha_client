part of '../main.dart';

class UniversalSlider extends StatefulWidget {

  final Function onChanged;
  final Function onChangeEnd;
  final Function onChangeStart;
  final Widget leading;
  final Widget closing;
  final String title;
  final double min;
  final Color activeColor;
  final double max;
  final double value;
  final int divisions;
  final EdgeInsets padding;

  const UniversalSlider({Key key, this.onChanged, this.onChangeStart, this.activeColor, this.divisions, this.onChangeEnd, this.leading, this.closing, this.title, this.min, this.max, this.value, this.padding: const EdgeInsets.fromLTRB(Sizes.leftWidgetPadding, Sizes.rowPadding, Sizes.rightWidgetPadding, 0.0)}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return UniversalSliderState();
  }

}

class UniversalSliderState extends State<UniversalSlider> {

  double _value;
  bool _changeStarted = false;
  bool _changedHere = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List <Widget> row = [];
    List <Widget> col = [];
    if (!_changedHere) {
      _value = widget.value;
    } else {
      _changedHere = false;
    }
    if (widget.leading != null) {
      row.add(widget.leading);
    }
    row.add(
      Flexible(
        child: Slider(
          value: _value ?? math.max(widget.max ?? 100, _value ?? 0),
          min: widget.min ?? 0,
          max: widget.max ?? 100,
          activeColor: widget.activeColor,
          onChangeStart: (value) {
            _changeStarted = true;
            widget.onChangeStart?.call(value); 
          },
          divisions: widget.divisions,
          onChanged: (value) {
            setState(() {
              _value = value;
              _changedHere = true;
            });
            widget.onChanged?.call(value);
          },
          onChangeEnd: (value) {
            _changeStarted = false;
            setState(() {
              _value = value;
              _changedHere = true;
            });
            Timer(Duration(milliseconds: 500), () {
              if (!_changeStarted) {
                widget.onChangeEnd?.call(value);
              }
            });
          }
        ),
      )
    );
    if (widget.closing != null) {
      row.add(widget.closing);
    }
    if (widget.title != null) {
      col.addAll(<Widget>[
        Container(height: Sizes.rowPadding,),
        Text('${widget.title}'),
      ]);
    }
    col.addAll(<Widget>[
      Container(height: Sizes.rowPadding,),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: row,
      ),
      Container(height: Sizes.rowPadding,)
    ]);
    return Padding(
      padding: widget.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: col,
      ),
    );
  }
}