part of '../main.dart';

class Badges extends StatelessWidget {
  final BadgesData badges;

  const Badges({Key key, this.badges}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<EntityWrapper> entitiesToShow = badges.getEntitiesToShow();
    
    if (entitiesToShow.isNotEmpty) {
      return Wrap(
        alignment: WrapAlignment.center,
        spacing: 10.0,
        runSpacing: 1.0,
        children: entitiesToShow.map((entity) =>
            EntityModel(
              entityWrapper: entity,
              child: BadgeWidget(),
              handleTap: true,
            )).toList(),
      );
    }
    return Container(height: 0.0, width: 0.0,);
  }

  
}