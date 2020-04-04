part of '../main.dart';

class FlatServiceButton extends StatelessWidget {

  final String serviceDomain;
  final String serviceName;
  final String entityId;
  final String text;

  FlatServiceButton({
    Key key,
    @required this.serviceDomain,
    @required this.serviceName,
    @required this.entityId,
    @required this.text,
  }) : super(key: key);

  void _setNewState() {
    ConnectionManager().callService(domain: serviceDomain, service: serviceName, entityId: entityId);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: Theme.of(context).textTheme.subhead.fontSize*2.5,
        child: FlatButton(
          onPressed: (() {
            _setNewState();
          }),
          child: Text(
            text,
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.subhead.copyWith(
              color: Colors.blue
            ),
          ),
        )
    );
  }
}