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
      List currentStateFilter;
      if (entityWrapper.stateFilter != null && entityWrapper.stateFilter.isNotEmpty) {
        currentStateFilter = entityWrapper.stateFilter;
      } else {
        currentStateFilter = stateFilter;
      }
      bool showByFilter = currentStateFilter.isEmpty;
      for (var allowedState in currentStateFilter) {
        if (allowedState is String && allowedState == entityWrapper.entity.state) {
          showByFilter = true;
          break;
        } else if (allowedState is Map) {
          try {
            var tmpVal = allowedState['attribute'] != null ? entityWrapper.entity.getAttribute(allowedState['attribute']) : entityWrapper.entity.state;
            var valToCompareWith = allowedState['value'];
            var valToCompare;
            if (valToCompareWith is! String) {
              valToCompare = double.tryParse(tmpVal);
            } else {
              valToCompare = tmpVal;
            }
            if (valToCompare != null) {
              bool result;
              switch (allowedState['operator']) {
                case '<=': { result = valToCompare <= valToCompareWith;}
                break;
                
                case '<': { result = valToCompare < valToCompareWith;}
                break;

                case '>=': { result = valToCompare >= valToCompareWith;}
                break;

                case '>': { result = valToCompare > valToCompareWith;}
                break;

                case '!=': { result = valToCompare != valToCompareWith;}
                break;

                case 'regex': {
                  RegExp regExp = RegExp(valToCompareWith.toString());
                  result = regExp.hasMatch(valToCompare.toString());
                }
                break;

                default: {
                    result = valToCompare == valToCompareWith;
                  }
              }
              if (result) {
                showByFilter = true;
                break;
              }  
            }
          } catch (e) {
            Logger.e('Error filtering ${entityWrapper.entity.entityId} by $allowedState');
            Logger.e('$e');
          }
        }
      }
      return showByFilter;
    }).toList();
  }

  Widget build(BuildContext context) {
    return CardWidget(
      card: this,
    );
  }

}