part of 'main.dart';

class Popup {
  final String title;
  final String body;
  final String positiveText;
  final String negativeText;
  final  onPositive;
  final  onNegative;

  Popup({@required this.title, @required this.body, this.positiveText, this.negativeText, this.onPositive, this.onNegative});

  void show(BuildContext context) {
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
    showDialog(
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