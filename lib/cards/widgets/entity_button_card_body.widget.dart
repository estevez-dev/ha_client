part of '../../main.dart';

class EntityButtonCardBody extends StatelessWidget {

  final bool showName;

  EntityButtonCardBody({
    Key key, this.showName: true,
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

    return InkWell(
      onTap: () => entityWrapper.handleTap(),
      onLongPress: () => entityWrapper.handleHold(),
      child: FractionallySizedBox(
        widthFactor: 1,
        child: Column(
          children: <Widget>[
            LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return EntityIcon(
                    padding: EdgeInsets.fromLTRB(2.0, 6.0, 2.0, 2.0),
                    size: constraints.maxWidth / 2.5,
                  );
                }
            ),
            _buildName()
          ],
        ),
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
        textAlign: TextAlign.center,
        fontSize: Sizes.nameFontSize,
      );
    }
    return Container(width: 0, height: 0);
  }
}