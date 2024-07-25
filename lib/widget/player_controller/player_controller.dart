import 'package:musily_player/musily_player.dart';
import 'package:musily_player/widget/player_controller/get_playable_item_usecase_impl.dart';
import 'package:musily_player/widget/player_controller/player_data.dart';
import 'package:musily_player/widget/player_controller/player_methods.dart';
import 'package:musily_player/widget/utils/app_controller.dart';

class PlayerController extends AppController<PlayerData, PlayerMethods> {
  late final MusilyPlayer _musilyPlayer;
  late final GetPlayableItemUsecaseImpl _getPlayableItemUsecase;
  PlayerController({
    required MusilyPlayer musilyPlayer,
  }) {
    _musilyPlayer = musilyPlayer;
    _getPlayableItemUsecase = GetPlayableItemUsecaseImpl();

    updateData(
      data.copyWith(
        repeatMode: _musilyPlayer.getRepeatMode(),
        shuffleEnabled: _musilyPlayer.getShuffleMode(),
      ),
    );

    _musilyPlayer.setOnPlayerStateChanged((state) {
      updateData(
        data.copyWith(
          isPlaying: state == MusilyPlayerState.playing,
          mediaAvailable: state == MusilyPlayerState.playing ||
              state == MusilyPlayerState.paused,
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
    });
  }
  @override
  PlayerData defineData() {
    return PlayerData(
      queue: [],
      loadingTrackData: false,
      isPlaying: false,
      loadRequested: false,
      seeking: false,
      mediaAvailable: true,
      shuffleEnabled: false,
      repeatMode: MusilyRepeatMode.noRepeat,
    );
  }

  @override
  PlayerMethods defineMethods() {
    return PlayerMethods(
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
      loadAndPlay: (track) async {
        if (data.loadRequested) {
          if (track.id != data.currentPlayingItem?.id) {
            updateData(
              data.copyWith(
                loadRequested: false,
              ),
            );
            await methods.loadAndPlay(track);
          }
          return;
        }
        updateData(
          data.copyWith(
            loadingTrackData: true,
            loadRequested: true,
          ),
        );
        final playableItem = await _getPlayableItemUsecase.exec(track);
        await _musilyPlayer.playTrack(playableItem);
        updateData(
          data.copyWith(
            loadingTrackData: false,
          ),
        );
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
        await _musilyPlayer.skipToNext();
      },
      previousInQueue: () async {
        if (data.currentPlayingItem != null) {
          if (data.queue.first.id == data.currentPlayingItem!.id) {
            if (!data.shuffleEnabled) {
              if (data.repeatMode == MusilyRepeatMode.noRepeat ||
                  data.repeatMode == MusilyRepeatMode.repeatOne) {
                if (data.currentPlayingItem!.position.inSeconds < 5) {
                  return;
                }
              }
            }
          }
        }
        await _musilyPlayer.skipToPrevious();
      },
      addToQueue: (item) async {
        final itemFiltered = data.queue.where(
          (element) => element.id == item.id,
        );
        if (itemFiltered.isEmpty) {
          _musilyPlayer.addToQueue(item);
        }
        if (data.queue.length == 1) {
          await _musilyPlayer.playPlaylist();
        }
      },
      getPlayableItem: (track) async {
        final queueTrackList = data.queue.map((element) => element.id).toList();
        if (queueTrackList.contains(track.id)) {
          return data.queue.firstWhere(
            (element) => element.id == track.id,
          );
        }
        final playableItem = await _getPlayableItemUsecase.exec(track);
        return playableItem;
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
        updateData(
          data.copyWith(
            queue: data.queue
              ..insert(
                newIndex,
                data.queue.removeAt(oldIndex),
              ),
          ),
        );
        List<MusilyTrack> queueCopy = List.from(data.queue);
        queueCopy = queueCopy
          ..insert(
            newIndex,
            queueCopy.removeAt(oldIndex),
          );
        _musilyPlayer.setQueue(queueCopy);
      },
    );
  }
}
