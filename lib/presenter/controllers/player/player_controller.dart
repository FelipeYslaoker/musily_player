import 'dart:math';

import 'package:flutter/material.dart';
import 'package:musily_player/core/domain/presenter/controllers/base_controller.dart';
import 'package:musily_player/domain/entities/player_localization.dart';
import 'package:musily_player/musily_player.dart';
import 'package:musily_player/presenter/controllers/downloader/downloader_controller.dart';
import 'package:musily_player/presenter/controllers/player/player_data.dart';
import 'package:musily_player/presenter/controllers/player/player_methods.dart';

class PlayerController extends BaseController<PlayerData, PlayerMethods> {
  final _downloaderController = DownloaderController();
  final MusilyPlayer _musilyPlayer = MusilyPlayer();

  final PlayerLocalization Function(
    BuildContext context,
  )? localization;

  // Fetch data methods
  Future<String?> Function(
    MusilyTrack track,
  )? loadUrl;
  final Future<List<MusilyTrack>> Function(
    List<MusilyTrack> currentQueue,
  )? getSmartQueue;
  final Future<String?> Function(String trackId)? getLyrics;

  // Player event methods
  final void Function()? onPlayerExpanded;
  final void Function()? onPlayerCollapsed;
  final void Function(
    MusilyAlbum album,
    BuildContext context,
  )? onAlbumInvoked;
  final void Function(
    MusilyArtist artist,
    BuildContext context,
  )? onArtistInvoked;
  final void Function(MusilyTrack track)? onAddSmartQueueItem;

  // Player custom widgets
  final Widget Function(
    BuildContext context,
    MusilyTrack track,
  )? trackOptionsWidget;
  final Widget Function(
    BuildContext context,
  )? customQueueHeader;
  final Widget Function(
    BuildContext context,
    MusilyTrack track,
  )? favoriteButton;

  PlayerController({
    this.localization,
    //Fetch data methods
    this.loadUrl,
    this.getSmartQueue,
    this.getLyrics,

    // Player event methods
    this.onPlayerExpanded,
    this.onPlayerCollapsed,
    this.onAlbumInvoked,
    this.onArtistInvoked,
    this.onAddSmartQueueItem,

    // Player custom widgets
    this.trackOptionsWidget,
    this.customQueueHeader,
    this.favoriteButton,
  }) {
    updateData(
      data.copyWith(
        repeatMode: _musilyPlayer.getRepeatMode(),
        shuffleEnabled: _musilyPlayer.getShuffleMode(),
      ),
    );

    _downloaderController.setPlayerController(this);

    _musilyPlayer.setUriGetter((track) async {
      final offlineItem = _downloaderController.methods.getItem(track);
      if (offlineItem != null) {
        return Uri.parse(offlineItem.track.url!);
      }
      final url = await loadUrl?.call(track);
      return Uri.parse(url ?? '');
    });

    _musilyPlayer.setOnPlayerStateChanged((state) {
      updateData(
        data.copyWith(
          isPlaying: state == MusilyPlayerState.playing,
          mediaAvailable: state == MusilyPlayerState.playing ||
              state == MusilyPlayerState.paused,
          isBuffering: state == MusilyPlayerState.buffering,
        ),
      );
    });

    _musilyPlayer.setOnDurationChanged((newDuration) {
      if (data.currentPlayingItem != null) {
        data.currentPlayingItem!.duration = newDuration;
        updateData(data);
      }
    });

    _musilyPlayer.setOnPositionChanged((newPosition) {
      if (data.currentPlayingItem != null) {
        data.currentPlayingItem!.position = newPosition;
        updateData(data);
      }
    });

    _musilyPlayer.setOnAction((action) {
      if (action == MusilyPlayerAction.queueChanged) {
        updateData(
          data.copyWith(
            queue: _musilyPlayer.getQueue(),
          ),
        );
      }
    });

    _musilyPlayer.setOnShuffleChanged((enabled) {
      updateData(
        data.copyWith(
          shuffleEnabled: enabled,
        ),
      );
    });

    _musilyPlayer.setOnRepeatModeChanged((repeatMode) {
      updateData(
        data.copyWith(
          repeatMode: repeatMode,
        ),
      );
    });

    _musilyPlayer.setOnActiveTrackChange((track) {
      updateData(
        data.copyWith(
          currentPlayingItem: track,
        ),
      );
      dispatchEvent(
        BaseControllerEvent<MusilyTrack?>(
          id: 'playingItemUpdated',
          data: data.currentPlayingItem,
        ),
      );
      if (data.showLyrics) {
        methods.getLyrics(data.currentPlayingItem?.id ?? '');
      }
    });
  }
  @override
  PlayerData defineData() {
    return PlayerData(
      playingId: '',
      queue: [],
      loadingTrackData: false,
      isPlaying: false,
      loadRequested: false,
      seeking: false,
      mediaAvailable: true,
      shuffleEnabled: false,
      repeatMode: MusilyRepeatMode.noRepeat,
      isBuffering: false,
      showLyrics: false,
      loadingLyrics: false,
      syncedLyrics: true,
      lyrics: Lyrics(
        trackId: '',
        lyrics: null,
      ),
      tracksFromSmartQueue: [],
      loadingSmartQueue: false,
      addingToFavorites: false,
      showQueue: false,
      showDownloadManager: false,
    );
  }

