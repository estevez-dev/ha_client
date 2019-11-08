part of '../../main.dart';

class DateTimeEntity extends Entity {
  DateTimeEntity(Map rawData, String webHost) : super(rawData, webHost);

  bool get hasDate => attributes["has_date"] ?? false;
  bool get hasTime => attributes["has_time"] ?? false;
  int get year => attributes["year"] ?? 1970;
  int get month => attributes["month"] ?? 1;
  int get day => attributes["day"] ?? 1;
  int get hour => attributes["hour"] ?? 0;
  int get minute => attributes["minute"] ?? 0;
  int get second => attributes["second"] ?? 0;
  String get formattedState => _getFormattedState();
  DateTime get dateTimeState => _getDateTimeState();

  @override
  Widget _buildStatePart(BuildContext context) {
    return DateTimeStateWidget();
  }

  DateTime _getDateTimeState() {
    return DateTime(
        this.year, this.month, this.day, this.hour, this.minute, this.second);
  }

  String _getFormattedState() {
    String formattedState = "";
    if (this.hasDate) {
      formattedState += formatDate(dateTimeState, [M, ' ', d, ', ', yyyy]);
    }
    if (this.hasTime) {
      formattedState += " " + formatDate(dateTimeState, [HH, ':', nn]);
    }
    return formattedState;
  }

  void setNewState(Map newValue) {
    ConnectionManager().callService(domain: domain, service: "set_datetime", entityId: entityId, data: newValue);
  }
}