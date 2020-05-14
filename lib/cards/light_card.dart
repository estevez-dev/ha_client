part of '../main.dart';

class LightCard extends StatefulWidget {

  final LightCardData card;

  LightCard({Key key, this.card}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _LightCardState();
  }
}

class _LightCardState extends State<LightCard> {

  double _newBrightness;
  double _actualBrightness;
  bool _changedHere = false;

  @override
  void initState() {
    super.initState();
  }

  void _setBrightness(double value, LightEntity entity) {
    setState((){
      _newBrightness = value;
      _changedHere = true;
    });
    ConnectionManager().callService(
      domain: entity.domain,
      service: "turn_on",
      entityId: entity.entityId,
      data: {"brightness": value.round()}
    );
  }

  @override
  Widget build(BuildContext context) {
    EntityWrapper entityWrapper = widget.card.entity;
    LightEntity entity = entityWrapper.entity;
    if (entityWrapper.entity.statelessType == StatelessEntityType.missed) {
      return EntityModel(
        entityWrapper: widget.card.entity,
        child: MissedEntityWidget(),
        handleTap: false,
      );
    }
    entityWrapper.overrideName = widget.card.name ??
        entityWrapper.displayName;
    entityWrapper.overrideIcon = widget.card.icon ??
        entityWrapper.icon;
    _actualBrightness = (entity.brightness ?? 0).toDouble();
    if (!_changedHere) {
      _newBrightness = _actualBrightness;
    } else {
      _changedHere = false;
    }
    Color lightColor = entity.color?.toColor();
    Color color;
    if (lightColor != null && lightColor != Colors.white) {
      color = lightColor;
    } else {
      color = HAClientTheme().getOnStateColor(context);
    }
    return CardWrapper(
      padding: EdgeInsets.all(4),
      child: EntityModel(
        entityWrapper: entityWrapper,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ConstrainedBox(
              constraints: BoxConstraints.loose(Size(200, 200)),
              child: AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    SfRadialGauge(
                      axes: <RadialAxis>[
                        RadialAxis(
                          onAxisTapped: (val) {
                            _setBrightness(val, entity);
                          },
                          maximum: 255,
                          minimum: 0,
                          showLabels: false,
                          showTicks: false,
                          axisLineStyle: AxisLineStyle(
                            thickness: 0.05,
                            thicknessUnit: GaugeSizeUnit.factor,
                            color: HAClientTheme().getDisabledStateColor(context)
                          ),
                          pointers: <GaugePointer>[
                            RangePointer(
                              value: _actualBrightness,
                              sizeUnit: GaugeSizeUnit.factor,
                              width: 0.05,
                              color: color,
                              enableAnimation: true,
                              animationType: AnimationType.bounceOut,
                            ),
                            MarkerPointer(
                              value: _newBrightness,
                              markerType: MarkerType.circle,
                              markerHeight: 20,
                              markerWidth: 20,
                              enableDragging: true,
                              onValueChangeEnd: (val) {
                                _setBrightness(val, entity);
                              },
                              color: HAClientTheme().getColorByEntityState(entity.state, context)
                              //enableAnimation: true,
                              //animationType: AnimationType.bounceOut,
                            )
                          ]
                        )
                      ],
                    ),
                    FractionallySizedBox(
                      heightFactor: 0.4,
                      widthFactor: 0.4,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: InkResponse(
                          onTap: () => entityWrapper.handleTap(),
                          onLongPress: () => entityWrapper.handleHold(),
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: EntityIcon(
                              showBadge: false,
                              padding: EdgeInsets.all(0)
                            )
                          )
                        ) 
                      )
                    )
                  ],
                )
              )
            ),
            EntityName(
              padding: EdgeInsets.all(0),
              wordsWrap: true,
              maxLines: 3,
              textOverflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            )
          ],
        ),
        handleTap: true
      )
    );
  }
}
  