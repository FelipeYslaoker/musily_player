import 'package:musily_player/musily_entities.dart';

abstract class MusilyAudioHandler {
  void setOnPlayerStateChanged(
    Function(
      MusilyPlayerState playerState,
    ) callback,
  );
  void setOnDurationChanged(
    Function(
      Duration duration,
    ) callback,
  );
  void setOnPositionChanged(
    Function(Duration position) callback,
  );
  void setOnPlayerComplete(
    Function() callback,
  );
  void setOnAction(
    Function(
      MusilyPlayerAction playerAction,
    ) callback,
  );
  void setOnShuffleChanged(
    Function(
      bool enabled,
    ) callback,
  );
  void setOnRepeatModeChanged(
    Function(
      MusilyRepeatMode repeatMode,
    ) callback,
  );
  void setOnActiveTrackChange(
    Function(
      MusilyTrack? track,
    ) callback,
  );

  void setUriGetter(
    Future<Uri> Function(
      MusilyTrack track,
    ) callback,
  );

  Future<void> play();
  Future<void> pause();
  Future<void> stop();
  Future<void> seek(Duration position);
  Future<void> fastForward();
  Future<void> rewind();
  Future<void> playTrack(MusilyTrack track);

  Future<void> skipToTrack(int newIndex);
  Future<void> skipToNext();
  Future<void> skipToPrevious();

  Future<void> addToQueue(MusilyTrack track);
  Future<void> removeFromQueue(MusilyTrack track);
  Future<void> setQueue(List<MusilyTrack> items);

  Future<void> toggleShuffleMode(bool enabled);
  Future<void> toggleRepeatMode(MusilyRepeatMode repeatMode);
  Future<void> playPlaylist();

  List<MusilyTrack> getQueue();
  MusilyRepeatMode getRepeatMode();
  bool getShuffleMode();
}
