part of '../../../main.dart';

class LightColorPicker extends StatefulWidget {

  final HSVColor color;
  final onColorSelected;
  final double hueStep;
  final double saturationStep;
  final EdgeInsets padding;

  LightColorPicker({this.color, this.onColorSelected, this.hueStep: 15.0, this.saturationStep: 0.2, this.padding: const EdgeInsets.fromLTRB(Sizes.leftWidgetPadding, Sizes.rowPadding, Sizes.rightWidgetPadding, 0.0)});

  @override
  LightColorPickerState createState() => new LightColorPickerState();
}

class LightColorPickerState extends State<LightColorPicker> {

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    List<Widget> colorRows = [];
    Border border;
    bool isSomethingSelected = false;
    for (double saturation = 1.0; saturation >= (0.0 + widget.saturationStep); saturation = double.parse((saturation - widget.saturationStep).toStringAsFixed(2))) {
      List<Widget> rowChildren = [];
      //Logger.d("$saturation");
      double roundedSaturation = double.parse(widget.color.saturation.toStringAsFixed(1));
      //Logger.d("Rounded saturation=$roundedSaturation");
      for (double hue = 0; hue <= (365 - widget.hueStep);
      hue += widget.hueStep) {
        bool isExactHue = widget.color.hue.round() == hue;
        bool isHueInRange = widget.color.hue.round() > hue && widget.color.hue.round() < (hue+widget.hueStep);
        bool isExactSaturation = roundedSaturation == saturation;
        bool isSaturationInRange = roundedSaturation > saturation && roundedSaturation < double.parse((saturation+widget.saturationStep).toStringAsFixed(1));
        if ((isExactHue || isHueInRange) && (isExactSaturation || isSaturationInRange)) {
          //Logger.d("$isExactHue $isHueInRange $isExactSaturation $isSaturationInRange (${saturation+widget.saturationStep})");
          border = Border.all(
            width: 2.0,
            color: Colors.white,
          );
          isSomethingSelected = true;
        } else {
          border = null;
        }
        HSVColor currentColor = HSVColor.fromAHSV(1.0, hue, double.parse(saturation.toStringAsFixed(2)), 1.0);
        rowChildren.add(
            Flexible(
                child: GestureDetector(
                  child: Container(
                    height: 40.0,
                    decoration: BoxDecoration(
                        color: currentColor.toColor(),
                        border: border,
                    ),
                  ),
                  onTap: () => widget.onColorSelected(currentColor),
                )
            )
        );
      }
      colorRows.add(
          Row(
            children: rowChildren,
          )
      );
    }
    colorRows.add(
        Flexible(
            child: GestureDetector(
              child: Container(
                height: 40.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: isSomethingSelected ? null : Border.all(
                    width: 2.0,
                    color: Colors.amber[200],
                  )
                ),
              ),
              onTap: () => widget.onColorSelected(HSVColor.fromAHSV(1.0, 30.0, 0.0, 1.0)),
            )
        )
    );
    return Padding(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: colorRows,
      ),
      padding: widget.padding,
    );

  }
}