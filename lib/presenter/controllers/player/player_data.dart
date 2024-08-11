import 'package:musily_player/core/domain/presenter/controllers/base_controller.dart';
import 'package:musily_player/musily_entities.dart';
import 'package:musily_player/musily_player.dart';

class Lyrics {
  final String trackId;
  final String? lyrics;

  Lyrics({
    required this.trackId,
    required this.lyrics,
  });
}

class PlayerData implements BaseControllerData {
  List<MusilyTrack> queue;
  String playingId;
  MusilyTrack? currentPlayingItem;
  bool loadingTrackData;
  bool isPlaying;
  bool loadRequested;
  bool seeking;
  bool shuffleEnabled;
  MusilyRepeatMode repeatMode;
  bool isBuffering;

  bool showLyrics;
  bool loadingLyrics;
  Lyrics lyrics;
  bool syncedLyrics;

  bool mediaAvailable;
  List<String> tracksFromSmartQueue;
  bool loadingSmartQueue;

  bool addingToFavorites;
  bool showQueue;
  bool showDownloadManager;

  PlayerData({
    required this.queue,
    required this.playingId,
    this.currentPlayingItem,
    required this.loadingTrackData,
    required this.isPlaying,
    required this.loadRequested,
    required this.seeking,
    required this.mediaAvailable,
    required this.shuffleEnabled,
    required this.repeatMode,
    required this.isBuffering,
    required this.showLyrics,
    required this.loadingLyrics,
    required this.lyrics,
    required this.syncedLyrics,
    required this.tracksFromSmartQueue,
    required this.loadingSmartQueue,
    required this.addingToFavorites,
    required this.showQueue,
    required this.showDownloadManager,
  });

  @override
  PlayerData copyWith({
    List<MusilyTrack>? queue,
    String? playingId,
    MusilyTrack? currentPlayingItem,
    bool? loadingTrackData,
    bool? isPlaying,
    bool? loadRequested,
    bool? seeking,
    bool? shuffleEnabled,
    MusilyRepeatMode? repeatMode,
    bool? isBuffering,
    bool? showLyrics,
    bool? loadingLyrics,
    Lyrics? lyrics,
    bool? syncedLyrics,
    bool? mediaAvailable,
    List<String>? tracksFromSmartQueue,
    bool? loadingSmartQueue,
    bool? addingToFavorites,
    bool? showQueue,
    bool? showDownloadManager,
  }) {
    return PlayerData(
      queue: queue ?? this.queue,
      playingId: playingId ?? this.playingId,
      currentPlayingItem: currentPlayingItem ?? this.currentPlayingItem,
      loadingTrackData: loadingTrackData ?? this.loadingTrackData,
      isPlaying: isPlaying ?? this.isPlaying,
      loadRequested: loadRequested ?? this.loadRequested,
      seeking: seeking ?? this.seeking,
      shuffleEnabled: shuffleEnabled ?? this.shuffleEnabled,
      repeatMode: repeatMode ?? this.repeatMode,
      isBuffering: isBuffering ?? this.isBuffering,
      showLyrics: showLyrics ?? this.showLyrics,
      loadingLyrics: loadingLyrics ?? this.loadingLyrics,
      lyrics: lyrics ?? this.lyrics,
      syncedLyrics: syncedLyrics ?? this.syncedLyrics,
      mediaAvailable: mediaAvailable ?? this.mediaAvailable,
      tracksFromSmartQueue: tracksFromSmartQueue ?? this.tracksFromSmartQueue,
      loadingSmartQueue: loadingSmartQueue ?? this.loadingSmartQueue,
      addingToFavorites: addingToFavorites ?? this.addingToFavorites,
      showQueue: showQueue ?? this.showQueue,
      showDownloadManager: showDownloadManager ?? this.showDownloadManager,
    );
  }
}
