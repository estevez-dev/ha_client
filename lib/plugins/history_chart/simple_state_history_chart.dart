part of '../../main.dart';

class SimpleStateHistoryChartWidget extends StatefulWidget {
  final rawHistory;

  const SimpleStateHistoryChartWidget({Key key, this.rawHistory}) : super(key: key);


  @override
  State<StatefulWidget> createState() {
    return new _SimpleStateHistoryChartWidgetState();
  }

}

class _SimpleStateHistoryChartWidgetState extends State<SimpleStateHistoryChartWidget> {

  int _selectedId = -1;
  List<charts.Series<EntityHistoryMoment, DateTime>> _parsedHistory;

  @override
  Widget build(BuildContext context) {
    _parsedHistory = _parseHistory();
    DateTime selectedTimeStart;
    DateTime selectedTimeEnd;
    String selectedState;
    if ((_selectedId > -1) && (_parsedHistory != null) && (_parsedHistory.first.data.length >= (_selectedId + 1))) {
      selectedTimeStart = _parsedHistory.first.data[_selectedId].startTime;
      selectedTimeEnd = _parsedHistory.first.data[_selectedId].endTime;
      selectedState = _parsedHistory.first.data[_selectedId].state;
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        HistoryControlWidget(
          selectedTimeStart: selectedTimeStart,
          selectedTimeEnd: selectedTimeEnd,
          selectedStates: [selectedState],
          onPrevTap: () => _selectPrev(),
          onNextTap: () => _selectNext(),
          colorIndexes: [_parsedHistory.first.data[_selectedId].colorId],
        ),
        SizedBox(
          height: 70.0,
          child: charts.TimeSeriesChart(
            _parsedHistory,
            animate: false,
            dateTimeFactory: const charts.LocalDateTimeFactory(),
            primaryMeasureAxis: charts.NumericAxisSpec(
                renderSpec: charts.NoneRenderSpec()
            ),
            selectionModels: [
              new charts.SelectionModelConfig(
                type: charts.SelectionModelType.info,
                changedListener: (model) => _onSelectionChanged(model),
              )
            ],
            customSeriesRenderers: [
              new charts.PointRendererConfig(
                // ID used to link series to this renderer.
                  customRendererId: 'startValuePoints'),
              new charts.PointRendererConfig(
                // ID used to link series to this renderer.
                  customRendererId: 'endValuePoints')
            ],
          ),
        )
      ],
    );
  }

  List<charts.Series<EntityHistoryMoment, DateTime>> _parseHistory() {
    List<EntityHistoryMoment> data = [];
    DateTime now = DateTime.now();
    Map<String, int> cachedStates = {};
    for (var i = 0; i < widget.rawHistory.length; i++) {
      var stateData = widget.rawHistory[i];
      DateTime startTime = DateTime.tryParse(stateData["last_updated"])?.toLocal();
      DateTime endTime;
      if (i < (widget.rawHistory.length - 1)) {
        endTime = DateTime.tryParse(widget.rawHistory[i+1]["last_updated"])?.toLocal();
      } else {
        endTime = now;
      }
      if (cachedStates[stateData["state"]] == null) {
        cachedStates.addAll({"${stateData["state"]}": cachedStates.length});
      }
      data.add(EntityHistoryMoment(
        state: stateData["state"],
        startTime: startTime,
        endTime: endTime,
        id: i,
        colorId: cachedStates[stateData["state"]]
      ));
    }
    data.add(EntityHistoryMoment(
        state: data.last.state,
        startTime: now,
        id: widget.rawHistory.length,
        colorId: data.last.colorId
    ));
    if (_selectedId == -1) {
      _selectedId = data.length - 1;
    }
    return [
      new charts.Series<EntityHistoryMoment, DateTime>(
        id: 'State',
        strokeWidthPxFn: (EntityHistoryMoment historyMoment, __) => (historyMoment.id == _selectedId) ? 6.0 : 3.0,
        colorFn: (EntityHistoryMoment historyMoment, __) => EntityColor.chartHistoryStateColor(historyMoment.state, historyMoment.colorId),
        domainFn: (EntityHistoryMoment historyMoment, _) => historyMoment.startTime,
        measureFn: (EntityHistoryMoment historyMoment, _) => 10,
        data: data,
      ),
      new charts.Series<EntityHistoryMoment, DateTime>(
        id: 'State',
        radiusPxFn: (EntityHistoryMoment historyMoment, __) => (historyMoment.id == _selectedId) ? 5.0 : 3.0,
        colorFn: (EntityHistoryMoment historyMoment, __) => EntityColor.chartHistoryStateColor(historyMoment.state, historyMoment.colorId),
        domainFn: (EntityHistoryMoment historyMoment, _) => historyMoment.startTime,
        measureFn: (EntityHistoryMoment historyMoment, _) => 10,
        data: data,
      )..setAttribute(charts.rendererIdKey, 'startValuePoints'),
      new charts.Series<EntityHistoryMoment, DateTime>(
        id: 'State',
        radiusPxFn: (EntityHistoryMoment historyMoment, __) => (historyMoment.id == _selectedId) ? 5.0 : 3.0,
        colorFn: (EntityHistoryMoment historyMoment, __) => EntityColor.chartHistoryStateColor(historyMoment.state, historyMoment.colorId),
        domainFn: (EntityHistoryMoment historyMoment, _) => historyMoment.endTime ?? DateTime.now(),
        measureFn: (EntityHistoryMoment historyMoment, _) => 10,
        data: data,
      )..setAttribute(charts.rendererIdKey, 'endValuePoints')
    ];
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

    if ((selectedDatum.isNotEmpty) &&(selectedDatum.first.datum.endTime != null)) {
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

/*
class SimpleEntityStateHistoryMoment {
  final DateTime startTime;
  final DateTime endTime;
  final String state;
  final int id;
  final int colorId;

  SimpleEntityStateHistoryMoment(this.state, this.startTime, this.endTime,  this.id, this.colorId);
}*/
