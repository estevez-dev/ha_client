part of '../main.dart';

class ErrorEntityWidget extends StatelessWidget {
  
  final String text;

  ErrorEntityWidget({
    Key key, this.text
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final EntityModel entityModel = EntityModel.of(context);
    String errorText = text ?? "Entity error: ${entityModel.entityWrapper.entity?.entityId}";
    return Container(
        child: Padding(
          padding: EdgeInsets.all(5.0),
          child: Text(errorText),
        ),
        color: Theme.of(context).errorColor,
    );
  }
}