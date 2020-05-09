part of '../main.dart';

class Badges extends StatelessWidget {
  final BadgesData badges;

  const Badges({Key key, this.badges}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<EntityWrapper> entitiesToShow = badges.getEntitiesToShow();
    
    if (entitiesToShow.isNotEmpty) {
      if (ConnectionManager().scrollBadges) {
        return ConstrainedBox(
          constraints: BoxConstraints.tightFor(height: 112),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: entitiesToShow.map((entity) =>
                EntityModel(
                  entityWrapper: entity,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
                    child: BadgeWidget(),
                  ),
                  handleTap: true,
                )).toList()
            ),
          )
        );
      } else {
        return Padding(
          padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 10.0,
            runSpacing: 5,
            children: entitiesToShow.map((entity) =>
                EntityModel(
                  entityWrapper: entity,
                  child: BadgeWidget(),
                  handleTap: true,
                )).toList(),
          )
        );
      }
    }
    return Container(height: 0.0, width: 0.0,);
  }

  
}