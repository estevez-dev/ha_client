import 'package:flutter/material.dart';

class SpoilerCard extends StatefulWidget {

  final String title;
  final Widget body;
  final bool isExpanded;

  SpoilerCard({Key key, @required this.title, @required this.body, this.isExpanded: false}) : super(key: key);

  @override
  _SpoilerCardState createState() => _SpoilerCardState();
}

class _SpoilerCardState extends State<SpoilerCard> {

  bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.isExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: Text("${widget.title}"),
            trailing: Icon(
              _expanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              size: 20,
            ),
            onTap: () => setState((){_expanded = !_expanded;}),
          ),
          _expanded ? widget.body : Container(height: 0,)
        ],
      ),
    );
  }
}