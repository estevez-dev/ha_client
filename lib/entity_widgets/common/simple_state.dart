part of '../../main.dart';

class SimpleEntityState extends StatelessWidget {

  final bool expanded;
  final TextAlign textAlign;
  final EdgeInsetsGeometry padding;
  final int maxLines;
  final String customValue;
  final double fontSize;
  final bool bold;

  const SimpleEntityState({Key key,this.bold: false, this.maxLines: 10, this.fontSize: Sizes.stateFontSize, this.expanded: true, this.textAlign: TextAlign.right, this.padding: const EdgeInsets.fromLTRB(0.0, 0.0, Sizes.rightWidgetPadding, 0.0), this.customValue}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final entityModel = EntityModel.of(context);
    String state;
    if (customValue == null) {
      state = entityModel.entityWrapper.entity.displayState ?? "";
      state = state.replaceAll("\n", "").replaceAll("\t", " ").trim();
    } else {
      state = customValue;
    }
    TextStyle textStyle =  TextStyle(
      fontSize: this.fontSize,
      fontWeight: FontWeight.normal
    );
    if (entityModel.entityWrapper.entity.statelessType == StatelessEntityType.CALL_SERVICE) {
      textStyle = textStyle.apply(color: Colors.blue);
    }
    if (this.bold) {
      textStyle = textStyle.apply(fontWeightDelta: 100);
    }
    while (state.contains("  ")){
      state = state.replaceAll("  ", " ");
    }
    Widget result = Padding(
      padding: padding,
      child: Text(
        "$state ${entityModel.entityWrapper.unitOfMeasurement}",
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        softWrap: true,
        style: textStyle
      )
    );
    if (expanded) {
      return Flexible(
        fit: FlexFit.tight,
        flex: 2,
        child: result,
      );
    } else {
      return result;
    }
  }
}
