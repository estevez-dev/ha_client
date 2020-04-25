part of '../main.dart';

class EntityName extends StatelessWidget {

  final EdgeInsetsGeometry padding;
  final TextOverflow textOverflow;
  final bool wordsWrap;
  final TextAlign textAlign;
  final int maxLines;
  final TextStyle textStyle;

  const EntityName({Key key, this.maxLines, this.padding: const EdgeInsets.only(right: 10.0), this.textOverflow: TextOverflow.ellipsis, this.textStyle, this.wordsWrap: true, this.textAlign: TextAlign.left}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final EntityWrapper entityWrapper = EntityModel.of(context).entityWrapper;
    TextStyle tStyle;
    if (textStyle == null) {
      if (entityWrapper.entity.statelessType == StatelessEntityType.webLink) {
        tStyle = HAClientTheme().getLinkTextStyle(context);
      } else {
        tStyle = Theme.of(context).textTheme.body1;
      }
    } else {
      tStyle = textStyle;
    }
    return Padding(
      padding: padding,
      child: Text(
        "${entityWrapper.displayName}",
        overflow: textOverflow,
        softWrap: wordsWrap,
        maxLines: maxLines,
        style: tStyle,
        textAlign: textAlign,
      ),
    );
  }
}