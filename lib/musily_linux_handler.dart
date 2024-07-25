import 'dart:async';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:musily_player/musily_player.dart';

class MusilyLinuxHandler extends BaseAudioHandler
    implements MusilyAudioHandler {
  MusilyLinuxHandler() {
    _setupEventSubscriptions();
    _updatePlaybackState();
  }

  AudioPlayer audioPlayer = AudioPlayer();
  List<MusilyTrack> mediaQueue = [];
  bool? shuffleEnabled;
  MusilyRepeatMode? repeatMode;
  MusilyTrack? activeTrack;

  late StreamSubscription<PlayerState> _playbackEventSubscription;
  late StreamSubscription<Duration?> _durationSubscription;
  late StreamSubscription<int?> _currentIndexSubscription;
  late StreamSubscription<Duration?> _positionChangeSubscription;

  @override
  Future<void> addToQueue(MusilyTrack track) async {
    mediaQueue.add(track);
    _onAction?.call(MusilyPlayerAction.queueChanged);
    if (track.url == null) {
      _loadTrackUrl(track);
    }
  }

  Future<void> _loadTrackUrl(MusilyTrack track) async {
    final filteredTrack = mediaQueue.where((element) => element.id == track.id);
    if (filteredTrack.isNotEmpty) {
      final uri = await _uriGetter?.call(track);
      filteredTrack.first.url = uri.toString();
      _onAction?.call(MusilyPlayerAction.queueChanged);
    }
  }

  void Function(
    MusilyPlayerState playerState,
  )? _onPlayerStateChanged;
  void Function(Duration duration)? _onDurationChanged;
  void Function(Duration position)? _onPositionChanged;
  void Function()? _onPlayerComplete;

  void Function(MusilyPlayerAction playerAction)? _onAction;
  void Function(bool enabled)? _onShuffleChanged;
  void Function(MusilyRepeatMode repeatMode)? _onRepeatModeChanged;
  void Function(MusilyTrack? track)? _onActiveTrackChanged;

  Future<Uri> Function(MusilyTrack track)? _uriGetter;

  final processingStateMap = {
    PlayerState.stopped: AudioProcessingState.idle,
    PlayerState.paused: AudioProcessingState.loading,
    PlayerState.playing: AudioProcessingState.ready,
    PlayerState.completed: AudioProcessingState.completed,
  };

  final repeatModeMap = {
    MusilyRepeatMode.noRepeat: AudioServiceRepeatMode.none,
    MusilyRepeatMode.repeatOne: AudioServiceRepeatMode.one,
    MusilyRepeatMode.repeat: AudioServiceRepeatMode.all,
  };

  @override
  void setOnPlayerStateChanged(
    Function(
      MusilyPlayerState playerState,
    ) callback,
  ) {
    _onPlayerStateChanged = callback;
  }

  @override
  void setOnDurationChanged(
    Function(Duration duration) callback,
  ) {
    _onDurationChanged = callback;
  }

  @override
  void setOnPositionChanged(
    Function(Duration position) callback,
  ) {
    _onPositionChanged = callback;
  }

  @override
  void setOnPlayerComplete(
    Function() callback,
  ) {
    _onPlayerComplete = callback;
  }

  @override
  void setOnAction(Function(MusilyPlayerAction playerAction) callback) {
    _onAction = callback;
  }

  @override
  void setOnShuffleChanged(Function(bool enabled) callback) {
    _onShuffleChanged = callback;
  }

  @override
  void setOnRepeatModeChanged(Function(MusilyRepeatMode repeatMode) callback) {
    _onRepeatModeChanged = callback;
  }

  @override
  void setOnActiveTrackChange(Function(MusilyTrack? track) callback) {
    _onActiveTrackChanged = callback;
  }

  Future<void> _handlePlaybackEvent(PlayerState state) async {
    try {
      if (state == PlayerState.completed) {
        switch (repeatMode) {
          case MusilyRepeatMode.noRepeat:
            if (hasNext) {
              await skipToNext();
            } else if (activeTrack != null) {
              await skipToTrack(0);
              if (state == PlayerState.playing) {
                await pause();
              }
              if (activeTrack?.position != Duration.zero) {
                await seek(Duration.zero);
              }
            }
            break;
          case MusilyRepeatMode.repeatOne:
            await seek(Duration.zero);
            if (state != PlayerState.playing) {
              await play();
            }
            break;
          case MusilyRepeatMode.repeat:
            await skipToNext();
            break;
          case null:
            break;
        }
      }
      _updatePlaybackState();
    } catch (e, stackTrace) {
      Logger.log('Error handling playback event', e, stackTrace);
    }
  }

  int activeTrackIndex() {
    final filteredTrack = mediaQueue.where(
      (element) => element.id == activeTrack?.id,
    );
    if (filteredTrack.isNotEmpty) {
      return mediaQueue.indexOf(filteredTrack.first);
    }
    return -1;
  }

  void _handleDurationChange(Duration? duration) {
    try {
      final index = activeTrackIndex();
      if (index != -1 && queue.value.isNotEmpty) {
        final newQueue = List<MediaItem>.from(queue.value);
        final oldMediaItem = newQueue[index];
        final newMediaItem = oldMediaItem.copyWith(duration: duration);
        newQueue[index] = newMediaItem;
        queue.add(newQueue);
        mediaItem.add(newMediaItem);
      }
    } catch (e, stackTrace) {
      Logger.log('Error handling duration change', e, stackTrace);
    }
  }

  void _handleCurrentSongIndexChanged(int? index) {
    try {
      if (index != null && queue.value.isNotEmpty) {
        final playlist = queue.value;
        mediaItem.add(playlist[index]);
      }
    } catch (e, stackTrace) {
      Logger.log(
        'Error handling current song index change',
        e,
        stackTrace,
      );
    }
  }

  void _setupEventSubscriptions() {
    _playbackEventSubscription = audioPlayer.onPlayerStateChanged.listen(
      (audioPlayerState) async {
        await _handlePlaybackEvent(audioPlayerState);
        if (_onPlayerStateChanged != null) {
          MusilyPlayerState playerState = MusilyPlayerState.disposed;
          switch (audioPlayerState) {
            case PlayerState.stopped:
              playerState = MusilyPlayerState.stopped;
            case PlayerState.playing:
              playerState = MusilyPlayerState.playing;
            case PlayerState.paused:
              playerState = MusilyPlayerState.paused;
            case PlayerState.completed:
              playerState = MusilyPlayerState.completed;
            case PlayerState.disposed:
              playerState = MusilyPlayerState.disposed;
          }
          _onPlayerStateChanged!.call(playerState);
          if (playerState == MusilyPlayerState.completed) {
            _onPlayerComplete?.call();
          }
        }
      },
    );
    _durationSubscription = audioPlayer.onDurationChanged.listen(
      (duration) {
        _handleDurationChange(duration);
        _onDurationChanged?.call(duration);
      },
    );
    _positionChangeSubscription =
        audioPlayer.onPositionChanged.listen((position) {
      _onPositionChanged?.call(position);
    });
  }

  void _updatePlaybackState() {
    final hasPreviousOrNext = hasPrevious || hasNext;
    playbackState.add(
      playbackState.value.copyWith(
        controls: [
          if (hasPreviousOrNext) MediaControl.skipToPrevious,
          if (audioPlayer.state == PlayerState.playing)
            MediaControl.pause
          else
            MediaControl.play,
          if (hasPreviousOrNext) MediaControl.skipToNext
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 3],
        processingState: processingStateMap[audioPlayer.state]!,
        repeatMode: repeatModeMap[repeatMode] ?? AudioServiceRepeatMode.none,
        shuffleMode: (shuffleEnabled ?? false)
            ? AudioServiceShuffleMode.all
            : AudioServiceShuffleMode.none,
        playing: audioPlayer.state == PlayerState.playing,
        updatePosition: activeTrack?.duration ?? Duration.zero,
        bufferedPosition: activeTrack?.duration ?? Duration.zero,
        queueIndex: activeTrackIndex(),
      ),
    );
  }

  @override
  Future<void> onTaskRemoved() async {
    await audioPlayer.stop().then((_) => audioPlayer.dispose());

    await _playbackEventSubscription.cancel();
    await _durationSubscription.cancel();
    await _currentIndexSubscription.cancel();
    await _positionChangeSubscription.cancel();

    await super.onTaskRemoved();
  }

  bool get hasNext => activeTrackIndex() + 1 < mediaQueue.length;

  bool get hasPrevious => activeTrackIndex() > 0;

  @override
  Future<void> play() async {
    if (activeTrack != null &&
        (activeTrack!.filePath != null || activeTrack!.url != null)) {
      final audioSource = await buildAudioSource(
        activeTrack!,
        activeTrack!.filePath ?? activeTrack!.url!,
      );
      await audioPlayer.play(audioSource);
    }
    _onAction?.call(MusilyPlayerAction.play);
  }

  @override
  Future<void> playPlaylist() async {
    if (mediaQueue.isNotEmpty) {
      await playTrack(mediaQueue.first);
    }
  }

  @override
  Future<void> pause() async {
    await audioPlayer.pause();
    _onAction?.call(MusilyPlayerAction.pause);
  }

  @override
  Future<void> stop() async {
    activeTrack = null;
    _onActiveTrackChanged?.call(null);
    _handleCurrentSongIndexChanged(activeTrackIndex());
    await audioPlayer.stop();
    _onAction?.call(MusilyPlayerAction.stop);
  }

  @override
  Future<void> seek(Duration position) async {
    await audioPlayer.seek(position);
  }

  @override
  Future<void> fastForward() => seek(
        Duration(
          seconds: (activeTrack?.position.inSeconds ?? 0) + 15,
        ),
      );

  @override
  Future<void> rewind() => seek(
        Duration(
          seconds: (activeTrack?.position.inSeconds ?? 0) - 15,
        ),
      );

  @override
  Future<void> playTrack(MusilyTrack track) async {
    try {
      late String url;
      if (track.filePath != null) {
        url = track.filePath!;
      } else if (track.url != null) {
        url = track.url!;
      } else {
        url = '';
      }
      activeTrack = track;
      _onActiveTrackChanged?.call(track);
      if (mediaQueue.where((element) => element.id == track.id).isEmpty) {
        mediaQueue = [track];
        _onAction?.call(MusilyPlayerAction.queueChanged);
      }
      if (url.isEmpty) {
        if (_uriGetter != null) {
          final uri = await _uriGetter!.call(track);
          url = uri.toString();
          track.url = uri.toString();
          _onActiveTrackChanged?.call(track);
          if (url.isEmpty) {
            return;
          }
        }
      }
      final audioSource = await buildAudioSource(track, url);

      await audioPlayer.play(audioSource);
    } catch (e, stackTrace) {
      Logger.log('Error playing song', e, stackTrace);
    }
  }

  bool _isUrl(String string) {
    return RegExp(r'^https?:\/\/[^\s/$.?#].[^\s]*$').hasMatch(string);
  }

  Future<Source> buildAudioSource(
    MusilyTrack track,
    String url,
  ) async {
    if (!_isUrl(url)) {
      return DeviceFileSource(url);
    }

    return UrlSource(url);
  }

  @override
  void setUriGetter(Future<Uri> Function(MusilyTrack track) callback) {
    _uriGetter = callback;
  }

  @override
  Future<void> skipToTrack(int newIndex) async {
    if (newIndex >= 0 && newIndex < mediaQueue.length) {
      final newTrack = mediaQueue[newIndex];
      await playTrack(newTrack);
    }
  }

  @override
  Future<void> skipToNext() async {
    if ((shuffleEnabled ?? false) && mediaQueue.length > 2) {
      final random = Random();
      int min = 0;
      int max = mediaQueue.length - 1;
      int randomIndex = (min + random.nextDouble() * (max - min)).toInt();
      if (randomIndex == activeTrackIndex()) {
        if (mediaQueue.last == mediaQueue[randomIndex]) {
          randomIndex - 1;
        }
        if (mediaQueue.first == mediaQueue[randomIndex]) {
          randomIndex + 1;
        }
      }
      await skipToTrack(randomIndex);
      return;
    }
    if (repeatMode == MusilyRepeatMode.repeat) {
      if (mediaQueue[activeTrackIndex()] == mediaQueue.last) {
        await skipToTrack(0);
        return;
      }
    }
    await skipToTrack(activeTrackIndex() + 1);
  }

  @override
  Future<void> skipToPrevious() async {
    final currentPosition =
        await audioPlayer.getCurrentPosition() ?? Duration.zero;
    if (currentPosition.inSeconds > 5) {
      await seek(Duration.zero);
      return;
    }
    if ((shuffleEnabled ?? false) && mediaQueue.length > 2) {
      final random = Random();
      int min = 0;
      int max = mediaQueue.length - 1;
      int randomIndex = (min + random.nextDouble() * (max - min)).toInt();
      if (randomIndex == activeTrackIndex()) {
        if (mediaQueue.last == mediaQueue[randomIndex]) {
          randomIndex - 1;
        }
        if (mediaQueue.first == mediaQueue[randomIndex]) {
          randomIndex + 1;
        }
      }
      await skipToTrack(randomIndex);
      return;
    }
    if (repeatMode == MusilyRepeatMode.repeat) {
      if (mediaQueue[activeTrackIndex()] == mediaQueue.first) {
        await skipToTrack(mediaQueue.length - 1);
        return;
      }
    }
    await skipToTrack(activeTrackIndex() - 1);
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    final shuffleEnabled = shuffleMode != AudioServiceShuffleMode.none;
    this.shuffleEnabled = shuffleEnabled;
    _onShuffleChanged?.call(shuffleEnabled);
  }

  @override
  Future<void> removeFromQueue(MusilyTrack track) async {
    final itemFiltered = mediaQueue.where((element) => element.id == track.id);
    if (itemFiltered.isNotEmpty) {
      final index = mediaQueue.indexOf(itemFiltered.first);
      mediaQueue.removeAt(index);
      _onAction?.call(MusilyPlayerAction.queueChanged);
    }
  }

  @override
  List<MusilyTrack> getQueue() {
    return mediaQueue;
  }

  @override
  Future<void> setQueue(List<MusilyTrack> items) async {
    mediaQueue = items;
    _onAction?.call(MusilyPlayerAction.queueChanged);
  }

  @override
  Future<void> toggleRepeatMode(MusilyRepeatMode repeatMode) async {
    this.repeatMode = repeatMode;
    _onRepeatModeChanged?.call(repeatMode);
  }

  @override
  MusilyRepeatMode getRepeatMode() {
    return repeatMode ?? MusilyRepeatMode.noRepeat;
  }

  @override
  bool getShuffleMode() {
    return shuffleEnabled ?? false;
  }

  @override
  Future<void> toggleShuffleMode(bool enabled) async {
    await setShuffleMode(
      enabled ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none,
    );
  }
}
