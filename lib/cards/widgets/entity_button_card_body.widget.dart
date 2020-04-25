part of '../../main.dart';

class EntityButtonCardBody extends StatelessWidget {

  final bool showName;
  final int depth;

  EntityButtonCardBody({
    Key key, this.showName: true, @required this.depth
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final EntityWrapper entityWrapper = EntityModel.of(context).entityWrapper;
    if (entityWrapper.entity.statelessType == StatelessEntityType.MISSED) {
      return MissedEntityWidget();
    }
    if (entityWrapper.entity.statelessType > StatelessEntityType.MISSED) {
      return Container(width: 0.0, height: 0.0,);
    }
    double widthBase =  math.min(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height) / 6;
    return InkWell(
      onTap: () => entityWrapper.handleTap(),
      onLongPress: () => entityWrapper.handleHold(),
      onDoubleTap: () => entityWrapper.handleDoubleTap(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          EntityIcon(
            padding: EdgeInsets.fromLTRB(2.0, 6.0, 2.0, 2.0),
            size: widthBase / (depth * 0.5),
          ),
          _buildName()
        ],
      ),
    );
  }

  Widget _buildName() {
    if (showName) {
      return EntityName(
        padding: EdgeInsets.fromLTRB(Sizes.buttonPadding, 0.0, Sizes.buttonPadding, Sizes.rowPadding),
        textOverflow: TextOverflow.ellipsis,
        maxLines: 3,
        wordsWrap: true,
        textAlign: TextAlign.center
      );
    }
    return Container(width: 0, height: 0);
  }
}