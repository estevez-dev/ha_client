part of '../../main.dart';

class EntityHistoryWidgetType {
  static const int simple = 0;
  static const int numericState = 1;
  static const int numericAttributes = 2;
}

class EntityHistoryConfig {
  final int chartType;
  final List<String> numericAttributesToShow;
  final bool numericState;

  EntityHistoryConfig({this.chartType, this.numericAttributesToShow, this.numericState: true});

}

class EntityHistoryWidget extends StatefulWidget {

  const EntityHistoryWidget({Key key}) : super(key: key);

  @override
  _EntityHistoryWidgetState createState() {
    return new _EntityHistoryWidgetState();
  }
}

class _EntityHistoryWidgetState extends State<EntityHistoryWidget> {

  List _history;
  bool _needToUpdateHistory;
  DateTime _historyLastUpdated;
  bool _disposed = false;
  Entity entity;

  @override
  void initState() {
    super.initState();
    _needToUpdateHistory = true;
  }

  void _loadHistory(String entityId) {
    DateTime now = DateTime.now();
    if (_historyLastUpdated != null) {
      Logger.d("History was updated ${now.difference(_historyLastUpdated).inSeconds} seconds ago");
    }
    if (_historyLastUpdated == null || now.difference(_historyLastUpdated).inSeconds > 30) {
      _historyLastUpdated = now;
      ConnectionManager().getHistory(entityId).then((history){
        if (!_disposed) {
          setState(() {
            _history = history.isNotEmpty ? history[0] : [];
            _needToUpdateHistory = false;
          });
        }
      }).catchError((e) {
        Logger.e("Error loading $entityId history: $e");
        if (!_disposed) {
          setState(() {
            _history = [];
            _needToUpdateHistory = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final EntityModel entityModel = EntityModel.of(context);
    final Entity entity = entityModel.entityWrapper.entity;
    if (!_needToUpdateHistory) {
      _needToUpdateHistory = true;
    } else {
      _loadHistory(entity.entityId);
    }
    return _buildChart(entity.historyConfig);
  }

  Widget _buildChart(EntityHistoryConfig config) {
    List<Widget> children = [];
    if (_history == null) {
      children.add(
          Text("Loading history...")
      );
    } else if (_history.isEmpty) {
      children.add(
          Text("No history")
      );
    } else {
      children.add(
          _selectChartWidget(config)
      );
    }
    children.add(Divider());
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, Sizes.rowPadding),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _selectChartWidget(EntityHistoryConfig config) {
    switch (config.chartType) {

      case EntityHistoryWidgetType.simple: {
          return SimpleStateHistoryChartWidget(
            rawHistory: _history,
          );
      }

      case EntityHistoryWidgetType.numericState: {
        return NumericStateHistoryChartWidget(
          rawHistory: _history,
          config: config,
        );
      }

      case EntityHistoryWidgetType.numericAttributes: {
        return CombinedHistoryChartWidget(
          rawHistory: _history,
          config: config,
        );
      }

      default: {
        Logger.d("  Simple selected as default");
        return SimpleStateHistoryChartWidget(
          rawHistory: _history,
        );
      }
    }

  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

}