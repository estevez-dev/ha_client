part of '../../../main.dart';

class ModeSelectorWidget extends StatelessWidget {

  final String caption;
  final List options;
  final String value;
  final onChange;
  final EdgeInsets padding;

  ModeSelectorWidget({
    Key key,
    @required this.caption,
    this.options: const [],
    this.value,
    @required this.onChange,
    this.padding: const EdgeInsets.fromLTRB(Sizes.leftWidgetPadding, Sizes.rowPadding, Sizes.rightWidgetPadding, 0.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("$caption", style: Theme.of(context).textTheme.body1),
          Row(
            children: <Widget>[
              Expanded(
                child: ButtonTheme(
                  alignedDropdown: true,
                  child: DropdownButton<String>(
                    value: value,
                    iconSize: 30.0,
                    isExpanded: true,
                    style: Theme.of(context).textTheme.title,
                    hint: Text("Select ${caption.toLowerCase()}"),
                    items: options.map((value) {
                      return new DropdownMenuItem<String>(
                        value: '$value',
                        child: Text('$value'),
                      );
                    }).toList(),
                    onChanged: (mode) => onChange(mode),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}