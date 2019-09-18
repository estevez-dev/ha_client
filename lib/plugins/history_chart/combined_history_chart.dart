part of '../../main.dart';

class CombinedHistoryChartWidget extends StatefulWidget {
  final rawHistory;
  final EntityHistoryConfig config;

  const CombinedHistoryChartWidget({Key key, @required this.rawHistory, @required this.config}) : super(key: key);


  @override
  State<StatefulWidget> createState() {
    return new _CombinedHistoryChartWidgetState();
  }

}

class _CombinedHistoryChartWidgetState extends State<CombinedHistoryChartWidget> {

  int _selectedId = -1;
  List<charts.Series<EntityHistoryMoment, DateTime>> _parsedHistory;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _parsedHistory = _parseHistory();
    DateTime selectedTime;
    List<String> selectedStates = [];
    List<int> colorIndexes = [];
    if ((_selectedId > -1) && (_parsedHistory != null) && (_parsedHistory.first.data.length >= (_selectedId + 1))) {
      selectedTime = _parsedHistory.first.data[_selectedId].startTime;
      _parsedHistory.where((item) { return item.id == "state"; }).forEach((item) {
        selectedStates.add(item.data[_selectedId].state);
        colorIndexes.add(item.data[_selectedId].colorId);
      });
      _parsedHistory.where((item) { return item.id == "value"; }).forEach((item) {
        selectedStates.add("${item.data[_selectedId].value ?? '-'}");
        colorIndexes.add(item.data[_selectedId].colorId);
      });
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        HistoryControlWidget(
          selectedTimeStart: selectedTime,
          selectedStates: selectedStates,
          onPrevTap: () => _selectPrev(),
          onNextTap: () => _selectNext(),
          colorIndexes: colorIndexes,
        ),
        SizedBox(
          height: 150.0,
          child: charts.TimeSeriesChart(
            _parsedHistory,
            animate: false,
            primaryMeasureAxis: new charts.NumericAxisSpec(
                tickProviderSpec:
                new charts.BasicNumericTickProviderSpec(zeroBound: false)),
            dateTimeFactory: const charts.LocalDateTimeFactory(),
            defaultRenderer: charts.LineRendererConfig(
              includeArea: false,
              includePoints: true
            ),
            selectionModels: [
              new charts.SelectionModelConfig(
                type: charts.SelectionModelType.info,
                changedListener: (model) => _onSelectionChanged(model),
              )
            ],
            customSeriesRenderers: [
              new charts.SymbolAnnotationRendererConfig(
                customRendererId: "stateBars"
              )
            ],
          ),
        )
      ],
    );
  }

  double _parseToDouble(temp1) {
    if (temp1 is int) {
      return temp1.toDouble();
    } else if (temp1 is double) {
      return temp1;
    } else {
      return double.tryParse("$temp1");
    }
  }

  List<charts.Series<EntityHistoryMoment, DateTime>> _parseHistory() {
    Logger.d("  parsing history...");
    Map<String, List<EntityHistoryMoment>> numericDataLists = {};
    int colorIdCounter = 0;
    widget.config.numericAttributesToShow.forEach((String attrName) {
      Logger.d("    parsing attribute $attrName");
      List<EntityHistoryMoment> data = [];
      DateTime now = DateTime.now();
      for (var i = 0; i < widget.rawHistory.length; i++) {
        var stateData = widget.rawHistory[i];
        DateTime startTime = DateTime.tryParse(stateData["last_updated"])?.toLocal();
        DateTime endTime;
        bool hiddenLine;
        double value;
        double previousValue = 0.0;
        value = _parseToDouble(stateData["attributes"]["$attrName"]);
        bool hiddenDot = (value == null);
        if (hiddenDot && i > 0) {
          previousValue = data[i-1].value ?? data[i-1].previousValue;
        }
        if (i < (widget.rawHistory.length - 1)) {
          endTime = DateTime.tryParse(widget.rawHistory[i+1]["last_updated"])?.toLocal();
          double nextValue = _parseToDouble(widget.rawHistory[i+1]["attributes"]["$attrName"]);
          hiddenLine = (nextValue == null || hiddenDot);
        } else {
          hiddenLine = hiddenDot;
          endTime = now;
        }
        data.add(EntityHistoryMoment(
          value: value,
          previousValue: previousValue,
          hiddenDot: hiddenDot,
          hiddenLine: hiddenLine,
          state: stateData["state"],
          startTime: startTime,
          endTime: endTime,
          id: i,
          colorId: colorIdCounter
        ));
      }
      data.add(EntityHistoryMoment(
          value: data.last.value,
          previousValue: data.last.previousValue,
          hiddenDot: data.last.hiddenDot,
          hiddenLine: data.last.hiddenLine,
          state: data.last.state,
          startTime: now,
          id: widget.rawHistory.length,
          colorId: colorIdCounter
      ));
      numericDataLists.addAll({attrName: data});
      colorIdCounter += 1;
    });

    if ((_selectedId == -1) && (numericDataLists.isNotEmpty)) {
      _selectedId = numericDataLists.length -1;
    }
    List<charts.Series<EntityHistoryMoment, DateTime>> result = [];
    numericDataLists.forEach((attrName, dataList) {
      Logger.d("  adding ${dataList.length} data values");
      result.add(
        new charts.Series<EntityHistoryMoment, DateTime>(
          id: "value",
          colorFn: (EntityHistoryMoment historyMoment, __) => EntityColor.chartHistoryStateColor("_", historyMoment.colorId),
          radiusPxFn: (EntityHistoryMoment historyMoment, __) {
              if (historyMoment.hiddenDot) {
                return 0.0;
              } else if (historyMoment.id == _selectedId) {
                return 5.0;
              } else {
                return 1.0;
              }
            },
          strokeWidthPxFn: (EntityHistoryMoment historyMoment, __) => historyMoment.hiddenLine ? 0.0 : 2.0,
          domainFn: (EntityHistoryMoment historyMoment, _) => historyMoment.startTime,
          measureFn: (EntityHistoryMoment historyMoment, _) => historyMoment.value ?? historyMoment.previousValue,
          data: dataList,
          /*domainLowerBoundFn: (CombinedEntityStateHistoryMoment historyMoment, _) => historyMoment.time.subtract(Duration(hours: 1)),
          domainUpperBoundFn: (CombinedEntityStateHistoryMoment historyMoment, _) => historyMoment.time.add(Duration(hours: 1)),*/
        )
      );
    });
    result.add(
        new charts.Series<EntityHistoryMoment, DateTime>(
          id: 'state',
          radiusPxFn: (EntityHistoryMoment historyMoment, __) => (historyMoment.id == _selectedId) ? 5.0 : 4.0,
          colorFn: (EntityHistoryMoment historyMoment, __) => EntityColor.chartHistoryStateColor(historyMoment.state, historyMoment.colorId),
          domainFn: (EntityHistoryMoment historyMoment, _) => historyMoment.startTime,
          domainLowerBoundFn: (EntityHistoryMoment historyMoment, _) => historyMoment.startTime,
          domainUpperBoundFn: (EntityHistoryMoment historyMoment, _) => historyMoment.endTime ?? DateTime.now(),
          // No measure values are needed for symbol annotations.
          measureFn: (_, __) => null,
          data: numericDataLists[numericDataLists.keys.first],
        )
        // Configure our custom symbol annotation renderer for this series.
          ..setAttribute(charts.rendererIdKey, 'stateBars')
        // Optional radius for the annotation shape. If not specified, this will
        // default to the same radius as the points.
          //..setAttribute(charts.boundsLineRadiusPxKey, 3.5)
    );
    return result;
  }

  void _selectPrev() {
    if (_selectedId > 0) {
      setState(() {
        _selectedId -= 1;
      });
    }
    else {
      setState(() {
        _selectedId = _parsedHistory.first.data.length - 1;
      });
    }
  }

  void _selectNext() {
    if (_selectedId < (_parsedHistory.first.data.length - 1)) {
      setState(() {
        _selectedId += 1;
      });
    }
    else {
      setState(() {
        _selectedId = 0;
      });

    }
  }

  void _onSelectionChanged(charts.SelectionModel model) {
    final selectedDatum = model.selectedDatum;

    int selectedId;

    if (selectedDatum.isNotEmpty) {
      selectedId = selectedDatum.first.datum.id;
      setState(() {
        _selectedId = selectedId;
      });
    } else {
      setState(() {
      });
    }
  }
}
