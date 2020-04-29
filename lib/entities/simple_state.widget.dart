part of '../main.dart';

class SimpleEntityState extends StatelessWidget {

  final bool expanded;
  final TextAlign textAlign;
  final EdgeInsetsGeometry padding;
  final int maxLines;
  final String customValue;
  final TextStyle textStyle;
  //final bool bold;

  const SimpleEntityState({Key key,/*this.bold: false,*/ this.maxLines: 10, this.expanded: true, this.textAlign: TextAlign.right, this.textStyle, this.padding: const EdgeInsets.fromLTRB(0.0, 0.0, Sizes.rightWidgetPadding, 0.0), this.customValue}) : super(key: key);

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
    TextStyle tStyle;
    if (textStyle != null) {
      tStyle = textStyle;
    } else if (entityModel.entityWrapper.entity.statelessType == StatelessEntityType.callService) {
      tStyle = Theme.of(context).textTheme.subhead.copyWith(
        color: HAClientTheme().getLinkTextStyle(context).color
      );
    } else {
      tStyle = Theme.of(context).textTheme.body1;
    }
    /*if (this.bold) {
      textStyle = textStyle.apply(fontWeightDelta: 100);
    }*/
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
        style: tStyle
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
