part of '../../../main.dart';

class ClimateControlWidget extends StatefulWidget {

  ClimateControlWidget({Key key}) : super(key: key);

  @override
  _ClimateControlWidgetState createState() => _ClimateControlWidgetState();
}

class _ClimateControlWidgetState extends State<ClimateControlWidget> {

  bool _showPending = false;
  bool _changedHere = false;
  Timer _resetTimer;
  Timer _tempThrottleTimer;
  Timer _targetTempThrottleTimer;
  double _tmpTemperature = 0.0;
  double _tmpTargetLow = 0.0;
  double _tmpTargetHigh = 0.0;
  double _tmpTargetHumidity = 0.0;
  String _tmpHVACMode;
  String _tmpFanMode;
  String _tmpSwingMode;
  String _tmpPresetMode;
  //bool _tmpIsOff = false;
  bool _tmpAuxHeat = false;

  void _resetVars(ClimateEntity entity) {
    _tmpTemperature = entity.temperature;
    _tmpTargetHigh = entity.targetHigh;
    _tmpTargetLow = entity.targetLow;
    _tmpHVACMode = entity.state;
    _tmpFanMode = entity.fanMode;
    _tmpSwingMode = entity.swingMode;
    _tmpPresetMode = entity.presetMode;
    //_tmpIsOff = entity.isOff;
    _tmpAuxHeat = entity.auxHeat;
    _tmpTargetHumidity = entity.targetHumidity;

    _showPending = false;
    _changedHere = false;
  }

  void _temperatureUp(ClimateEntity entity) {
    _tmpTemperature = ((_tmpTemperature + entity.temperatureStep) <= entity.maxTemp) ? _tmpTemperature + entity.temperatureStep : entity.maxTemp;
    _setTemperature(entity);
  }

  void _temperatureDown(ClimateEntity entity) {
    _tmpTemperature = ((_tmpTemperature - entity.temperatureStep) >= entity.minTemp) ? _tmpTemperature - entity.temperatureStep : entity.minTemp;
    _setTemperature(entity);
  }

  void _targetLowUp(ClimateEntity entity) {
    _tmpTargetLow = ((_tmpTargetLow + entity.temperatureStep) <= entity.maxTemp) ? _tmpTargetLow + entity.temperatureStep : entity.maxTemp;
    _setTargetTemp(entity);
  }

  void _targetLowDown(ClimateEntity entity) {
    _tmpTargetLow = ((_tmpTargetLow - entity.temperatureStep) >= entity.minTemp) ? _tmpTargetLow - entity.temperatureStep : entity.minTemp;
    _setTargetTemp(entity);
  }

  void _targetHighUp(ClimateEntity entity) {
    _tmpTargetHigh = ((_tmpTargetHigh + entity.temperatureStep) <= entity.maxTemp) ? _tmpTargetHigh + entity.temperatureStep : entity.maxTemp;
    _setTargetTemp(entity);
  }

  void _targetHighDown(ClimateEntity entity) {
    _tmpTargetHigh = ((_tmpTargetHigh - entity.temperatureStep) >= entity.minTemp) ? _tmpTargetHigh - entity.temperatureStep : entity.minTemp;
    _setTargetTemp(entity);
  }

  void _setTemperature(ClimateEntity entity) {
    if (_tempThrottleTimer!=null) {
      _tempThrottleTimer.cancel();
    }
    setState(() {
      _changedHere = true;
      _tmpTemperature = double.parse(_tmpTemperature.toStringAsFixed(1));
    });
    _tempThrottleTimer = Timer(Duration(seconds: 2), () {
      setState(() {
        _changedHere = true;
        ConnectionManager().callService(
          domain: entity.domain,
          service: "set_temperature",
          entityId: entity.entityId,
          data: {"temperature": "${_tmpTemperature.toStringAsFixed(1)}"}
        );
        _resetStateTimer(entity);
      });
    });
  }

  void _setTargetTemp(ClimateEntity entity) {
    if (_targetTempThrottleTimer!=null) {
      _targetTempThrottleTimer.cancel();
    }
    setState(() {
      _changedHere = true;
      _tmpTargetLow = double.parse(_tmpTargetLow.toStringAsFixed(1));
      _tmpTargetHigh = double.parse(_tmpTargetHigh.toStringAsFixed(1));
    });
    _targetTempThrottleTimer = Timer(Duration(seconds: 2), () {
      setState(() {
        _changedHere = true;
        ConnectionManager().callService(
          domain: entity.domain,
          service: "set_temperature",
          entityId: entity.entityId,
          data: {"target_temp_high": "${_tmpTargetHigh.toStringAsFixed(1)}", "target_temp_low": "${_tmpTargetLow.toStringAsFixed(1)}"}
        );
        _resetStateTimer(entity);
      });
    });
  }

