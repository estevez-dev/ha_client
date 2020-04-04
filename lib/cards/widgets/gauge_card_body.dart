part of '../../main.dart';

class GaugeCardBody extends StatefulWidget {

  final int min;
  final int max;
  final Map severity;

  GaugeCardBody({Key key, this.min, this.max, this.severity}) : super(key: key);

  @override
  _GaugeCardBodyState createState() => _GaugeCardBodyState();
}

class _GaugeCardBodyState extends State<GaugeCardBody> {

  List<charts.Series> seriesList;

  List<charts.Series<GaugeSegment, String>> _createData(double value) {
    double fixedValue;
    if (value > widget.max) {
      fixedValue = widget.max.toDouble();
    } else if (value < widget.min) {
      fixedValue = widget.min.toDouble();
    } else {
      fixedValue = value;
    }
    double toShow = ((fixedValue - widget.min) / (widget.max - widget.min)) * 100;
    Color mainColor;
    if (widget.severity != null) {
      if (widget.severity["red"] is int && fixedValue >= widget.severity["red"]) {
        mainColor = Colors.red;
      } else if (widget.severity["yellow"] is int && fixedValue >= widget.severity["yellow"]) {
        mainColor = Colors.amber;
      } else {
        mainColor = Colors.green;
      }
    } else {
      mainColor = Colors.green;
    }
    final data = [
      GaugeSegment('Main', toShow, mainColor),
      GaugeSegment('Rest', 100 - toShow, Colors.black45),
    ];

    return [
      charts.Series<GaugeSegment, String>(
        id: 'Segments',
        domainFn: (GaugeSegment segment, _) => segment.segment,
        measureFn: (GaugeSegment segment, _) => segment.value,
        colorFn: (GaugeSegment segment, _) => segment.color,
        // Set a label accessor to control the text of the arc label.
        labelAccessorFn: (GaugeSegment segment, _) =>
        segment.segment == 'Main' ? '${segment.value}' : null,
        data: data,
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    EntityWrapper entityWrapper = EntityModel.of(context).entityWrapper;

    return InkWell(
      onTap: () => entityWrapper.handleTap(),
      onLongPress: () => entityWrapper.handleHold(),
      onDoubleTap: () => entityWrapper.handleDoubleTap(),
      child: AspectRatio(
          aspectRatio: 1.5,
          child: Stack(
              fit: StackFit.expand,
              overflow: Overflow.clip,
              children: [
                LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      double verticalOffset;
                      if(constraints.maxWidth > 150.0) {
                        verticalOffset = 0.2;
                      } else if (constraints.maxWidth > 100.0)  {
                        verticalOffset = 0.3;
                      } else {
                        verticalOffset = 0.3;
                      }
                      return FractionallySizedBox(
                        heightFactor: 2,
                        widthFactor: 1,
                        alignment: FractionalOffset(0,verticalOffset),
                        child: charts.PieChart(
                          _createData(entityWrapper.entity.doubleState),
                          animate: false,
                          defaultRenderer: charts.ArcRendererConfig(
                            arcRatio: 0.4,
                            startAngle: pi,
                            arcLength: pi,
                          ),
                        ),
                      );
                    }
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints constraints) {
                        double fontSize = constraints.maxHeight / 7;
                        return Padding(
                          padding: EdgeInsets.only(bottom: 2*fontSize),
                          child: SimpleEntityState(
                            //textAlign: TextAlign.center,
                            expanded: false,
                            maxLines: 1,
                            bold: true,
                            textAlign: TextAlign.center,
                            padding: EdgeInsets.all(0.0),
                            fontSize: fontSize,
                            //padding: EdgeInsets.only(top: Sizes.rowPadding),
                          ),
                        );
                      }
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints constraints) {
                        double fontSize = constraints.maxHeight / 7;
                        return Padding(
                          padding: EdgeInsets.only(bottom: fontSize),
                          child: EntityName(
                            textStyle: Theme.of(context).textTheme.body1.copyWith(
                              fontSize: fontSize
                            ),
                            maxLines: 1,
                            padding: EdgeInsets.all(0.0),
                            textAlign: TextAlign.center,
                            textOverflow: TextOverflow.ellipsis,
                          ),
                        );
                      }
                  ),
                )
              ]
          )
      ),
    );
  }
}

class GaugeSegment {
  final String segment;
  final double value;
  final charts.Color color;

  GaugeSegment(this.segment, this.value, Color color)
      : this.color = charts.Color(
      r: color.red, g: color.green, b: color.blue, a: color.alpha);
}