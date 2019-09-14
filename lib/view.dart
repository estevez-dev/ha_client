part of 'main.dart';

class ViewWidget extends StatefulWidget {
  final HAView view;

  const ViewWidget({
    Key key,
    this.view
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ViewWidgetState();
  }

}

class ViewWidgetState extends State<ViewWidget> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.view.panel) {
      return FractionallySizedBox(
        widthFactor: 1,
        heightFactor: 1,
        child: _buildPanelChild(context),
      );
    } else {
      return ListView(
          shrinkWrap: true,
          padding: EdgeInsets.all(0),
          children: <Widget>[
            DynamicMultiColumnLayout(
              minColumnWidth: Sizes.minViewColumnWidth,
              children: _buildChildren(context),
            )
          ]
      );
      return ListView(
        shrinkWrap: true,
        padding: EdgeInsets.all(0),
        children: <Widget>[
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 3000),
            child: CustomMultiChildLayout(
              delegate: ViewLayoutBuilder(
                  cardsCount: widget.view.cards.length
              ),
              children: _buildChildren(context),
            ),
          )
        ],
      );
    }
  }

  Widget _buildPanelChild(BuildContext context) {
    if (widget.view.cards != null && widget.view.cards.isNotEmpty) {
      return widget.view.cards[0].build(context);
    } else {
      return Container(width: 0, height: 0);
    }
  }

  List<Widget> _buildChildren(BuildContext context) {
    List<Widget> result = [];
    int layoutChildId = 0;

    /*if (widget.view.badges.isNotEmpty) {
      result.add(
          LayoutId(
            id: "badges",
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 10.0,
              runSpacing: 1.0,
              children: _buildBadges(context),
            ),
          )
      );
    }*/
    widget.view.cards.forEach((HACard card){
      result.add(
          card.build(context)
      );
    });

    return result;
  }

  List<Widget> _buildBadges(BuildContext context) {
    List<Widget> result = [];
    widget.view.badges.forEach((Entity entity) {
      if (!entity.isHidden) {
        result.add(
            entity.buildBadgeWidget(context)
        );
      }
    });
    return result;
  }

  @override
  void dispose() {
    super.dispose();
  }

}

class ViewLayoutBuilder extends MultiChildLayoutDelegate {
  final int cardsCount;

  ViewLayoutBuilder({@required this.cardsCount});

  @override
  void performLayout(Size size) {
    int columnsCount = (size.width ~/ Sizes.minViewColumnWidth);
    double columnWidth = size.width / columnsCount;
    List<double> columnXPositions = [];
    List<double> columnYPositions = [];
    double startY = 0;
    if (hasChild("badges")) {
      Size badgesSizes = layoutChild(
          'badges', BoxConstraints.tightFor(width: size.width));
      startY += badgesSizes.height;
      positionChild('badges', Offset(0, 0));
    }
    for (int i =0; i < columnsCount; i++) {
      columnXPositions.add(i*columnWidth);
      columnYPositions.add(startY);
    }
    for (int i = 0; i < cardsCount; i++) {
      final String cardId = 'card_$i';

      if (hasChild(cardId)) {
        int columnToAdd = 0;
        double minYPosition = columnYPositions[0];
        for (int i=1; i<columnsCount; i++) {
          if (columnYPositions[i] < minYPosition) {
            minYPosition = columnYPositions[i];
            columnToAdd = i;
          }
        }
        Size newSize = layoutChild(
            '$cardId', BoxConstraints.tightFor(width: columnWidth));
        positionChild('$cardId', Offset(columnXPositions[columnToAdd], columnYPositions[columnToAdd]));
        columnYPositions[columnToAdd] = minYPosition + newSize.height;
      }
    }
  }

  @override
  bool shouldRelayout(MultiChildLayoutDelegate oldDelegate) => false;
}