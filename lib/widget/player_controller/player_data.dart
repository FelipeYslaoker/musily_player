import 'package:musily_player/musily_player.dart';
import 'package:musily_player/widget/utils/app_controller.dart';

class PlayerData extends AppControllerData {
  List<MusilyTrack> queue;
  MusilyTrack? currentPlayingItem;
  bool loadingTrackData;
  bool isPlaying;
  bool loadRequested;
  bool seeking;
  bool shuffleEnabled;
  MusilyRepeatMode repeatMode;

  bool mediaAvailable;

  PlayerData({
    required this.queue,
    this.currentPlayingItem,
    required this.loadingTrackData,
    required this.isPlaying,
    required this.loadRequested,
    required this.seeking,
    required this.mediaAvailable,
    required this.shuffleEnabled,
    required this.repeatMode,
  });

  @override
  PlayerData copyWith({
    List<MusilyTrack>? queue,
    MusilyTrack? currentPlayingItem,
    bool? loadingTrackData,
    bool? isPlaying,
    bool? loadRequested,
    bool? seeking,
    bool? mediaAvailable,
    bool? shuffleEnabled,
    MusilyRepeatMode? repeatMode,
  }) {
    return PlayerData(
      queue: queue ?? this.queue,
      currentPlayingItem: currentPlayingItem ?? this.currentPlayingItem,
      loadingTrackData: loadingTrackData ?? this.loadingTrackData,
      isPlaying: isPlaying ?? this.isPlaying,
      loadRequested: loadRequested ?? this.loadRequested,
      seeking: seeking ?? this.seeking,
      mediaAvailable: mediaAvailable ?? this.mediaAvailable,
      shuffleEnabled: shuffleEnabled ?? this.shuffleEnabled,
      repeatMode: repeatMode ?? this.repeatMode,
    );
  }
}
