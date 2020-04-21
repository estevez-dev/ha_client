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
      Logger.d("----view id: ${rawView['id']}");
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
    Map result = {};
    result['title'] = 'Home';
    result['views'] = [
      {
        'icon': 'mdi:home',
        'badges': HomeAssistant().entities.getByDomains(
            includeDomains: ['sensor', 'binary_sensor', 'device_tracker', 'person', 'sun']
          ).map(
            (en) => en.entityId
          ).toList(),
        'cards': [{
          'type': 'entities',
          'entities': HomeAssistant().entities.getByDomains(
              excludeDomains: ['sensor','binary_sensor', 'device_tracker', 'person', 'sun']
            ).map(
              (en) => en.entityId
            ).toList()
        }]
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