part of '../../main.dart';

class MediaPlayerEntity extends Entity {

  static const SUPPORT_PAUSE = 1;
  static const SUPPORT_SEEK = 2;
  static const SUPPORT_VOLUME_SET = 4;
  static const SUPPORT_VOLUME_MUTE = 8;
  static const SUPPORT_PREVIOUS_TRACK = 16;
  static const SUPPORT_NEXT_TRACK = 32;

  static const SUPPORT_TURN_ON = 128;
  static const SUPPORT_TURN_OFF = 256;
  static const SUPPORT_PLAY_MEDIA = 512;
  static const SUPPORT_VOLUME_STEP = 1024;
  static const SUPPORT_SELECT_SOURCE = 2048;
  static const SUPPORT_STOP = 4096;
  static const SUPPORT_CLEAR_PLAYLIST = 8192;
  static const SUPPORT_PLAY = 16384;
  static const SUPPORT_SHUFFLE_SET = 32768;
  static const SUPPORT_SELECT_SOUND_MODE = 65536;

  MediaPlayerEntity(Map rawData, String webHost) : super(rawData, webHost);

  bool get supportPause => ((supportedFeatures &
  MediaPlayerEntity.SUPPORT_PAUSE) ==
      MediaPlayerEntity.SUPPORT_PAUSE);
  bool get supportSeek => ((supportedFeatures &
  MediaPlayerEntity.SUPPORT_SEEK) ==
      MediaPlayerEntity.SUPPORT_SEEK);
  bool get supportVolumeSet => ((supportedFeatures &
  MediaPlayerEntity.SUPPORT_VOLUME_SET) ==
      MediaPlayerEntity.SUPPORT_VOLUME_SET);
  bool get supportVolumeMute => ((supportedFeatures &
  MediaPlayerEntity.SUPPORT_VOLUME_MUTE) ==
      MediaPlayerEntity.SUPPORT_VOLUME_MUTE);
  bool get supportPreviousTrack => ((supportedFeatures &
  MediaPlayerEntity.SUPPORT_PREVIOUS_TRACK) ==
      MediaPlayerEntity.SUPPORT_PREVIOUS_TRACK);
  bool get supportNextTrack => ((supportedFeatures &
  MediaPlayerEntity.SUPPORT_NEXT_TRACK) ==
      MediaPlayerEntity.SUPPORT_NEXT_TRACK);

  bool get supportTurnOn => ((supportedFeatures &
  MediaPlayerEntity.SUPPORT_TURN_ON) ==
      MediaPlayerEntity.SUPPORT_TURN_ON);
  bool get supportTurnOff => ((supportedFeatures &
  MediaPlayerEntity.SUPPORT_TURN_OFF) ==
      MediaPlayerEntity.SUPPORT_TURN_OFF);
  bool get supportPlayMedia => ((supportedFeatures &
  MediaPlayerEntity.SUPPORT_PLAY_MEDIA) ==
      MediaPlayerEntity.SUPPORT_PLAY_MEDIA);
  bool get supportVolumeStep => ((supportedFeatures &
  MediaPlayerEntity.SUPPORT_VOLUME_STEP) ==
      MediaPlayerEntity.SUPPORT_VOLUME_STEP);
  bool get supportSelectSource => ((supportedFeatures &
  MediaPlayerEntity.SUPPORT_SELECT_SOURCE) ==
      MediaPlayerEntity.SUPPORT_SELECT_SOURCE);
  bool get supportStop => ((supportedFeatures &
  MediaPlayerEntity.SUPPORT_STOP) ==
      MediaPlayerEntity.SUPPORT_STOP);
  bool get supportClearPlaylist => ((supportedFeatures &
  MediaPlayerEntity.SUPPORT_CLEAR_PLAYLIST) ==
      MediaPlayerEntity.SUPPORT_CLEAR_PLAYLIST);
  bool get supportPlay => ((supportedFeatures &
  MediaPlayerEntity.SUPPORT_PLAY) ==
      MediaPlayerEntity.SUPPORT_PLAY);
  bool get supportShuffleSet => ((supportedFeatures &
  MediaPlayerEntity.SUPPORT_SHUFFLE_SET) ==
      MediaPlayerEntity.SUPPORT_SHUFFLE_SET);
  bool get supportSelectSoundMode => ((supportedFeatures &
  MediaPlayerEntity.SUPPORT_SELECT_SOUND_MODE) ==
      MediaPlayerEntity.SUPPORT_SELECT_SOUND_MODE);

  List<String> get soundModeList => getStringListAttributeValue("sound_mode_list");
  List<String> get sourceList => getStringListAttributeValue("source_list");
  DateTime get positionLastUpdated => DateTime.tryParse("${attributes["media_position_updated_at"]}")?.toLocal();
  int get durationSeconds => _getIntAttributeValue("media_duration");
  int get positionSeconds => _getIntAttributeValue("media_position");

  @override
  Widget _buildAdditionalControlsForPage(BuildContext context) {
    return MediaPlayerControls();
  }

  bool canCalculateActualPosition() {
    return positionLastUpdated != null && durationSeconds != null && positionSeconds != null;
  }

  double getActualPosition() {
    double result = 0;
    if (canCalculateActualPosition()) {
      Duration durationD;
      Duration positionD;
      durationD = Duration(seconds: durationSeconds);
      positionD = Duration(
          seconds: positionSeconds);
      result = positionD.inSeconds.toDouble();
      int differenceInSeconds = DateTime
          .now()
          .difference(positionLastUpdated)
          .inSeconds;
      result = ((result + differenceInSeconds) <= durationD.inSeconds) ? (result + differenceInSeconds) : durationD.inSeconds.toDouble();
    }

    return result;

  }

}