part of '../../../main.dart';

class SelectStateWidget extends StatefulWidget {

  SelectStateWidget({Key key}) : super(key: key);

  @override
  _SelectStateWidgetState createState() => _SelectStateWidgetState();
}

class _SelectStateWidgetState extends State<SelectStateWidget> {

  void setNewState(domain, entityId, newValue) {
    ConnectionManager().callService(
      domain: domain,
      service: "select_option",
      entityId: entityId,
      data: {"option": "$newValue"}
    );
  }

  @override
  Widget build(BuildContext context) {
    final entityModel = EntityModel.of(context);
    final SelectEntity entity = entityModel.entityWrapper.entity;
    Widget ctrl;
    if (entity.listOptions.isNotEmpty) {
      ctrl = DropdownButton<String>(
        value: entity.state,
        isExpanded: true,
        items: entity.listOptions.map((String value) {
          return new DropdownMenuItem<String>(
            value: value,
            child: new Text(value),
          );
        }).toList(),
        onChanged: (_) {
          setNewState(entity.domain, entity.entityId,_);
        },
      );
    } else {
      ctrl = Text('---');
    }
    return Flexible(
      flex: 2,
      fit: FlexFit.tight,
      //width: Entity.INPUT_WIDTH,
      child: ctrl,
    );
  }


}