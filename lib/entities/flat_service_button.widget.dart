part of '../main.dart';

class FlatServiceButton extends StatelessWidget {

  final String serviceDomain;
  final String serviceName;
  final String entityId;
  final String text;
  final double fontSize;

  FlatServiceButton({
    Key key,
    @required this.serviceDomain,
    @required this.serviceName,
    @required this.entityId,
    @required this.text,
    this.fontSize: Sizes.stateFontSize
  }) : super(key: key);

  void _setNewState() {
    ConnectionManager().callService(serviceDomain, serviceName, entityId, null);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: fontSize*2.5,
        child: FlatButton(
          onPressed: (() {
            _setNewState();
          }),
          child: Text(
            text,
            textAlign: TextAlign.right,
            style:
            new TextStyle(fontSize: fontSize, color: Colors.blue),
          ),
        )
    );
  }
}