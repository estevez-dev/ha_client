part of '../../main.dart';

class VacuumEntity extends Entity {

  static const SUPPORT_TURN_ON = 1;
  static const SUPPORT_TURN_OFF = 2;
  static const SUPPORT_PAUSE = 4;
  static const SUPPORT_STOP = 8;
  static const SUPPORT_RETURN_HOME = 16;
  static const SUPPORT_FAN_SPEED = 32;
  static const SUPPORT_BATTERY = 64;
  static const SUPPORT_STATUS = 128;
  static const SUPPORT_SEND_COMMAND = 256;
  static const SUPPORT_LOCATE = 512;
  static const SUPPORT_CLEAN_SPOT = 1024;
  static const SUPPORT_MAP = 2048;
  static const SUPPORT_STATE = 4096;
  static const SUPPORT_START = 8192;

  VacuumEntity(Map rawData, String webHost) : super(rawData, webHost);

  bool get supportTurnOn => ((supportedFeatures &
  VacuumEntity.SUPPORT_TURN_ON) ==
      VacuumEntity.SUPPORT_TURN_ON);
  bool get supportTurnOff => ((supportedFeatures &
  VacuumEntity.SUPPORT_TURN_OFF) ==
      VacuumEntity.SUPPORT_TURN_OFF);
  bool get supportPause => ((supportedFeatures &
  VacuumEntity.SUPPORT_PAUSE) ==
      VacuumEntity.SUPPORT_PAUSE);
  bool get supportStop => ((supportedFeatures &
  VacuumEntity.SUPPORT_STOP) ==
      VacuumEntity.SUPPORT_STOP);
  bool get supportReturnHome => ((supportedFeatures &
  VacuumEntity.SUPPORT_RETURN_HOME) ==
      VacuumEntity.SUPPORT_RETURN_HOME);
  bool get supportFanSpeed => ((supportedFeatures &
  VacuumEntity.SUPPORT_FAN_SPEED) ==
      VacuumEntity.SUPPORT_FAN_SPEED);
  bool get supportBattery => ((supportedFeatures &
  VacuumEntity.SUPPORT_BATTERY) ==
      VacuumEntity.SUPPORT_BATTERY);
  bool get supportStatus => ((supportedFeatures &
  VacuumEntity.SUPPORT_STATUS) ==
      VacuumEntity.SUPPORT_STATUS);
  bool get supportSendCommand => ((supportedFeatures &
  VacuumEntity.SUPPORT_SEND_COMMAND) ==
      VacuumEntity.SUPPORT_SEND_COMMAND);
  bool get supportLocate => ((supportedFeatures &
  VacuumEntity.SUPPORT_LOCATE) ==
      VacuumEntity.SUPPORT_LOCATE);
  bool get supportCleanSpot => ((supportedFeatures &
  VacuumEntity.SUPPORT_CLEAN_SPOT) ==
      VacuumEntity.SUPPORT_CLEAN_SPOT);
  bool get supportMap => ((supportedFeatures &
  VacuumEntity.SUPPORT_MAP) ==
      VacuumEntity.SUPPORT_MAP);
  bool get supportState => ((supportedFeatures &
  VacuumEntity.SUPPORT_STATE) ==
      VacuumEntity.SUPPORT_STATE);
  bool get supportStart => ((supportedFeatures &
  VacuumEntity.SUPPORT_START) ==
      VacuumEntity.SUPPORT_START);

  List<String> get fanSpeedList => getStringListAttributeValue("fan_speed_list");
  String get fanSpeed => getAttribute("fan_speed");
  String get status => getAttribute("status");
  int get batteryLevel => _getIntAttributeValue("battery_level");
  String get batteryIcon => getAttribute("battery_icon");

  /*@override
  Widget _buildStatePart(BuildContext context) {
    return SwitchStateWidget();
  }*/

  @override
  Widget _buildAdditionalControlsForPage(BuildContext context) {
    return VacuumControls();
  }
}