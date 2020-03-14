part of '../../main.dart';

class LightCardBody extends StatefulWidget {

  final int min;
  final int max;
  final Map severity;

  LightCardBody({Key key, this.min, this.max, this.severity}) : super(key: key);

  @override
  _LightCardBodyState createState() => _LightCardBodyState();
}

class _LightCardBodyState extends State<LightCardBody> {

  @override
  Widget build(BuildContext context) {
    EntityWrapper entityWrapper = EntityModel.of(context).entityWrapper;
    LightEntity entity = entityWrapper.entity;
    Logger.d("Light brightness: ${entity.brightness}");

    return FractionallySizedBox(
      widthFactor: 0.5,
      child: Container(
        //color: Colors.redAccent,
        child: SingleCircularSlider(
            255,
            entity.brightness ?? 0,
          baseColor: Colors.white,
          handlerColor: Colors.blue[200],
          selectionColor: Colors.blue[100],
        ),
      ),
    );

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
                            fontSize: fontSize,
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