part of 'main.dart';

class ViewWidget extends StatelessWidget {
  final HAView view;

  const ViewWidget({
    Key key,
    this.view
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (this.view.isPanel) {
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
            _buildBadges(context),
            DynamicMultiColumnLayout(
              minColumnWidth: Sizes.minViewColumnWidth,
              children: this.view.cards.map((card) => card.build(context)).toList(),
            )
          ]
      );
    }
  }

  Widget _buildPanelChild(BuildContext context) {
    if (this.view.cards != null && this.view.cards.isNotEmpty) {
      return this.view.cards[0].build(context);
    } else {
      return Container(width: 0, height: 0);
    }
  }

  Widget _buildBadges(BuildContext context) {
    if (this.view.badges.isNotEmpty) {
      return Wrap(
        alignment: WrapAlignment.center,
        spacing: 10.0,
        runSpacing: 1.0,
        children: this.view.badges.map((badge) =>
            badge.buildBadgeWidget(context)).toList(),
      );
    } else {
      return Container(width: 0, height: 0,);
    }
  }

}