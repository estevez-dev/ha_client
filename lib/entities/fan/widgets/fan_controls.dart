part of '../../../main.dart';

class FanControlsWidget extends StatefulWidget {

  @override
  _FanControlsWidgetState createState() => _FanControlsWidgetState();

}

class _FanControlsWidgetState extends State<FanControlsWidget> {

  bool _tmpOscillate;
  bool _tmpDirectionForward;
  bool _changedHere = false;
  String _tmpSpeed;

  void _resetState(FanEntity entity) {
    _tmpOscillate = entity.attributes["oscillating"] ?? false;
    _tmpDirectionForward = entity.attributes["direction"] == "forward";
    _tmpSpeed = entity.attributes["speed"];
  }

  void _setOscillate(FanEntity entity, bool oscillate) {
    setState(() {
      _tmpOscillate = oscillate;
      _changedHere = true;
      ConnectionManager().callService(
          "fan", "oscillate", entity.entityId,
          {"oscillating": oscillate});
    });
  }

  void _setDirection(FanEntity entity, bool forward) {
    setState(() {
      _tmpDirectionForward = forward;
      _changedHere = true;
      ConnectionManager().callService(
          "fan", "set_direction", entity.entityId,
          {"direction": forward ? "forward" : "reverse"});
    });
  }

  void _setSpeed(FanEntity entity, String value) {
    setState(() {
      _tmpSpeed = value;
      _changedHere = true;
      ConnectionManager().callService(
            "fan", "set_speed", entity.entityId,
            {"speed": value});
    });
  }

  @override
  Widget build(BuildContext context) {
    final entityModel = EntityModel.of(context);
    final FanEntity entity = entityModel.entityWrapper.entity;
    if (!_changedHere) {
      _resetState(entity);
    } else {
      _changedHere = false;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        _buildSpeedControl(entity),
        _buildOscillateControl(entity),
        _buildDirectionControl(entity)
      ],
    );
  }

  Widget _buildSpeedControl(FanEntity entity) {
    if (entity.supportSetSpeed && entity.speedList != null && entity.speedList.isNotEmpty) {
      return ModeSelectorWidget(
        onChange: (effect) => _setSpeed(entity, effect),
        caption: "Speed",
        options: entity.speedList,
        value: _tmpSpeed
      );
    } else {
      return Container(width: 0.0, height: 0.0);
    }
  }

  Widget _buildOscillateControl(FanEntity entity) {
    if (entity.supportOscillate) {
      return ModeSwitchWidget(
          onChange: (value) => _setOscillate(entity, value),
          caption: "Oscillate",
          value: _tmpOscillate,
          expanded: false,
      );
    } else {
      return Container(width: 0.0, height: 0.0);
    }
  }

  Widget _buildDirectionControl(FanEntity entity) {
    if (entity.supportDirection) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            onPressed: _tmpDirectionForward ?
              () => _setDirection(entity, false) :
              null,
            icon: Icon(Icons.rotate_left),
          ),
          IconButton(
            onPressed: !_tmpDirectionForward ?
              () => _setDirection(entity, true) :
              null,
            icon: Icon(Icons.rotate_right),
          ),
        ],
      );
    } else {
      return Container(width: 0.0, height: 0.0);
    }
  }


}