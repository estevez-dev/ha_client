part of '../../main.dart';

class GaugeCardBody extends StatelessWidget {

  final int min;
  final int max;
  final Map severity;

  GaugeCardBody({Key key, this.min, this.max, this.severity}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    EntityWrapper entityWrapper = EntityModel.of(context).entityWrapper;
    double fixedValue;
    double value = entityWrapper.entity.doubleState;
    if (value > max) {
      fixedValue = max.toDouble();
    } else if (value < min) {
      fixedValue = min.toDouble();
    } else {
      fixedValue = value;
    }
    
    List<GaugeRange> ranges;
    Color currentColor;
    if (severity != null && severity["green"] is int && severity["red"] is int && severity["yellow"] is int) {
      List<RangeContainer> rangesList = <RangeContainer>[
        RangeContainer(severity["green"], HAClientTheme().getGreenGaugeColor()),
        RangeContainer(severity["red"], HAClientTheme().getRedGaugeColor()),
        RangeContainer(severity["yellow"], HAClientTheme().getYellowGaugeColor())
      ];
      rangesList.sort((current, next) {
        if (current.startFrom > next.startFrom) {
          return 1;
        }
        if (current.startFrom < next.startFrom) {
          return -1;
        }
        return 0;
      });

      if (fixedValue < rangesList[1].startFrom) {
        currentColor = rangesList[0].color;
      } else if (fixedValue < rangesList[2].startFrom && fixedValue >= rangesList[1].startFrom) {
        currentColor = rangesList[1].color;
      } else {
        currentColor = rangesList[2].color;
      }

      ranges = [
        GaugeRange(
          startValue: rangesList[0].startFrom.toDouble(),
          endValue: rangesList[1].startFrom.toDouble(),
          color: rangesList[0].color.withOpacity(0.1),
          sizeUnit: GaugeSizeUnit.factor,
          endWidth: 0.3,
          startWidth: 0.3
        ),
        GaugeRange(
          startValue: rangesList[1].startFrom.toDouble(),
          endValue: rangesList[2].startFrom.toDouble(),
          color: rangesList[1].color.withOpacity(0.1),
          sizeUnit: GaugeSizeUnit.factor,
          endWidth: 0.3,
          startWidth: 0.3
        ),
        GaugeRange(
          startValue: rangesList[2].startFrom.toDouble(),
          endValue: max.toDouble(),
          color: rangesList[2].color.withOpacity(0.1),
          sizeUnit: GaugeSizeUnit.factor,
          endWidth: 0.3,
          startWidth: 0.3
        )
      ];
    }
    if (ranges == null) {
      currentColor = Theme.of(context).primaryColorDark;
      ranges = <GaugeRange>[
        GaugeRange(
          startValue: min.toDouble(),
          endValue: max.toDouble(),
          color: Theme.of(context).primaryColorDark.withOpacity(0.1),
          sizeUnit: GaugeSizeUnit.factor,
          endWidth: 0.3,
          startWidth: 0.3,
        )
      ];
    }

    return InkWell(
      onTap: () => entityWrapper.handleTap(),
      onLongPress: () => entityWrapper.handleHold(),
      onDoubleTap: () => entityWrapper.handleDoubleTap(),
      child: AspectRatio(
        aspectRatio: 2,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            double fontSizeFactor;
            if (constraints.maxWidth > 300.0) {
              fontSizeFactor = 1.6;
            } else if (constraints.maxWidth > 150.0) {
              fontSizeFactor = 1;
            } else if (constraints.maxWidth > 100.0)  {
              fontSizeFactor = 0.6;
            } else {
              fontSizeFactor = 0.4;
            }
            return SfRadialGauge(
              axes: <RadialAxis>[
                RadialAxis(
                  maximum: max.toDouble(),
                  minimum: min.toDouble(),
                  showLabels: false,
                  useRangeColorForAxis: true,
                  showTicks: false,
                  canScaleToFit: true,
                  ranges: ranges,
                  axisLineStyle: AxisLineStyle(
                    thickness: 0.3,
                    thicknessUnit: GaugeSizeUnit.factor,
                    color: Colors.transparent
                  ),
                  annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                      angle: -90,
                      positionFactor: 1.3,
                      //verticalAlignment: GaugeAlignment.far,
                      widget: EntityName(
                        textStyle: Theme.of(context).textTheme.body1.copyWith(
                          fontSize: Theme.of(context).textTheme.body1.fontSize * fontSizeFactor
                        ),
                      ),
                    ),
                    GaugeAnnotation(
                      angle: 180,
                      positionFactor: 0,
                      verticalAlignment: GaugeAlignment.center,
                      widget: SimpleEntityState(
                        expanded: false,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        textStyle: Theme.of(context).textTheme.title.copyWith(
                          fontSize: Theme.of(context).textTheme.title.fontSize * fontSizeFactor,
                        ),
                      ),
                    )
                  ],
                  startAngle: 180,
                  endAngle: 0,
                  pointers: <GaugePointer>[
                    RangePointer(
                      value: fixedValue,
                      sizeUnit: GaugeSizeUnit.factor,
                      width: 0.3,
                      color: currentColor,
                      enableAnimation: true,
                      animationType: AnimationType.bounceOut,
                    )
                  ]
                )
              ],
            );
          },
        ),
      ),
    );
  }
  
}

class RangeContainer {
  final int startFrom;
  Color color;

  RangeContainer(this.startFrom, this.color);
}