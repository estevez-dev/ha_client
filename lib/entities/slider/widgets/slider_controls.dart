part of '../../../main.dart';

class SliderControlsWidget extends StatefulWidget {

  SliderControlsWidget({Key key}) : super(key: key);

  @override
  _SliderControlsWidgetState createState() => _SliderControlsWidgetState();
}

class _SliderControlsWidgetState extends State<SliderControlsWidget> {
  int _multiplier = 1;
  double _newValue;
  bool _changedHere = false;

  void setNewState(newValue, domain, entityId) {
    setState(() {
      _newValue = newValue;
      _changedHere = true;
    });
    ConnectionManager().callService(
      domain: domain,
      service: "set_value",
      entityId: entityId,
      data: {"value": "${newValue.toString()}"}
    );
  }

  @override
  Widget build(BuildContext context) {
    final entityModel = EntityModel.of(context);
    final SliderEntity entity = entityModel.entityWrapper.entity;
    if (entity.valueStep < 1) {
      _multiplier = 10;
    } else if (entity.valueStep < 0.1) {
      _multiplier = 100;
    }
    if (!_changedHere) {
      _newValue = entity.doubleState;
    } else {
      _changedHere = false;
    }
    Widget slider = UniversalSlider(
      min: entity.minValue * _multiplier,
      max: entity.maxValue * _multiplier,
      value: (_newValue <= entity.maxValue) &&
          (_newValue >= entity.minValue)
          ? _newValue * _multiplier
          : entity.minValue * _multiplier,
      onChanged: (value) {
        setState(() {
          _newValue = (value.roundToDouble() / _multiplier);
          _changedHere = true;
        });
      },
      onChangeEnd: (value) {
        setNewState(value.roundToDouble() / _multiplier, entity.domain, entity.entityId);
      },
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          "$_newValue",
          style: Theme.of(context).textTheme.display1.copyWith(
            color: Colors.blue
          ),
        ),
        slider
      ],
    );
  }
}