  void _setTargetHumidity(ClimateEntity entity, double value) {
    setState(() {
      _tmpTargetHumidity = value.roundToDouble();
      _changedHere = true;
      ConnectionManager().callService(
          domain: entity.domain,
          service: "set_humidity",
          entityId: entity.entityId,
          data: {"humidity": "$_tmpTargetHumidity"}
        );
      _resetStateTimer(entity);
    });
  }

  void _setHVACMode(ClimateEntity entity, value) {
    setState(() {
      _tmpHVACMode = value;
      _changedHere = true;
      ConnectionManager().callService(
          domain: entity.domain,
          service: "set_hvac_mode",
          entityId: entity.entityId,
          data: {"hvac_mode": "$_tmpHVACMode"}
        );
      _resetStateTimer(entity);
    });
  }

  void _setSwingMode(ClimateEntity entity, value) {
    setState(() {
      _tmpSwingMode = value;
      _changedHere = true;
      ConnectionManager().callService(
          domain: entity.domain,
          service: "set_swing_mode",
          entityId: entity.entityId,
          data: {"swing_mode": "$_tmpSwingMode"}
        );
      _resetStateTimer(entity);
    });
  }

  void _setFanMode(ClimateEntity entity, value) {
    setState(() {
      _tmpFanMode = value;
      _changedHere = true;
      ConnectionManager().callService(domain: entity.domain, service: "set_fan_mode", entityId: entity.entityId, data: {"fan_mode": "$_tmpFanMode"});
      _resetStateTimer(entity);
    });
  }

  void _setPresetMode(ClimateEntity entity, value) {
    setState(() {
      _tmpPresetMode = value;
      _changedHere = true;
      ConnectionManager().callService(domain: entity.domain, service: "set_preset_mode", entityId: entity.entityId, data: {"preset_mode": "$_tmpPresetMode"});
      _resetStateTimer(entity);
    });
  }

  /*void _setOnOf(ClimateEntity entity, value) {
    setState(() {
      _tmpIsOff = !value;
      _changedHere = true;
      eventBus.fire(new ServiceCallEvent(entity.domain, "${_tmpIsOff ? 'turn_off' : 'turn_on'}", entity.entityId, null));
      _resetStateTimer(entity);
    });
  }*/

  void _setAuxHeat(ClimateEntity entity, value) {
    setState(() {
      _tmpAuxHeat = value;
      _changedHere = true;
      ConnectionManager().callService(domain: entity.domain, service: "set_aux_heat", entityId: entity.entityId, data: {"aux_heat": "$_tmpAuxHeat"});
      _resetStateTimer(entity);
    });
  }

  void _resetStateTimer(ClimateEntity entity) {
    if (_resetTimer!=null) {
      _resetTimer.cancel();
    }
    _resetTimer = Timer(Duration(seconds: 3), () {
      setState(() {});
      _resetVars(entity);
    });
  }

