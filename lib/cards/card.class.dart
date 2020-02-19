part of '../main.dart';

class HACard {
  List<EntityWrapper> entities = [];
  List<HACard> childCards = [];
  EntityWrapper linkedEntityWrapper;
  String name;
  String id;
  String type;
  bool showName;
  bool showState;
  bool showEmpty;
  bool showHeaderToggle;
  int columnsCount;
  List stateFilter;
  List states;
  List conditions;
  String content;
  String unit;
  int min;
  int max;
  Map severity;

  HACard({
    this.name,
    this.id,
    this.linkedEntityWrapper,
    this.columnsCount: 4,
    this.showName: true,
    this.showHeaderToggle: true,
    this.showState: true,
    this.stateFilter: const [],
    this.showEmpty: true,
    this.content,
    this.states,
    this.conditions: const [],
    this.unit,
    this.min,
    this.max,
    this.severity,
    @required this.type
  }) {
    if (this.columnsCount <= 0) {
      this.columnsCount = 4;
    }
  }

  List<EntityWrapper> getEntitiesToShow() {
    return entities.where((entityWrapper) {
      if (!ConnectionManager().useLovelace && entityWrapper.entity.isHidden) {
        return false;
      }
      if (stateFilter.isNotEmpty) {
        return stateFilter.contains(entityWrapper.entity.state);
      }
      return true;
    }).toList();
  }

  Widget build(BuildContext context) {
    return CardWidget(
      card: this,
    );
  }

}