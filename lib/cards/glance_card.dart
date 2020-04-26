part of '../main.dart';

class GlanceCard extends StatelessWidget {
  final GlanceCardData card;

  const GlanceCard({Key key, this.card}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<EntityWrapper> entitiesToShow = card.getEntitiesToShow();
    if (entitiesToShow.isEmpty && !card.showEmpty) {
      return Container(height: 0.0, width: 0.0,);
    }
    int length = entitiesToShow.length;
    int rowsCount;
    int columnsCount;
    if (length == 0) {
      columnsCount = 0;
      rowsCount = 0;
    } else {
      columnsCount = length >= card.columnsCount ? card.columnsCount : entitiesToShow.length;
      rowsCount = (length / columnsCount).round();
    }
    List<TableRow> rows = [];
    for (int i = 0; i < rowsCount; i++) {
      int start = i*columnsCount;
      int end = start + math.min(columnsCount, length - start);
      List<Widget> rowChildren = [];
      rowChildren.addAll(entitiesToShow.sublist(
          start, end
        ).map(
          (EntityWrapper entity){
            return EntityModel(
              entityWrapper: entity,
              child: _buildEntityContainer(context, entity),
              handleTap: true
            );
          }
        ).toList()
      );
      while (rowChildren.length < columnsCount) {
        rowChildren.add(
          Container()
        );
      }
      rows.add(
        TableRow(
          children: rowChildren
        )
      );
    }
    return CardWrapper(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CardHeader(name: card.title),
          Padding(
            padding: EdgeInsets.symmetric(vertical: Sizes.rowPadding),
            child: Table(
              children: rows
            )
          )
        ],
      )
    );
  }

  Widget _buildEntityContainer(BuildContext context, EntityWrapper entityWrapper) {
    if (entityWrapper.entity.statelessType == StatelessEntityType.missed) {
      return MissedEntityWidget();
    } else if (entityWrapper.entity.statelessType != StatelessEntityType.none) {
      return Container(width: 0.0, height: 0.0,);
    }
    List<Widget> result = [];
    if (card.showName) {
      result.add(_buildName(context));
    }
    result.add(
        EntityIcon(
          padding: EdgeInsets.all(0.0),
          size: Sizes.iconSize,
        )
    );
    if (card.showState) {
      result.add(_buildState());
    }

    return Center(
      child: InkResponse(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: result,
        ),
        onTap: () => entityWrapper.handleTap(),
        onLongPress: () => entityWrapper.handleHold(),
        onDoubleTap: () => entityWrapper.handleDoubleTap(),
      ),
    );
  }

  Widget _buildName(BuildContext context) {
    return EntityName(
      padding: EdgeInsets.only(bottom: Sizes.rowPadding),
      textOverflow: TextOverflow.ellipsis,
      wordsWrap: false,
      textAlign: TextAlign.center,
      textStyle: Theme.of(context).textTheme.body1,
    );
  }

  Widget _buildState() {
    return SimpleEntityState(
      textAlign: TextAlign.center,
      expanded: false,
      maxLines: 1,
      padding: EdgeInsets.only(top: Sizes.rowPadding),
    );
  }

}