  @override
  Widget build(BuildContext context) {
    final entityModel = EntityModel.of(context);
    final ClimateEntity entity = entityModel.entityWrapper.entity;
    if (_changedHere) {
      _showPending = (_tmpTemperature != entity.temperature || _tmpTargetHigh != entity.targetHigh || _tmpTargetLow != entity.targetLow);
      _changedHere = false;
    } else {
      _resetTimer?.cancel();
      _resetVars(entity);
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(Sizes.leftWidgetPadding, Sizes.rowPadding, Sizes.rightWidgetPadding, 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          //_buildOnOffControl(entity),
          _buildTemperatureControls(entity),
          _buildTargetTemperatureControls(entity),
          _buildHumidityControls(entity),
          _buildOperationControl(entity),
          _buildFanControl(entity),
          _buildSwingControl(entity),
          _buildPresetModeControl(entity),
          _buildAuxHeatControl(entity)
        ],
      ),
    );
  }

  Widget _buildPresetModeControl(ClimateEntity entity) {
    if (entity.supportPresetMode) {
      return ModeSelectorWidget(
        options: entity.presetModes,
        onChange: (mode) => _setPresetMode(entity, mode),
        caption: "Preset",
        value: _tmpPresetMode,
      );
    } else {
      return Container(height: 0.0, width: 0.0,);
    }
  }

  /*Widget _buildOnOffControl(ClimateEntity entity) {
    if (entity.supportOnOff) {
      return ModeSwitchWidget(
          onChange: (value) => _setOnOf(entity, value),
          caption: "On / Off",
          value: !_tmpIsOff
      );
    } else {
      return Container(height: 0.0, width: 0.0,);
    }
  }*/

  Widget _buildAuxHeatControl(ClimateEntity entity) {
    if (entity.supportAuxHeat ) {
      return ModeSwitchWidget(
          caption: "Aux heat",
          onChange: (value) => _setAuxHeat(entity, value),
          value: _tmpAuxHeat
      );
    } else {
      return Container(height: 0.0, width: 0.0,);
    }
  }

  Widget _buildOperationControl(ClimateEntity entity) {
    if (entity.hvacModes != null) {
      return ModeSelectorWidget(
        onChange: (mode) => _setHVACMode(entity, mode),
        options: entity.hvacModes,
        caption: "Operation",
        value: _tmpHVACMode,
      );
    } else {
      return Container(height: 0.0, width: 0.0);
    }
  }

  Widget _buildFanControl(ClimateEntity entity) {
    if (entity.supportFanMode) {
      return ModeSelectorWidget(
        options: entity.fanModes,
        onChange: (mode) => _setFanMode(entity, mode),
        caption: "Fan mode",
        value: _tmpFanMode,
      );
    } else {
      return Container(height: 0.0, width: 0.0);
    }
  }

  Widget _buildSwingControl(ClimateEntity entity) {
    if (entity.supportSwingMode) {
      return ModeSelectorWidget(
          onChange: (mode) => _setSwingMode(entity, mode),
          options: entity.swingModes,
          value: _tmpSwingMode,
          caption: "Swing mode"
      );
    } else {
      return Container(height: 0.0, width: 0.0);
    }
  }

  Widget _buildTemperatureControls(ClimateEntity entity) {
    if ((entity.supportTargetTemperature) && (entity.temperature != null)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Target temperature", style: TextStyle(
              fontSize: Sizes.stateFontSize
          )),
          TemperatureControlWidget(
            value: _tmpTemperature,
            fontColor: _showPending ? Colors.red : Colors.black,
            onDec: () => _temperatureDown(entity),
            onInc: () => _temperatureUp(entity),
          )
        ],
      );
    } else {
      return Container(width: 0.0, height: 0.0,);
    }
  }

  Widget _buildTargetTemperatureControls(ClimateEntity entity) {
    List<Widget> controls = [];
    if ((entity.supportTargetTemperatureRange) && (entity.targetLow != null)) {
      controls.addAll(<Widget>[
        TemperatureControlWidget(
          value: _tmpTargetLow,
          fontColor: _showPending ? Colors.red : Colors.black,
          onDec: () => _targetLowDown(entity),
          onInc: () => _targetLowUp(entity),
        ),
        Expanded(
          child: Container(height: 10.0),
        )
      ]);
    }
    if ((entity.supportTargetTemperatureRange) && (entity.targetHigh != null)) {
      controls.add(
          TemperatureControlWidget(
            value: _tmpTargetHigh,
            fontColor: _showPending ? Colors.red : Colors.black,
            onDec: () => _targetHighDown(entity),
            onInc: () => _targetHighUp(entity),
          )
      );
    }
    if (controls.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Target temperature range", style: TextStyle(
              fontSize: Sizes.stateFontSize
          )),
          Row(
            children: controls,
          )
        ],
      );
    } else {
      return Container(width: 0.0, height: 0.0);
    }
  }

  Widget _buildHumidityControls(ClimateEntity entity) {
    List<Widget> result = [];
    if (entity.supportTargetHumidity) {
      result.addAll(<Widget>[
        Text(
          "$_tmpTargetHumidity%",
          style: TextStyle(fontSize: Sizes.largeFontSize),
        ),
        Expanded(
          child: Slider(
            value: _tmpTargetHumidity,
            max: entity.maxHumidity,
            min: entity.minHumidity,
            onChanged: ((double val) {
              setState(() {
                _changedHere = true;
                _tmpTargetHumidity = val.roundToDouble();
              });
            }),
            onChangeEnd: (double v) => _setTargetHumidity(entity, v),
          ),
        )
      ]);
    }
    if (result.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(
                0.0, Sizes.rowPadding, 0.0, Sizes.rowPadding),
            child: Text("Target humidity", style: TextStyle(
                fontSize: Sizes.stateFontSize
            )),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: result,
          ),
          Container(
            height: Sizes.rowPadding,
          )
        ],
      );
    } else {
      return Container(
        width: 0.0,
        height: 0.0,
      );
    }
  }


  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

}