import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;

class DynamicMultiColumnLayout extends MultiChildRenderObjectWidget {

  final int minColumnWidth;

  DynamicMultiColumnLayout({
    Key key,
    this.minColumnWidth: 350,
    List<Widget> children = const <Widget>[],
  }) : super(key: key, children: children);

  @override
  RenderCustomLayoutBox createRenderObject(BuildContext context) {
    return RenderCustomLayoutBox(minColumnWidth: this.minColumnWidth);
  }

}

class RenderCustomLayoutBox extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, CustomLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, CustomLayoutParentData> {

  final int minColumnWidth;

  RenderCustomLayoutBox({
    this.minColumnWidth,
    List<RenderBox> children,
  }) {
    addAll(children);
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! CustomLayoutParentData) {
      child.parentData = CustomLayoutParentData();
    }
  }

  double _getIntrinsicHeight(double childSize(RenderBox child)) {
    double inflexibleSpace = 0.0;
    RenderBox child = firstChild;
    while (child != null) {
      inflexibleSpace += childSize(child);
      final FlexParentData childParentData = child.parentData;
      child = childParentData.nextSibling;
    }
    return inflexibleSpace;
  }

  double _getIntrinsicWidth(double childSize(RenderBox child)) {
    double maxSpace = 0.0;
    RenderBox child = firstChild;
    while (child != null) {
      maxSpace = math.max(maxSpace, childSize(child));
      final FlexParentData childParentData = child.parentData;
      child = childParentData.nextSibling;
    }
    return maxSpace;
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return _getIntrinsicWidth((RenderBox child) => child.getMinIntrinsicWidth(height));
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return _getIntrinsicWidth((RenderBox child) => child.getMaxIntrinsicWidth(height));
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return _getIntrinsicHeight((RenderBox child) => child.getMinIntrinsicHeight(width));
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return _getIntrinsicHeight((RenderBox child) => child.getMaxIntrinsicHeight(width));
  }

  @override
  void performLayout() {
    int columnsCount;
    List<double> columnXPositions = [];
    List<double> columnYPositions = [];
    if (childCount == 0) {
      size = constraints.biggest;
      assert(size.isFinite);
      return;
    }

    columnsCount = (constraints.maxWidth ~/ this.minColumnWidth);
    double columnWidth = constraints.maxWidth / columnsCount;
    double startY = 0;
    for (int i =0; i < columnsCount; i++) {
      columnXPositions.add(i*columnWidth);
      columnYPositions.add(startY);
    }
    RenderBox child = firstChild;
    while (child != null) {
      final CustomLayoutParentData childParentData = child.parentData;

      int columnToAdd = 0;
      double minYPosition = columnYPositions[0];
      for (int i=0; i<columnsCount; i++) {
        if (columnYPositions[i] < minYPosition) {
          minYPosition = columnYPositions[i];
          columnToAdd = i;
        }
      }
      child.layout(BoxConstraints.tightFor(width: columnWidth), parentUsesSize: true);
      childParentData.offset = Offset(columnXPositions[columnToAdd], columnYPositions[columnToAdd]);
      final Size newSize = child.size;
      columnYPositions[columnToAdd] = minYPosition + newSize.height;

      child = childParentData.nextSibling;
    }

    double width = constraints.maxWidth;
    double height = 0;
    for (int i=0; i<columnsCount; i++) {
      if (columnYPositions[i] > height) {
        height = columnYPositions[i];
      }
    }

    size = Size(width, height);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(HitTestResult result, { Offset position }) {
    return defaultHitTestChildren(result, position: position);
  }
}

class CustomLayoutParentData extends ContainerBoxParentData<RenderBox> {

}