part of '../../main.dart';

class CoverEntity extends Entity {

  static const SUPPORT_OPEN = 1;
  static const SUPPORT_CLOSE = 2;
  static const SUPPORT_SET_POSITION = 4;
  static const SUPPORT_STOP = 8;
  static const SUPPORT_OPEN_TILT = 16;
  static const SUPPORT_CLOSE_TILT = 32;
  static const SUPPORT_STOP_TILT = 64;
  static const SUPPORT_SET_TILT_POSITION = 128;

  CoverEntity(Map rawData, String webHost) : super(rawData, webHost);

  bool get supportOpen => ((supportedFeatures &
  CoverEntity.SUPPORT_OPEN) ==
      CoverEntity.SUPPORT_OPEN);
  bool get supportClose => ((supportedFeatures &
  CoverEntity.SUPPORT_CLOSE) ==
      CoverEntity.SUPPORT_CLOSE);
  bool get supportSetPosition => ((supportedFeatures &
  CoverEntity.SUPPORT_SET_POSITION) ==
      CoverEntity.SUPPORT_SET_POSITION);
  bool get supportStop => ((supportedFeatures &
  CoverEntity.SUPPORT_STOP) ==
      CoverEntity.SUPPORT_STOP);

  bool get supportOpenTilt => ((supportedFeatures &
  CoverEntity.SUPPORT_OPEN_TILT) ==
      CoverEntity.SUPPORT_OPEN_TILT);
  bool get supportCloseTilt => ((supportedFeatures &
  CoverEntity.SUPPORT_CLOSE_TILT) ==
      CoverEntity.SUPPORT_CLOSE_TILT);
  bool get supportStopTilt => ((supportedFeatures &
  CoverEntity.SUPPORT_STOP_TILT) ==
      CoverEntity.SUPPORT_STOP_TILT);
  bool get supportSetTiltPosition => ((supportedFeatures &
  CoverEntity.SUPPORT_SET_TILT_POSITION) ==
      CoverEntity.SUPPORT_SET_TILT_POSITION);


  double get currentPosition => _getDoubleAttributeValue('current_position') ?? 0;
  double get currentTiltPosition => _getDoubleAttributeValue('current_tilt_position') ?? 0;
  bool get canBeOpened => ((state != EntityState.opening) && (state != EntityState.open)) || (state == EntityState.open && currentPosition != null && currentPosition > 0.0 && currentPosition < 100.0);
  bool get canBeClosed => ((state != EntityState.closing) && (state != EntityState.closed));
  bool get canTiltBeOpened => currentTiltPosition < 100;
  bool get canTiltBeClosed => currentTiltPosition > 0;

  @override
  Widget _buildStatePart(BuildContext context) {
    return CoverStateWidget();
  }

  @override
  Widget _buildAdditionalControlsForPage(BuildContext context) {
    return CoverControlWidget();
  }

}
