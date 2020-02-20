part of '../../main.dart';

class CameraEntity extends Entity {

  static const SUPPORT_ON_OFF = 1;
  static const SUPPORT_STREAM = 2;

  CameraEntity(Map rawData, String webHost) : super(rawData, webHost);

  bool get supportOnOff => ((supportedFeatures &
  CameraEntity.SUPPORT_ON_OFF) ==
      CameraEntity.SUPPORT_ON_OFF);
  bool get supportStream => ((supportedFeatures &
  CameraEntity.SUPPORT_STREAM) ==
      CameraEntity.SUPPORT_STREAM);

  @override
  Widget _buildAdditionalControlsForPage(BuildContext context) {
    return CameraStreamView();
  }
}