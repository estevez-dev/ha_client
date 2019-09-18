part of '../../main.dart';

class EntityAttributesList extends StatelessWidget {
  EntityAttributesList({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final entityModel = EntityModel.of(context);
    List<Widget> attrs = [];
    entityModel.entityWrapper.entity.attributes.forEach((name, value) {
      attrs.add(_buildSingleAttribute("$name", "${value ?? '-'}"));
    });
    return Padding(
      padding: EdgeInsets.only(bottom: Sizes.rowPadding),
      child: Column(
        children: attrs,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
      )
    );
  }

  Widget _buildSingleAttribute(String name, String value) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                Sizes.leftWidgetPadding, Sizes.rowPadding, 0.0, 0.0),
            child: Text(
              "$name",
              textAlign: TextAlign.left,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                0.0, Sizes.rowPadding, Sizes.rightWidgetPadding, 0.0),
            child: Text(
              "${value}",
              textAlign: TextAlign.right,
            ),
          ),
        )
      ],
    );
  }
}