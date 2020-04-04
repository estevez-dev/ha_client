part of '../../../main.dart';

class ModeSwitchWidget extends StatelessWidget {

  final String caption;
  final onChange;
  final bool value;
  final bool expanded;
  final EdgeInsets padding;

  ModeSwitchWidget({
    Key key,
    @required this.caption,
    @required this.onChange,
    this.value,
    this.expanded: true,
    this.padding: const EdgeInsets.only(left: Sizes.leftWidgetPadding, right: Sizes.rightWidgetPadding)
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: this.padding,
      child: Row(
        children: <Widget>[
          _buildCaption(context),
          Switch(
            onChanged: (value) => onChange(value),
            value: value ?? false,
          )
        ],
      )
    );
  }

  Widget _buildCaption(BuildContext context) {
    Widget captionWidget = Text(
      "$caption",
      style: Theme.of(context).textTheme.body1,
    );
    if (expanded) {
      return Expanded(
        child: captionWidget,
      );
    }
    return captionWidget;
  }

}