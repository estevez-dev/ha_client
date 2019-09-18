part of '../main.dart';

class EntityName extends StatelessWidget {

  final EdgeInsetsGeometry padding;
  final TextOverflow textOverflow;
  final bool wordsWrap;
  final double fontSize;
  final TextAlign textAlign;
  final int maxLines;

  const EntityName({Key key, this.maxLines, this.padding: const EdgeInsets.only(right: 10.0), this.textOverflow: TextOverflow.ellipsis, this.wordsWrap: true, this.fontSize: Sizes.nameFontSize, this.textAlign: TextAlign.left}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final EntityWrapper entityWrapper = EntityModel.of(context).entityWrapper;
    TextStyle textStyle = TextStyle(fontSize: fontSize);
    if (entityWrapper.entity.statelessType == StatelessEntityType.WEBLINK) {
      textStyle = textStyle.apply(color: Colors.blue, decoration: TextDecoration.underline);
    }
    return Padding(
      padding: padding,
      child: Text(
        "${entityWrapper.displayName}",
        overflow: textOverflow,
        softWrap: wordsWrap,
        maxLines: maxLines,
        style: textStyle,
        textAlign: textAlign,
      ),
    );
  }
}