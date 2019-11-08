part of '../../../main.dart';

class LightControlsWidget extends StatefulWidget {

  @override
  _LightControlsWidgetState createState() => _LightControlsWidgetState();

}

class _LightControlsWidgetState extends State<LightControlsWidget> {

  int _tmpBrightness;
  int _tmpWhiteValue;
  int _tmpColorTemp = 0;
  HSVColor _tmpColor = HSVColor.fromAHSV(1.0, 30.0, 0.0, 1.0);
  bool _changedHere = false;
  String _tmpEffect;

  void _resetState(LightEntity entity) {
    _tmpBrightness = entity.brightness ?? 1;
    _tmpWhiteValue = entity.whiteValue ?? 0;
    _tmpColorTemp = entity.colorTemp ?? entity.minMireds?.toInt();
    _tmpColor = entity.color ?? _tmpColor;
    _tmpEffect = entity.effect;
  }

  void _setBrightness(LightEntity entity, double value) {
    setState(() {
      _tmpBrightness = value.round();
      _changedHere = true;
      ConnectionManager().callService(
          domain: entity.domain,
          service: "turn_on",
          entityId: entity.entityId,
          data: {"brightness": _tmpBrightness}
        );
    });
  }

  void _setWhiteValue(LightEntity entity, double value) {
    setState(() {
      _tmpWhiteValue = value.round();
      _changedHere = true;
      ConnectionManager().callService(
            domain: entity.domain,
            service: "turn_on",
            entityId: entity.entityId,
            data: {"white_value": _tmpWhiteValue}
          );

    });
  }

  void _setColorTemp(LightEntity entity, double value) {
    setState(() {
      _tmpColorTemp = value.round();
      _changedHere = true;
      ConnectionManager().callService(
          domain: entity.domain,
          service: "turn_on",
          entityId: entity.entityId,
          data: {"color_temp": _tmpColorTemp}
        );
    });
  }

  void _setColor(LightEntity entity, HSVColor color) {
    setState(() {
      _tmpColor = color;
      _changedHere = true;
      ConnectionManager().callService(
        domain: entity.domain,
        service: "turn_on",
        entityId: entity.entityId,
        data: {"hs_color": [color.hue, color.saturation*100]}
      );
    });
  }

  void _setEffect(LightEntity entity, String value) {
    setState(() {
      _tmpEffect = value;
      _changedHere = true;
      if (_tmpEffect != null) {
        ConnectionManager().callService(
            domain: entity.domain,
            service: "turn_on",
            entityId: entity.entityId,
            data: {"effect": "$value"}
          );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final entityModel = EntityModel.of(context);
    final LightEntity entity = entityModel.entityWrapper.entity;
    if (!_changedHere) {
      _resetState(entity);
    } else {
      _changedHere = false;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        _buildBrightnessControl(entity),
        _buildWhiteValueControl(entity),
        _buildColorTempControl(entity),
        _buildColorControl(entity),
        _buildEffectControl(entity)
      ],
    );
  }

  Widget _buildBrightnessControl(LightEntity entity) {
    if (entity.supportBrightness) {
      double val;
      if (_tmpBrightness != null) {
        if (_tmpBrightness > 255) {
          val = 255;
        } else if (_tmpBrightness < 1) {
          val = 1;
        } else {
          val = _tmpBrightness.toDouble();
        }
      } else {
        val = 1;
      }
      return UniversalSlider(
        onChanged: (value) {
          setState(() {
            _changedHere = true;
            _tmpBrightness = value.round();
          });
        },
        min: 1.0,
        max: 255.0,
        onChangeEnd: (value) => _setBrightness(entity, value),
        value: val,
        leading: Icon(Icons.brightness_5),
        title: "Brightness",
      );
    } else {
      return Container(width: 0.0, height: 0.0);
    }
  }

  Widget _buildWhiteValueControl(LightEntity entity) {
    if ((entity.supportWhiteValue) && (_tmpWhiteValue != null)) {
      return UniversalSlider(
        onChanged: (value) {
          setState(() {
            _changedHere = true;
            _tmpWhiteValue = value.round();
          });
        },
        min: 0.0,
        max: 255.0,
        onChangeEnd: (value) => _setWhiteValue(entity, value),
        value: _tmpWhiteValue == null ? 0.0 : _tmpWhiteValue.toDouble(),
        leading: Icon(MaterialDesignIcons.getIconDataFromIconName("mdi:file-word-box")),
        title: "White",
      );
    } else {
      return Container(width: 0.0, height: 0.0);
    }
  }

  Widget _buildColorTempControl(LightEntity entity) {
    if (entity.supportColorTemp) {
      double val;
      if (_tmpColorTemp != null) {
        if (_tmpColorTemp > entity.maxMireds) {
          val = entity.maxMireds;
        } else if (_tmpColorTemp < entity.minMireds) {
          val = entity.minMireds;
        } else {
          val = _tmpColorTemp.toDouble();
        }
      } else {
        val = entity.minMireds;
      }
      return UniversalSlider(
        title: "Color temperature",
        leading: Text("Cold", style: TextStyle(color: Colors.lightBlue),),
        value:  val,
        onChangeEnd: (value) => _setColorTemp(entity, value),
        max: entity.maxMireds,
        min: entity.minMireds,
        onChanged: (value) {
          setState(() {
            _changedHere = true;
            _tmpColorTemp = value.round();
          });
        },
        closing: Text("Warm", style: TextStyle(color: Colors.amberAccent),),
      );
    } else {
      return Container(width: 0.0, height: 0.0);
    }
  }

  Widget _buildColorControl(LightEntity entity) {
    if (entity.supportColor) {
      HSVColor savedColor = HomeAssistant().savedColor;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          LightColorPicker(
            color: _tmpColor,
            onColorSelected: (color) => _setColor(entity, color),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              FlatButton(
                color: _tmpColor.toColor(),
                child: Text('Copy color'),
                onPressed: _tmpColor == null ? null : () {
                  setState(() {
                    HomeAssistant().savedColor = _tmpColor;
                  });
                },
              ),
              FlatButton(
                color: savedColor?.toColor() ?? Colors.transparent,
                child: Text('Paste color'),
                onPressed: savedColor == null ? null : () {
                  _setColor(entity, savedColor);
                },
              )
            ],
          )
        ],
      );
    } else {
      return Container(width: 0.0, height: 0.0);
    }
  }

  Widget _buildEffectControl(LightEntity entity) {
    if ((entity.supportEffect) && (entity.effectList != null)) {
      List<String> list = List.from(entity.effectList);
      if (_tmpEffect!= null && !list.contains(_tmpEffect)) {
        list.insert(0, _tmpEffect);
      }
      return ModeSelectorWidget(
          onChange: (effect) => _setEffect(entity, effect),
          caption: "Effect",
          options: list,
          value: _tmpEffect
      );
    } else {
      return Container(width: 0.0, height: 0.0);
    }
  }


}