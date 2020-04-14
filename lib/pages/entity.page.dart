part of '../main.dart';

class EntityViewPage extends StatefulWidget {
  EntityViewPage({Key key, @required this.entityId}) : super(key: key);

  final String entityId;

  @override
  _EntityViewPageState createState() => new _EntityViewPageState();
}

class _EntityViewPageState extends State<EntityViewPage> {
  StreamSubscription _refreshDataSubscription;
  StreamSubscription _stateSubscription;
  Entity _entity;

  @override
  void initState() {
    super.initState();
    _stateSubscription = eventBus.on<StateChangedEvent>().listen((event) {
      if (event.entityId == widget.entityId) {
        Logger.d("[Entity page] State change event handled: ${event.entityId}");
        setState(() {
          _getEntity();
        });
      }
    });
    _refreshDataSubscription = eventBus.on<RefreshDataFinishedEvent>().listen((event) {
      Logger.d("[Entity page] Refresh data event handled");
      setState(() {
        _getEntity();
      });
    });
    _getEntity();
  }

  _getEntity() {
    _entity = HomeAssistant().entities.get(widget.entityId);
  }

  @override
  Widget build(BuildContext context) {
    String entityNameToDisplay = '${(_entity?.displayName ?? widget.entityId) ?? ''}';
    return new Scaffold(
      appBar: new AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: (){
          Navigator.pop(context);
        }),
        title: new Text(entityNameToDisplay),
      ),
      body: _entity == null ? PageLoadingError(
        errorText: 'Entity is not available $entityNameToDisplay',
      ) : EntityPageLayout(entity: _entity),
    );
  }

  @override
  void dispose(){
    if (_stateSubscription != null) _stateSubscription.cancel();
    if (_refreshDataSubscription != null) _refreshDataSubscription.cancel();
    super.dispose();
  }
}