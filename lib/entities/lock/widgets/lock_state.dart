part of '../../../main.dart';

class LockStateWidget extends StatelessWidget {

  final bool assumedState;

  const LockStateWidget({Key key, this.assumedState: false}) : super(key: key);

  void _lock(Entity entity) {
    ConnectionManager().callService("lock", "lock", entity.entityId, null);
  }

  void _unlock(Entity entity) {
    ConnectionManager().callService("lock", "unlock", entity.entityId, null);
  }

  @override
  Widget build(BuildContext context) {
    final entityModel = EntityModel.of(context);
    final LockEntity entity = entityModel.entityWrapper.entity;
    if (assumedState) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
        SizedBox(
        height: 34.0,
        child: FlatButton(
          onPressed: () => _unlock(entity),
          child: Text("UNLOCK",
              textAlign: TextAlign.right,
              style:
              new TextStyle(fontSize: Sizes.stateFontSize, color: Colors.blue),
            ),
          )
        ),
        SizedBox(
            height: 34.0,
            child: FlatButton(
              onPressed: () => _lock(entity),
              child: Text("LOCK",
                textAlign: TextAlign.right,
                style:
                new TextStyle(fontSize: Sizes.stateFontSize, color: Colors.blue),
              ),
            )
        )
        ],
      );
    } else {
      return SizedBox(
          height: 34.0,
          child: FlatButton(
            onPressed: (() {
              entity.isLocked ? _unlock(entity) : _lock(entity);
            }),
            child: Text(
              entity.isLocked ? "UNLOCK" : "LOCK",
              textAlign: TextAlign.right,
              style:
              new TextStyle(fontSize: Sizes.stateFontSize, color: Colors.blue),
            ),
          )
      );
    }
  }
}