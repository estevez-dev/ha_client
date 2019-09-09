part of '../../main.dart';

class HistoryControlWidget extends StatelessWidget {

  final Function onPrevTap;
  final Function onNextTap;
  final DateTime selectedTimeStart;
  final DateTime selectedTimeEnd;
  final List<String> selectedStates;
  final List<int> colorIndexes;

  const HistoryControlWidget({Key key, this.onPrevTap, this.onNextTap, this.selectedTimeStart, this.selectedTimeEnd, this.selectedStates, @ required this.colorIndexes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (selectedTimeStart != null) {
      return
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.chevron_left),
              padding: EdgeInsets.all(0.0),
              iconSize: 40.0,
              onPressed: onPrevTap,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: 10.0),
                child: _buildStates(),
              ),
            ),
            _buildTime(),
            IconButton(
              icon: Icon(Icons.chevron_right),
              padding: EdgeInsets.all(0.0),
              iconSize: 40.0,
              onPressed: onNextTap,
            ),
          ],
        );

    } else {
      return Container(height: 48.0);
    }
  }

  Widget _buildStates() {
    List<Widget> children = [];
    for (int i = 0; i < selectedStates.length; i++) {
      children.add(
          Text(
            "${selectedStates[i] ?? '-'}",
            textAlign: TextAlign.right,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: EntityColor.historyStateColor(selectedStates[i], colorIndexes[i]),
                fontSize: 22.0
            ),
          )
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: children,
    );
  }

  Widget _buildTime() {
    List<Widget> children = [];
    children.add(
        Text("${formatDate(selectedTimeStart, [M, ' ', d, ', ', HH, ':', nn, ':', ss])}", textAlign: TextAlign.left,)
    );
    if (selectedTimeEnd != null) {
      children.add(
          Text("${formatDate(selectedTimeEnd, [M, ' ', d, ', ', HH, ':', nn, ':', ss])}", textAlign: TextAlign.left,)
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

}