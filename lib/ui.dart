part of 'main.dart';

class HomeAssistantUI {
  List<HAView> views;
  String title;

  bool get isEmpty => views == null || views.isEmpty;

  HomeAssistantUI() {
    views = [];
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