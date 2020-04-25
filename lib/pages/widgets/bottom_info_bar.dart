part of '../../main.dart';

class BottomInfoBarController {

  Function show;
  Function hide;

  String bottomBarText;
  bool bottomBarProgress;
  bool bottomBarErrorColor;
  Timer _bottomBarTimer;
  bool initialState = false;

  List<HAErrorAction> actions = [];

  void hideBottomBar() {
    _bottomBarTimer?.cancel();
    if (hide == null) {
      initialState = false;
    } else {
      hide();
    }
  }

  void showInfoBottomBar({String message, bool progress: false, Duration duration}) {
    _bottomBarTimer?.cancel();
    actions.clear();
    bottomBarErrorColor = false;
    bottomBarText = message;
    bottomBarProgress = progress;
    if (show == null) {
      initialState = true;
    } else {
      show();
    }
    if (duration != null) {
      _bottomBarTimer = Timer(duration, () {
        hideBottomBar();
      });
    }
  }

  void showErrorBottomBar(HAError error) {
    actions.clear();
    actions.addAll(error.actions);
    bottomBarErrorColor = true;
    bottomBarProgress = false;
    bottomBarText = "${error.message}";
    if (show == null) {
      initialState = true;
    } else {
      show();
    }
  }

}

class BottomInfoBar extends StatefulWidget {

  final BottomInfoBarController controller;

  const BottomInfoBar({Key key, this.controller}) : super(key: key);
  
  @override
  State<StatefulWidget> createState() {
    return new _BottomInfoBarState();
  }

}

class _BottomInfoBarState extends State<BottomInfoBar> {

  bool _show;

  @override
  void initState() {
    _show = widget.controller.initialState;
    widget.controller.show = () {
      setState(() {
        _show = true;
      });
    };
    widget.controller.hide = () {
      setState(() {
        _show = false;
      });
    };
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    if (!_show) {
      return Container(width: 0, height: 0,);
    } else {
      Widget bottomBar;
      List<Widget> bottomBarChildren = [];
      Widget actionsWidget;
      TextStyle textStyle = Theme.of(context).textTheme.button.copyWith(
        decoration: TextDecoration.underline
      );
      List<Widget> actions = [];
      widget.controller.actions.forEach((HAErrorAction action) {
        switch (action.type) {
          case HAErrorActionType.FULL_RELOAD: {
            actions.add(FlatButton(
              child: Text("${action.title}", style: textStyle),
              onPressed: () {
                eventBus.fire(FullReloadEvent());
              },
            ));
            break;
          }

          case HAErrorActionType.QUICK_RELOAD: {
            actions.add(FlatButton(
              child: Text("${action.title}", style: textStyle),
              onPressed: () {
                eventBus.fire(ReloadUIEvent());
              },
            ));
            break;
          }

          case HAErrorActionType.RELOGIN: {
            actions.add(FlatButton(
              child: Text("${action.title}", style: textStyle),
              onPressed: () {
                ConnectionManager().logout().then((_) => eventBus.fire(FullReloadEvent()));
              },
            ));
            break;
          }

          case HAErrorActionType.URL: {
            actions.add(FlatButton(
              child: Text("${action.title}", style: textStyle),
              onPressed: () {
                Launcher.launchURLInCustomTab(context: context, url: "${action.url}");
              },
            ));
            break;
          }

          case HAErrorActionType.OPEN_CONNECTION_SETTINGS: {
            actions.add(FlatButton(
              child: Text("${action.title}", style: textStyle),
              onPressed: () {
                Navigator.pushNamed(context, '/connection-settings');
              },
            ));
            break;
          }
        }
      });
      if (actions.isNotEmpty) {
        actionsWidget = Row(
          mainAxisSize: MainAxisSize.min,
          children: actions,
          mainAxisAlignment: MainAxisAlignment.end,
        );
      } else {
        actionsWidget = Container(height: 0.0, width: 0.0,);
      }

      if (widget.controller.bottomBarText != null) {
        bottomBarChildren.add(
            Padding(
              padding: EdgeInsets.fromLTRB(
                  Sizes.leftWidgetPadding, Sizes.rowPadding, 0.0,
                  Sizes.rowPadding),
              child: Text(
                "${widget.controller.bottomBarText}",
                textAlign: TextAlign.left,
                softWrap: true,
              ),
            )

        );
      }
      if (widget.controller.bottomBarProgress) {
        bottomBarChildren.add(
          LinearProgressIndicator(),
        );
      }
      if (bottomBarChildren.isNotEmpty) {
        bottomBar = Container(
          color: widget.controller.bottomBarErrorColor ? Theme.of(context).errorColor : Theme.of(context).primaryColorLight,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: widget.controller.bottomBarProgress ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: bottomBarChildren,
                ),
              ),
              actionsWidget
            ],
          ),
        );
      } else {
        bottomBar = Container(height: 0,);
      }
      return bottomBar;
    }
  } 
}