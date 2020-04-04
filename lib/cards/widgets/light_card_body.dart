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

  }
}