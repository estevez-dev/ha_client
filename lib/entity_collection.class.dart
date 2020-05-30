part of 'main.dart';

class EntityCollection {

  final homeAssistantWebHost;

  Map<String, Entity> _allEntities;
  //Map<String, Entity> views;

  bool get isEmpty => _allEntities.isEmpty;
  List<Entity> get viewEntities => _allEntities.values.where((entity) => entity.isView).toList();

  EntityCollection(this.homeAssistantWebHost) {
    _allEntities = {};
    //views = {};
  }

  bool get hasDefaultView => _allEntities.keys.contains("group.default_view");

  void parse(List rawData) {
    _allEntities.clear();
    //views.clear();

    Logger.d("Parsing ${rawData.length} Home Assistant entities");
    rawData.forEach((rawEntityData) {
      addFromRaw(rawEntityData);
    });
    _allEntities.forEach((entityId, entity){
      if ((entity.isGroup) && (entity.childEntityIds != null)) {
        entity.childEntities = getAll(entity.childEntityIds);
      }
      /*if (entity.isView) {
        views[entityId] = entity;
      }*/
    });
  }

  void clear() {
    _allEntities.clear();
  }

  Entity _createEntityInstance(rawEntityData) {
    switch (rawEntityData["entity_id"].split(".")[0]) {
      case 'sun': {
        return SunEntity(rawEntityData, homeAssistantWebHost);
      }
      case "media_player": {
        return MediaPlayerEntity(rawEntityData, homeAssistantWebHost);
      }
      case 'sensor': {
        return SensorEntity(rawEntityData, homeAssistantWebHost);
      }
      case 'lock': {
        return LockEntity(rawEntityData, homeAssistantWebHost);
      }
      case "automation": {
        return AutomationEntity(rawEntityData, homeAssistantWebHost);
      }

      case "input_boolean":
      case "switch": {
        return SwitchEntity(rawEntityData, homeAssistantWebHost);
      }
      case "light": {
        return LightEntity(rawEntityData, homeAssistantWebHost);
      }
      case "group": {
        return GroupEntity(rawEntityData, homeAssistantWebHost);
      }
      case "script":
      case "scene": {
        return ButtonEntity(rawEntityData, homeAssistantWebHost);
      }
      case "input_datetime": {
        return DateTimeEntity(rawEntityData, homeAssistantWebHost);
      }
      case "input_select": {
        return SelectEntity(rawEntityData, homeAssistantWebHost);
      }
      case "input_number": {
        return SliderEntity(rawEntityData, homeAssistantWebHost);
      }
      case "input_text": {
        return TextEntity(rawEntityData, homeAssistantWebHost);
      }
      case "climate": {
        return ClimateEntity(rawEntityData, homeAssistantWebHost);
      }
      case "cover": {
        return CoverEntity(rawEntityData, homeAssistantWebHost);
      }
      case "fan": {
        return FanEntity(rawEntityData, homeAssistantWebHost);
      }
      case "camera": {
        return CameraEntity(rawEntityData, homeAssistantWebHost);
      }
      case "alarm_control_panel": {
        return AlarmControlPanelEntity(rawEntityData, homeAssistantWebHost);
      }
      case "timer": {
        return TimerEntity(rawEntityData, homeAssistantWebHost);
      }
      case "vacuum": {
        return VacuumEntity(rawEntityData, homeAssistantWebHost);
      }
      default: {
        return Entity(rawEntityData, homeAssistantWebHost);
      }
    }
  }

  bool updateState(Map rawStateData) {
    if (isExist(rawStateData["entity_id"])) {
      updateFromRaw(rawStateData["new_state"] ?? rawStateData["old_state"]);
      return false;
    } else {
      addFromRaw(rawStateData["new_state"] ?? rawStateData["old_state"]);
      return true;
    }
  }

  void add(Entity entity) {
    _allEntities[entity.entityId] = entity;
  }

  void addFromRaw(Map rawEntityData) {
    Entity entity = _createEntityInstance(rawEntityData);
    _allEntities[entity.entityId] = entity;
  }

  void updateFromRaw(Map rawEntityData) {
    get("${rawEntityData["entity_id"]}")?.update(rawEntityData, homeAssistantWebHost);
  }

  Entity get(String entityId) {
    return _allEntities[entityId];
  }

  List<Entity> getAll(List ids) {
    List<Entity> result = [];
    ids.forEach((id){
      Entity en = get(id);
      if (en != null) {
        result.add(en);
      }
    });
    return result;
  }

  bool isExist(String entityId) {
    return _allEntities.containsKey(entityId);
  }

  List<Entity> getByDomains({List<String> includeDomains: const [], List<String> excludeDomains: const [], List<String> stateFiler}) {
    return _allEntities.values.where((entity) {
      return
        (excludeDomains.isEmpty || !excludeDomains.contains(entity.domain)) && 
        (includeDomains.isEmpty || includeDomains.contains(entity.domain)) &&
        ((stateFiler != null && stateFiler.contains(entity.state)) || stateFiler == null);
    }).toList();
  }
}