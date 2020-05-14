part of '../main.dart';

class LightCard extends StatelessWidget {

  final LightCardData card;

  LightCard({Key key, this.card}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    EntityWrapper entityWrapper = card.entity;
    LightEntity entity = entityWrapper.entity;
    if (entityWrapper.entity.statelessType == StatelessEntityType.missed) {
      return EntityModel(
        entityWrapper: card.entity,
        child: MissedEntityWidget(),
        handleTap: false,
      );
    }
    entityWrapper.overrideName = card.name ??
        entityWrapper.displayName;
    entityWrapper.overrideIcon = card.icon ??
        entityWrapper.icon;
    double value = (entity.brightness ?? 0).toDouble();

    return CardWrapper(
      padding: EdgeInsets.all(4),
      child: EntityModel(
        entityWrapper: entityWrapper,
        child: AspectRatio(
          aspectRatio: 1.8,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              SfRadialGauge(
                axes: <RadialAxis>[
                  RadialAxis(
                    maximum: 255,
                    minimum: 0,
                    showLabels: false,
                    showTicks: false,
                    canScaleToFit: true,
                    axisLineStyle: AxisLineStyle(
                      thickness: 0.05,
                      thicknessUnit: GaugeSizeUnit.factor,
                      color: HAClientTheme().getDisabledStateColor(context)
                    ),
                    pointers: <GaugePointer>[
                      /*RangePointer(
                        value: value,
                        sizeUnit: GaugeSizeUnit.factor,
                        width: 0.05,
                        color: HAClientTheme().getOnStateColor(context),
                        enableAnimation: true,
                        animationType: AnimationType.bounceOut,
                      ),*/
                      MarkerPointer(
                        value: value,
                        markerType: MarkerType.circle,
                        markerHeight: 20,
                        markerWidth: 20,
                        enableDragging: true,
                        onValueChangeStart: (_) {
                          Logger.d('Value change start');
                        },
                        onValueChanging: (args) {
                          Logger.d('Value changing: ${args.value}');
                        },
                        color: HAClientTheme().getOnStateColor(context),
                        enableAnimation: true,
                        animationType: AnimationType.bounceOut,
                      )
                    ]
                  )
                ],
              ),
            ],
          )
        ),
        handleTap: true
      )
    );
  }
  
}