  @override
  PlayerMethods defineMethods() {
    return PlayerMethods(
      toggleShowDownloadManager: () {
        updateData(
          data.copyWith(
            showDownloadManager: !data.showDownloadManager,
            showQueue: false,
            showLyrics: false,
          ),
        );
      },
      toggleShowQueue: () {
        updateData(
          data.copyWith(
            showQueue: !data.showQueue,
            showLyrics: false,
            showDownloadManager: false,
          ),
        );
      },
      closePlayer: () {
        dispatchEvent(
          BaseControllerEvent(
            id: 'closePlayer',
            data: data,
          ),
        );
      },
      toggleSmartQueue: () {
        if (data.tracksFromSmartQueue.isEmpty) {
          methods.getSmartQueue();
        } else {
          if (data.tracksFromSmartQueue
              .contains(data.currentPlayingItem?.hash)) {
            updateData(
              data.copyWith(
                currentPlayingItem: data.queue.firstOrNull,
              ),
            );
            if (data.queue.isNotEmpty) {
              _musilyPlayer.skipToTrack(0);
            }
          }
          _musilyPlayer.setQueue(
            [
              ...data.queue
                ..removeWhere(
                  (item) => data.tracksFromSmartQueue.contains(
                    item.hash,
                  ),
                ),
            ],
          );
          updateData(
            data.copyWith(
              tracksFromSmartQueue: [],
            ),
          );
        }
      },
      getSmartQueue: ({customItems}) async {
        updateData(
          data.copyWith(
            loadingSmartQueue: true,
          ),
        );
        if (customItems?.isNotEmpty ?? false) {
          final smartItems = await getSmartQueue?.call(customItems ?? []) ?? [];
          if (smartItems.isEmpty) {
            updateData(
              data.copyWith(
                loadingSmartQueue: false,
              ),
            );
            return;
          }
          smartItems.removeWhere(
            (item) => data.queue.map((track) => track.hash).contains(item.hash),
          );
          final List<MusilyTrack> queueClone = List.from(data.queue);
          final random = Random();
          for (final item in smartItems) {
            final indexToInsert = random.nextInt(queueClone.length - 1);
            queueClone.insert(
              indexToInsert,
              item,
            );
          }
          _musilyPlayer.setQueue(queueClone);
          updateData(
            data.copyWith(
              loadingSmartQueue: false,
              tracksFromSmartQueue: data.tracksFromSmartQueue
                ..addAll(
                  smartItems.map(
                    (item) => item.hash ?? item.id,
                  ),
                ),
            ),
          );
          return;
        }

        final smartQueue = (await getSmartQueue?.call(
              data.queue,
            ) ??
            []);
        final tracksFromSmartQueue = smartQueue.where(
          (track) => track.fromSmartQueue,
        );
        updateData(
          data.copyWith(
            tracksFromSmartQueue: [
              ...tracksFromSmartQueue.map(
                (track) => track.hash ?? track.id,
              )
            ],
          ),
        );
        _musilyPlayer.setQueue(smartQueue);
        updateData(
          data.copyWith(
            loadingSmartQueue: false,
          ),
        );
      },
      toggleSyncedLyrics: () {
        updateData(
          data.copyWith(
            syncedLyrics: !data.syncedLyrics,
          ),
        );
      },
      getLyrics: (trackId) async {
        if (data.loadingLyrics) {
          return null;
        }
        if (data.lyrics.trackId == trackId) {
          return data.lyrics.lyrics;
        }
        updateData(
          data.copyWith(
            loadingLyrics: true,
          ),
        );
        final lyrics = await getLyrics?.call(trackId);
        updateData(
          data.copyWith(
            lyrics: Lyrics(
              trackId: trackId,
              lyrics: lyrics,
            ),
            loadingLyrics: false,
          ),
        );
        return data.lyrics.lyrics;
      },
      toggleLyrics: (id) {
        updateData(
          data.copyWith(
            showLyrics: !data.showLyrics,
            showDownloadManager: false,
            showQueue: false,
          ),
        );
        methods.getLyrics(id);
      },
      play: () async {
        await _musilyPlayer.playPlaylist();
      },
      resume: () async {
        await _musilyPlayer.play();
      },
      pause: () async {
        await _musilyPlayer.pause();
      },
      toggleFavorite: () async {
        return;
      },
      seek: (duration) async {
        updateData(
          data.copyWith(
            seeking: true,
          ),
        );
        await _musilyPlayer.seek(duration);
        updateData(
          data.copyWith(
            seeking: false,
          ),
        );
      },
      loadAndPlay: (track, playingId) async {
        if (data.loadRequested) {
          if (track.id != data.currentPlayingItem?.id) {
            updateData(
              data.copyWith(
                loadRequested: false,
                playingId: playingId,
                tracksFromSmartQueue: [],
              ),
            );
            await methods.loadAndPlay(track, playingId);
          }
          return;
        }
        updateData(
          data.copyWith(
            loadingTrackData: true,
            loadRequested: true,
          ),
        );
        updateData(
          data.copyWith(
            loadingTrackData: false,
            playingId: playingId,
            tracksFromSmartQueue: [],
          ),
        );
        await _musilyPlayer.playTrack(track);
      },
      toggleShuffle: () async {
        await _musilyPlayer.toggleShuffleMode(
          !data.shuffleEnabled,
        );
      },
      toggleRepeatState: () async {
        switch (_musilyPlayer.getRepeatMode()) {
          case MusilyRepeatMode.repeat:
            await _musilyPlayer.toggleRepeatMode(MusilyRepeatMode.repeatOne);
            break;
          case MusilyRepeatMode.noRepeat:
            await _musilyPlayer.toggleRepeatMode(MusilyRepeatMode.repeat);
            break;
          case MusilyRepeatMode.repeatOne:
            await _musilyPlayer.toggleRepeatMode(MusilyRepeatMode.noRepeat);
            break;
        }
      },
      nextInQueue: () async {
        if (data.currentPlayingItem != null) {
          await _musilyPlayer.skipToNext();
        }
      },
      previousInQueue: () async {
        if (data.currentPlayingItem != null) {
          final currentPlayingIndex = data.queue.indexOf(
            data.queue.firstWhere(
              (element) => element.id == data.currentPlayingItem!.id,
            ),
          );
          if (currentPlayingIndex > 0) {
            await _musilyPlayer.skipToPrevious();
          }
        }
      },
      addToQueue: (items) async {
        final currentItemsHashs = data.queue.map((element) => element.hash);
        final filteredItems = items.where(
          (element) => !currentItemsHashs.contains(element.hash),
        );
        for (final item in filteredItems) {
          await _musilyPlayer.addToQueue(item);
        }
        if (data.queue.length == 1 || data.currentPlayingItem == null) {
          await _musilyPlayer.playPlaylist();
        }
      },
      queueJumpTo: (int index) async {
        if (data.currentPlayingItem != null) {
          if (data.currentPlayingItem!.id != data.queue[index].id) {
            await _musilyPlayer.skipToTrack(index);
          }
        }
      },
      reorderQueue: (int newIndex, int oldIndex) async {
        if (newIndex > oldIndex) {
          newIndex -= 1;
        }
        List<MusilyTrack> queueCopy = List.from(_musilyPlayer.getQueue());
        queueCopy = queueCopy
          ..insert(
            newIndex,
            queueCopy.removeAt(oldIndex),
          );
        _musilyPlayer.setQueue(queueCopy);
      },
      playPlaylist: (
        List<MusilyTrack> items,
        String playingId, {
        int startFrom = 1,
      }) async {
        await _musilyPlayer.stop();
        await _musilyPlayer.setQueue(items);
        _musilyPlayer.skipToTrack(startFrom);
        if (data.shuffleEnabled) {
          if (playingId != data.playingId) {
            await methods.toggleShuffle();
            await methods.toggleShuffle();
          }
        }
        updateData(
          data.copyWith(
            playingId: playingId,
            tracksFromSmartQueue: [],
          ),
        );
      },
    );
  }
}
