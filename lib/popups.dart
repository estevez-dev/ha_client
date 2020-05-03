part of 'main.dart';

class Popup {
  final String title;
  final String body;
  final String positiveText;
  final String negativeText;
  final  onPositive;
  final  onNegative;

  Popup({@required this.title, @required this.body, this.positiveText, this.negativeText, this.onPositive, this.onNegative});

  Future show(BuildContext context) {
    List<Widget> buttons = [];
    buttons.add(FlatButton(
      child: new Text("$positiveText"),
      onPressed: () {
        Navigator.of(context).pop();
        if (onPositive != null) {
          onPositive();
        }
      },
    ));
    if (negativeText != null) {
      buttons.add(FlatButton(
        child: new Text("$negativeText"),
        onPressed: () {
          Navigator.of(context).pop();
          if (onNegative != null) {
            onNegative();
          }
        },
      ));
    }
    // flutter defined function
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("$title"),
          content: new Text("$body"),
          actions: buttons,
        );
      },
    );
  }
}

class TokenLoginPopup extends Popup {

  TokenLoginPopup() : super(title: 'Login with long-lived token', body: '');

  final _tokenLoginFormKey = GlobalKey<FormState>();

  @override
  Future show(BuildContext context) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return SimpleDialog(
          title: new Text('Login with long-lived token'),
          children: <Widget>[
            Form(
              key: _tokenLoginFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(20),
                      child: TextFormField(
                      onSaved: (newValue) {
                        final storage = new FlutterSecureStorage();
                        storage.write(key: "hacl_llt", value: newValue).then((_) {
                          Navigator.of(context).pop();
                          eventBus.fire(SettingsChangedEvent(true));
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Please enter long-lived token',
                        contentPadding: EdgeInsets.all(0),
                        hintStyle: Theme.of(context).textTheme.subhead.copyWith(
                          color: Theme.of(context).textTheme.overline.color
                        )
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Long-lived token can\'t be emty';
                        }
                        return null;
                      },
                    )
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      FlatButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      Container(width: 10),
                      FlatButton(
                        child: Text('Login'),
                        onPressed: () {
                          if (_tokenLoginFormKey.currentState.validate()) {
                            _tokenLoginFormKey.currentState.save();
                          }
                        },
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        );
      },
    );
  }

}

class RegisterAppPopup extends Popup {

  RegisterAppPopup({String title, String body}): super(title: title, body: body);

  final _tokenLoginFormKey = GlobalKey<FormState>();

  @override
  Future show(BuildContext context) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return SimpleDialog(
          title: new Text('${this.title}'),
          children: <Widget>[
            Form(
              key: _tokenLoginFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: Text('${this.body}')
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                      child: TextFormField(
                        initialValue: ConnectionManager().mobileAppDeviceName ?? MobileAppIntegrationManager.getDefaultDeviceName(),
                        onSaved: (newValue) {
                          String deviceName =  newValue?.trim();
                          SharedPreferences.getInstance().then((prefs) {
                            prefs.remove("app-webhook-id");
                            prefs.setString('app-integration-device-name', deviceName);
                            ConnectionManager().webhookId = null;
                            ConnectionManager().mobileAppDeviceName = deviceName;
                            Navigator.of(context).pop();
                            MobileAppIntegrationManager.checkAppRegistration();
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Device name*',
                          hintText: 'Please enter device name',
                          contentPadding: EdgeInsets.all(0),
                          hintStyle: Theme.of(context).textTheme.subhead.copyWith(
                            color: Theme.of(context).textTheme.overline.color
                          )
                        ),
                        validator: (value) {
                          if (value.trim().isEmpty) {
                            return 'Device name can\'t be emty';
                          }
                          return null;
                        },
                      )
                    ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      FlatButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      Container(width: 10),
                      FlatButton(
                        child: Text('Create now'),
                        onPressed: () {
                          if (_tokenLoginFormKey.currentState.validate()) {
                            _tokenLoginFormKey.currentState.save();
                          }
                        },
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        );
      },
    );
  }

}