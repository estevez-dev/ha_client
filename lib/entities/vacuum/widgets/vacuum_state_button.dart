part of '../../../main.dart';

class VacuumStateButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget result;
    VacuumEntity entity = EntityModel.of(context).entityWrapper.entity;
    if (entity.supportTurnOn && entity.supportTurnOff) {
      result = FlatServiceButton(
          serviceDomain: "vacuum",
          serviceName: entity.state == EntityState.on ? "turn_off" : "turn_on",
          entityId: entity.entityId,
          text: entity.state == EntityState.on ? "TURN OFF" : "TURN ON"
      );
    } else if (entity.supportStart && (entity.state == EntityState.docked || entity.state == EntityState.idle)) {
      result = FlatServiceButton(
          serviceDomain: "vacuum",
          serviceName: "start",
          entityId: entity.entityId,
          text: "START CLEANING"
      );
    } else if (entity.supportReturnHome && entity.state == EntityState.cleaning) {
      result = FlatServiceButton(
          serviceDomain: "vacuum",
          serviceName: "return_to_base",
          entityId: entity.entityId,
          text: "RETURN TO DOCK"
      );
    } else {
      result = Text(entity.state.toUpperCase(), style: Theme.of(context).textTheme.subhead);
    }
    return Padding(
      padding: EdgeInsets.only(right: 15),
      child: result,
    );
  }
}
