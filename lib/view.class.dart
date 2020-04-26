part of 'main.dart';

class HAView {
  List<CardData> cards = [];
  List<Entity> badges = [];
  Entity linkedEntity;
  String name;
  String id;
  String iconName;
  final int count;
  bool isPanel;

  HAView({@required this.count, @required rawData}) {
    id = "${rawData['id']}";
    name = rawData['title'];
    iconName = rawData['icon'];
    isPanel = rawData['panel'] ?? false;

    if (rawData['badges'] != null && rawData['badges'] is List) {
        rawData['badges'].forEach((entity) {
          if (entity is String) {
            if (HomeAssistant().entities.isExist(entity)) {
              Entity e = HomeAssistant().entities.get(entity);
              badges.add(e);
            }
          } else {
            String eId = '${entity['entity']}';
            if (HomeAssistant().entities.isExist(eId)) {
              Entity e = HomeAssistant().entities.get(eId);
              badges.add(e);
            }
          }
        });
      }

      (rawData["cards"] ?? []).forEach((rawCardData) {
        cards.add(CardData.parse(rawCardData));
      });

      //cards.addAll(_createLovelaceCards(rawData["cards"] ?? [], 1));
  }

  Widget buildTab() {
    if (linkedEntity == null) {
      if (iconName != null && iconName.isNotEmpty) {
        return
          Tab(
              icon:
              Icon(
                MaterialDesignIcons.getIconDataFromIconName(
                    iconName ?? "mdi:home-assistant"),
                size: 24.0,
              )
          );
      } else {
        return
          Tab(
              text: "${name?.toUpperCase() ?? "UNNAMED VIEW"}",
          );
      }
    } else {
      if (linkedEntity.icon != null && linkedEntity.icon.length > 0) {
        return Tab(
          icon: Icon(
              MaterialDesignIcons.getIconDataFromIconName(
                  linkedEntity.icon),
              size: 24.0,
            )
        );
      } else {
        return Tab(
            text: "${linkedEntity.displayName?.toUpperCase()}",
        );
      }

    }
  }

  Widget build(BuildContext context) {
    return ViewWidget(
      view: this,
    );
  }
}