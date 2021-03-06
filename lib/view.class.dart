part of 'main.dart';

class HAView {
  List<CardData> cards = [];
  CardData badges;
  Entity linkedEntity;
  String name;
  String id;
  String path;
  String iconName;
  final int count;
  bool isPanel;

  HAView({@required this.count, @required rawData}) {
    id = "${rawData['id']}";
    name = rawData['title'];
    iconName = rawData['icon'];
    isPanel = rawData['panel'] ?? false;
    path = rawData['path'] ?? '$count';

    if (rawData['badges'] != null && !isPanel) {
        badges = CardData.parse({
          'type': CardType.BADGES,
          'badges': rawData['badges']
        });
      }

      (rawData['cards'] ?? []).forEach((rawCardData) {
        if (rawCardData != null) {
          if (rawCardData is Map) {
            cards.add(CardData.parse(rawCardData));
          } else if (rawCardData is List && rawCardData.length == 1) {
            cards.add(CardData.parse(rawCardData[0]));
          }
        }
      });
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
      view: this
    );
  }
}
