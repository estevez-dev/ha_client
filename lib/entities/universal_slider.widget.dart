part of '../main.dart';

class UniversalSlider extends StatefulWidget {

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
  State<StatefulWidget> createState() {
    return UniversalSliderState();
  }

}

class UniversalSliderState extends State<UniversalSlider> {

  double _value;
  bool _changeStarted = false;

  @override
  void initState() {
    _value = widget.value;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List <Widget> row = [];
    if (widget.leading != null) {
      row.add(widget.leading);
    }
    row.add(
      Flexible(
        child: Slider(
          value: _value ?? math.max(widget.max ?? 100, _value ?? 0),
          min: widget.min ?? 0,
          max: widget.max ?? 100,
          onChangeStart: (_) {
            _changeStarted = true; 
          },
          onChanged: (value) {
            setState(() {
              _value = value;
            });
            widget.onChanged(value);
          },
          onChangeEnd: (value) {
            _changeStarted = false;
            Timer(Duration(milliseconds: 500), () {
              if (!_changeStarted) {
                setState(() {
                  _value = value;
                });
                widget.onChangeEnd(value);
              }
            });
          }
        ),
      )
    );
    if (widget.closing != null) {
      row.add(widget.closing);
    }
    return Padding(
      padding: widget.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(height: Sizes.rowPadding,),
          Text('${widget.title}'),
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