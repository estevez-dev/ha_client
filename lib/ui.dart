part of 'main.dart';

class HomeAssistantUI {
  List<HAView> views;
  String title;

  bool get isEmpty => views == null || views.isEmpty;

  HomeAssistantUI(rawLovelaceConfig) {
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

  Widget build(BuildContext context, TabController tabController) {
    return TabBarView(
      controller: tabController,
      children: _buildViews(context)
    );
  }

  List<Widget> _buildViews(BuildContext context) {
    List<Widget> result = [];
    views.forEach((view) {
      result.add(
        view.build(context)
      );
    });
    return result;
  }

  void clear() {
    views.clear();
  }

}