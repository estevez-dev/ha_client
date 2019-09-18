part of '../../main.dart';

class LastUpdatedWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final entityModel = EntityModel.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
          Sizes.leftWidgetPadding, Sizes.rowPadding, 0.0, 0.0),
      child: Text(
        '${entityModel.entityWrapper.entity.lastUpdated}',
        textAlign: TextAlign.left,
        style: TextStyle(
            fontSize: Sizes.smallFontSize, color: Colors.black26),
      ),
    );
  }
}