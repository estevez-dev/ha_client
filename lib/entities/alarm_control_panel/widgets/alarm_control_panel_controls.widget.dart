part of '../../../main.dart';

class AlarmControlPanelControlsWidget extends StatefulWidget {

  final bool extended;
  final List states;

  const AlarmControlPanelControlsWidget({Key key, @required this.extended, this.states}) : super(key: key);

  @override
  _AlarmControlPanelControlsWidgetWidgetState createState() => _AlarmControlPanelControlsWidgetWidgetState();

}

class _AlarmControlPanelControlsWidgetWidgetState extends State<AlarmControlPanelControlsWidget> {

  String code = "";
  List supportedStates;

  @override
  void initState() {
    super.initState();
    supportedStates = widget.states ?? ["arm_home", "arm_away"];
  }


  void _callService(AlarmControlPanelEntity entity, String service) {
    ConnectionManager().callService(
      domain: entity.domain,
      service: service,
      entityId: entity.entityId,
      data: {"code": "$code"}
    );
    setState(() {
      code = "";
    });
  }

  void _pinPadHandler(value) {
    setState(() {
      code += "$value";
    });
  }

  void _pinPadClear() {
    setState(() {
      code = "";
    });
  }

  void _askToTrigger(AlarmControlPanelEntity entity) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Are you sure?"),
          content: new Text("Are you sure want to trigger alarm ${entity.displayName}?"),
          actions: <Widget>[
            FlatButton(
              child: new Text("Yes"),
              onPressed: () {
                ConnectionManager().callService(
                  domain: entity.domain,
                  service: "alarm_trigger",
                  entityId: entity.entityId
                );
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: new Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final entityModel = EntityModel.of(context);
    final AlarmControlPanelEntity entity = entityModel.entityWrapper.entity;
    List<Widget> buttons = [];
    if (entity.state == EntityState.alarm_disarmed) {
      if (supportedStates.contains("arm_home")) {
        buttons.add(
          RaisedButton(
            onPressed: () => _callService(entity, "alarm_arm_home"),
            child: Text("ARM HOME"),
          )
        );
      }
      if (supportedStates.contains("arm_away")) {
        buttons.add(
            RaisedButton(
              onPressed: () => _callService(entity, "alarm_arm_away"),
              child: Text("ARM AWAY"),
            )
        );
      }
      if (widget.extended) {
        if (supportedStates.contains("arm_night")) {
          buttons.add(
              RaisedButton(
                onPressed: () => _callService(entity, "alarm_arm_night"),
                child: Text("ARM NIGHT"),
              )
          );
        }
        if (supportedStates.contains("arm_custom_bypass")) {
          buttons.add(
              RaisedButton(
                onPressed: () =>
                    _callService(entity, "alarm_arm_custom_bypass"),
                child: Text("ARM CUSTOM BYPASS"),
              )
          );
        }
      }
    } else {
      buttons.add(
        RaisedButton(
          onPressed: () => _callService(entity, "alarm_disarm"),
          child: Text("DISARM"),
        )
      );
    }
    Widget pinPad;
    if (entity.attributes["code_format"] == null) {
      pinPad = Container(width: 0.0, height: 0.0,);
    } else {
      pinPad = Padding(
          padding: EdgeInsets.only(bottom: Sizes.rowPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Wrap(
                spacing: 5.0,
                children: <Widget>[
                  RaisedButton(
                    onPressed: () => _pinPadHandler("1"),
                    child: Text("1"),
                  ),
                  RaisedButton(
                    onPressed: () => _pinPadHandler("2"),
                    child: Text("2"),
                  ),
                  RaisedButton(
                    onPressed: () => _pinPadHandler("3"),
                    child: Text("3"),
                  )
                ],
              ),
              Wrap(
                spacing: 5.0,
                children: <Widget>[
                  RaisedButton(
                    onPressed: () => _pinPadHandler("4"),
                    child: Text("4"),
                  ),
                  RaisedButton(
                    onPressed: () => _pinPadHandler("5"),
                    child: Text("5"),
                  ),
                  RaisedButton(
                    onPressed: () => _pinPadHandler("6"),
                    child: Text("6"),
                  )
                ],
              ),
              Wrap(
                spacing: 5.0,
                children: <Widget>[
                  RaisedButton(
                    onPressed: () => _pinPadHandler("7"),
                    child: Text("7"),
                  ),
                  RaisedButton(
                    onPressed: () => _pinPadHandler("8"),
                    child: Text("8"),
                  ),
                  RaisedButton(
                    onPressed: () => _pinPadHandler("9"),
                    child: Text("9"),
                  )
                ],
              ),
              Wrap(
                spacing: 5.0,
                alignment: WrapAlignment.end,
                children: <Widget>[
                  RaisedButton(
                    onPressed: () => _pinPadHandler("0"),
                    child: Text("0"),
                  ),
                  RaisedButton(
                    onPressed: () => _pinPadClear(),
                    child: Text("CLEAR"),
                  )
                ],
              )
            ],
          )
      );
    }
    Widget inputWrapper;
    if (entity.attributes["code_format"] == null) {
      inputWrapper = Container(width: 0.0, height: 0.0,);
    } else {
      inputWrapper = Container(
          width: 150.0,
          child: TextField(
              decoration: InputDecoration(
                  labelText: "Alarm Code"
              ),
              //focusNode: _focusNode,
              obscureText: true,
              controller: new TextEditingController.fromValue(
                  new TextEditingValue(
                      text: code,
                      selection:
                      new TextSelection.collapsed(offset: code.length)
                  )
              ),
              onChanged: (value) {
                code = value;
              }
          )
      );
    }
    Widget buttonsWrapper = Padding(
        padding: EdgeInsets.symmetric(vertical: Sizes.rowPadding),
        child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 15.0,
            runSpacing: Sizes.rowPadding,
            children: buttons
        )
    );
    Widget triggerButton = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FlatButton(
          child: Text(
            "TRIGGER",
            style: Theme.of(context).textTheme.subhead.copyWith(
              color: Colors.redAccent
            )
          ),
          onPressed: () => _askToTrigger(entity),
        )
      ]
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        widget.extended ? buttonsWrapper : inputWrapper,
        widget.extended ? inputWrapper : buttonsWrapper,
        widget.extended ? pinPad : triggerButton
      ]

    );
  }


}