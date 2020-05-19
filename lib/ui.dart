part of 'main.dart';

class HomeAssistantUI {
  List<HAView> views;
  String title;

  bool get isEmpty => views == null || views.isEmpty;

  HomeAssistantUI({rawLovelaceConfig}) {
    if (rawLovelaceConfig == null) {
      rawLovelaceConfig = _generateLovelaceConfig();
    }
    views = [];
    Logger.d("--Title: ${rawLovelaceConfig["title"]}");
    title = rawLovelaceConfig["title"];
    int viewCounter = 0;
    Logger.d("--Views count: ${rawLovelaceConfig['views'].length}");
    rawLovelaceConfig["views"].forEach((rawView){
      Logger.d("----view: ${rawView['path'] ?? viewCounter}");
      HAView view = HAView(
          count: viewCounter,
          rawData: rawView
      );

      views.add(
        view
      );
      viewCounter += 1;
    });
  }

  Map _generateLovelaceConfig() {
    Map result = {
      'title': 'Home'
    };
    List<Entity> left = HomeAssistant().entities.getByDomains(
      excludeDomains: ['sensor','binary_sensor', 'device_tracker', 'person', 'sun']
    );
    List<Map> cards = [];
    Map<String, Map> cardsByDomains = {};
    left.forEach((Entity entity) {
      if (entity is GroupEntity) {
        cards.add({
          'type': CardType.ENTITIES,
          'title': entity.displayName,
          'entities': entity.childEntities.map((e) => e.entityId)
        });
      } else if (entity is MediaPlayerEntity) {
        cards.add({
          'type': CardType.MEDIA_CONTROL,
          'entity': entity.entityId
        });
      } else if (entity is AlarmControlPanelEntity) {
        cards.add({
          'type': CardType.ALARM_PANEL,
          'entity': entity.entityId
        });
      } else if (cardsByDomains.containsKey(entity.domain)) {
        cardsByDomains[entity.domain]['entities'].add(entity.entityId);
      } else {
        cardsByDomains[entity.domain] = {
          'type': 'entities',
          'entities': [entity.entityId],
          'title': entity.domain
        };
      }
    });
    cards.addAll(cardsByDomains.values);
    result['views'] = [
      {
        'icon': 'mdi:home',
        'badges': HomeAssistant().entities.getByDomains(
            includeDomains: ['sensor', 'binary_sensor', 'device_tracker', 'person', 'sun']
          ).map(
            (en) => en.entityId
          ).toList(),
        'cards': cards
      }
    ];
    return result;
  }

  Widget build(BuildContext context, TabController tabController) {
    return TabBarView(
      controller: tabController,
      children: _buildViews(context)
    );
  }

  List<Widget> _buildViews(BuildContext context) {
    return views.map((view) => view.build(context)).toList();
  }

  void clear() {
    views.clear();
  }

}