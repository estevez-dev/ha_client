part of '../../../main.dart';

class TextInputStateWidget extends StatefulWidget {

  TextInputStateWidget({Key key}) : super(key: key);

  @override
  _TextInputStateWidgetState createState() => _TextInputStateWidgetState();
}

class _TextInputStateWidgetState extends State<TextInputStateWidget> {
  String _tmpValue;
  String _entityState;
  String _entityDomain;
  String _entityId;
  int _minLength;
  int _maxLength;
  FocusNode _focusNode = FocusNode();
  bool validValue = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_focusListener);
  }

  void setNewState(newValue, domain, entityId) {
    if (validate(newValue, _minLength, _maxLength)) {
      ConnectionManager().callService(domain, "set_value", entityId,
          {"value": "$newValue"});
    } else {
      setState(() {
        _tmpValue = _entityState;
      });
    }
  }

  bool validate(newValue, minLength, maxLength) {
    if (newValue is String) {
      validValue = (newValue.length >= minLength) &&
          (maxLength == -1 ||
              (newValue.length <= maxLength));
    } else {
      validValue = true;
    }
    return validValue;
  }

  void _focusListener() {
    if (!_focusNode.hasFocus && (_tmpValue != _entityState)) {
      setNewState(_tmpValue, _entityDomain, _entityId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final entityModel = EntityModel.of(context);
    final TextEntity entity = entityModel.entityWrapper.entity;
    _entityState = entity.state;
    _entityDomain = entity.domain;
    _entityId = entity.entityId;
    _minLength = entity.valueMinLength;
    _maxLength = entity.valueMaxLength;

    if (!_focusNode.hasFocus && (_tmpValue != entity.state)) {
      _tmpValue = entity.state;
    }
    if (entity.isTextField || entity.isPasswordField) {
      return Flexible(
        fit: FlexFit.tight,
        flex: 2,
        //width: Entity.INPUT_WIDTH,
        child: TextField(
            focusNode: _focusNode,
            obscureText: entity.isPasswordField,
            controller: TextEditingController.fromValue(TextEditingValue(text: _tmpValue)),
            onChanged: (value) {
              _tmpValue = value;
            }),
      );
    } else {
      Logger.w( "Unsupported input mode for ${entity.entityId}");
      return SimpleEntityState();
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_focusListener);
    _focusNode.dispose();
    super.dispose();
  }

}