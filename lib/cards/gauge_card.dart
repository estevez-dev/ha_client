part of '../main.dart';

class GaugeCard extends StatelessWidget {

  final GaugeCardData card;

  GaugeCard({Key key, this.card}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    EntityWrapper entityWrapper = card.entity;
    if (entityWrapper.entity.statelessType == StatelessEntityType.missed) {
      return EntityModel(
        entityWrapper: card.entity,
        child: MissedEntityWidget(),
        handleTap: false,
      );
    }
    entityWrapper.overrideName = card.name ??
        entityWrapper.displayName;
    entityWrapper.unitOfMeasurementOverride = card.unit ??
        entityWrapper.unitOfMeasurement;
    double fixedValue;
    double value = entityWrapper.entity.doubleState;
    if (value > card.max) {
      fixedValue = card.max.toDouble();
    } else if (value < card.min) {
      fixedValue = card.min.toDouble();
    } else {
      fixedValue = value;
    }
    
    List<GaugeRange> ranges;
    Color currentColor;
    if (card.severity != null && card.severity["green"] is int && card.severity["red"] is int && card.severity["yellow"] is int) {
      List<RangeContainer> rangesList = <RangeContainer>[
        RangeContainer(card.severity["green"], HAClientTheme().getGreenGaugeColor()),
        RangeContainer(card.severity["red"], HAClientTheme().getRedGaugeColor()),
        RangeContainer(card.severity["yellow"], HAClientTheme().getYellowGaugeColor())
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
          endValue: card.max.toDouble(),
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
          startValue: card.min.toDouble(),
          endValue: card.max.toDouble(),
          color: Theme.of(context).primaryColorDark.withOpacity(0.1),
          sizeUnit: GaugeSizeUnit.factor,
          endWidth: 0.3,
          startWidth: 0.3,
        )
      ];
    }

    return CardWrapper(
      padding: EdgeInsets.all(4),
      child: EntityModel(
        entityWrapper: entityWrapper,
        child: InkWell(
          onTap: () => entityWrapper.handleTap(),
          onLongPress: () => entityWrapper.handleHold(),
          onDoubleTap: () => entityWrapper.handleDoubleTap(),
          child: AspectRatio(
            aspectRatio: 1.8,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                SfRadialGauge(
                  axes: <RadialAxis>[
                    RadialAxis(
                      maximum: card.max.toDouble(),
                      minimum: card.min.toDouble(),
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
                ),
                Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      flex: 8,
                      fit: FlexFit.tight,
                      child: Container()
                    ),
                    Flexible(
                      flex: 6,
                      fit: FlexFit.tight,
                      child: FractionallySizedBox(
                        widthFactor: 0.4,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          alignment: Alignment.bottomCenter,
                          child: SimpleEntityState(
                            padding: EdgeInsets.all(0),
                            expanded: false,
                            maxLines: 1,
                            textAlign: TextAlign.center
                          ),
                        )
                      )
                    ),
                    Flexible(
                      flex: 3,
                      fit: FlexFit.tight,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: EntityName(
                          padding: EdgeInsets.all(0),
                          textStyle: Theme.of(context).textTheme.subhead
                        ),
                      )
                    ),  
                  ],
                )
              ],
            )
          ),
        ),
        handleTap: true
      )
    );
  }
  
}

class RangeContainer {
  final int startFrom;
  Color color;

  RangeContainer(this.startFrom, this.color);
}