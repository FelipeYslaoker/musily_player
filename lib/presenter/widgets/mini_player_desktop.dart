import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:musily_player/core/presenter/widgets/app_image.dart';
import 'package:musily_player/core/presenter/widgets/infinity_marquee.dart';
import 'package:musily_player/musily_entities.dart';
import 'package:musily_player/presenter/controllers/downloader/downloader_controller.dart';
import 'package:musily_player/presenter/controllers/player/player_controller.dart';
import 'package:musily_player/core/utils/format_duration.dart';
import 'package:musily_player/presenter/widgets/download_button.dart';
import 'package:musily_player/presenter/widgets/in_context_dialog.dart';
import 'package:musily_player/presenter/widgets/queue_widget.dart';
import 'package:musily_player/presenter/widgets/track_lyrics.dart';

class MiniPlayerDesktop extends StatefulWidget {
  final PlayerController playerController;
  final DownloaderController downloaderController;
  const MiniPlayerDesktop({
    required this.playerController,
    required this.downloaderController,
    super.key,
  });

  @override
  State<MiniPlayerDesktop> createState() => _MiniPlayerDesktopState();
}

class _MiniPlayerDesktopState extends State<MiniPlayerDesktop> {
  Duration _seekDuration = Duration.zero;
  bool _useSeekDuration = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return widget.playerController.builder(
        builder: (context, data) {
          final availableHeight = constraints.maxHeight;
          return Stack(
            fit: StackFit.expand,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: SizedBox(
                  height: availableHeight - 77,
                  child: InContextDialog(
                    show: data.showQueue,
                    width: 400,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          strokeAlign: 1,
                          color: Theme.of(context).dividerColor.withOpacity(
                                .2,
                              ),
                        ),
                      ),
                      child: QueueWidget(
                        playerController: widget.playerController,
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: SizedBox(
                  height: availableHeight - 77,
                  child: InContextDialog(
                    show: data.showLyrics,
                    width: 400,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          strokeAlign: 1,
                          color: Theme.of(context).dividerColor.withOpacity(
                                .2,
                              ),
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            12,
                          ),
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            12,
                          ),
                          child: Builder(builder: (context) {
                            if (data.loadingLyrics) {
                              return Center(
                                child: LoadingAnimationWidget.waveDots(
                                  color: IconTheme.of(context).color ??
                                      Colors.white,
                                  size: 45,
                                ),
                              );
                            }
                            if (data.lyrics.lyrics == null) {
                              return Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.music_off_rounded,
                                      size: 45,
                                    ),
                                    const SizedBox(
                                      height: 12,
                                    ),
                                    Text(
                                      widget.playerController.localization
                                              ?.call(context)
                                              .lyricsNotFound ??
                                          'Lyrics not found',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w400,
                                          ),
                                    )
                                  ],
                                ),
                              );
                            }
                            return TrackLyrics(
                              totalDuration: data.currentPlayingItem!.duration,
                              currentPosition:
                                  data.currentPlayingItem!.position,
                              lyrics: data.lyrics.lyrics!,
                              synced: data.syncedLyrics,
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  height: 75,
                  child: Card(
                    margin: EdgeInsets.zero,
                    shape: const RoundedRectangleBorder(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: BorderSide(
                                          width: 1,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline
                                              .withOpacity(.2),
                                        ),
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          if (data.currentPlayingItem!.album !=
                                              null) {
                                            widget
                                                .playerController.onAlbumInvoked
                                                ?.call(
                                              data.currentPlayingItem!.album!,
                                              context,
                                            );
                                          }
                                        },
                                        child: Builder(
                                          builder: (context) {
                                            if (data.currentPlayingItem!
                                                        .lowResImg !=
                                                    null &&
                                                data.currentPlayingItem!
                                                    .lowResImg!.isNotEmpty) {
                                              return ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: AppImage(
                                                  data.currentPlayingItem!
                                                      .lowResImg!,
                                                  width: 45,
                                                  height: 45,
                                                ),
                                              );
                                            }
                                            return SizedBox(
                                              height: 45,
                                              width: 45,
                                              child: Icon(
                                                Icons.music_note,
                                                color: Theme.of(context)
                                                    .iconTheme
                                                    .color
                                                    ?.withOpacity(.7),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    if (data.tracksFromSmartQueue.contains(
                                      data.currentPlayingItem!.hash ??
                                          data.currentPlayingItem!.id,
                                    ))
                                      Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Container(
                                          height: 45,
                                          width: 45,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                    .withOpacity(.2),
                                              ],
                                            ),
                                          ),
                                          child: Center(
                                            child: Icon(
                                              CupertinoIcons.wand_stars,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary,
                                              size: 25,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(
                                  width: 12,
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      InfinityMarquee(
                                        child: Text(
                                          data.currentPlayingItem!.title ?? '',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          if (data.currentPlayingItem?.artist !=
                                              null) {
                                            widget.playerController
                                                .onArtistInvoked
                                                ?.call(
                                              data.currentPlayingItem!.artist!,
                                              context,
                                            );
                                          }
                                        },
                                        child: InfinityMarquee(
                                          child: Text(
                                            data.currentPlayingItem!.artist
                                                    ?.name ??
                                                '',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w200,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  width: 12,
                                ),
                                Expanded(
                                  child: Row(
                                    children: [
                                      if (widget.playerController
                                              .favoriteButton !=
                                          null)
                                        widget.playerController.favoriteButton!
                                            .call(context,
                                                data.currentPlayingItem!),
                                      DownloadButton(
                                        controller: widget.downloaderController,
                                        track: data.currentPlayingItem!,
                                      ),
                                      if (data.tracksFromSmartQueue.contains(
                                          data.currentPlayingItem!.hash))
                                        IconButton(
                                          onPressed: () {
                                            widget.playerController
                                                .onAddSmartQueueItem
                                                ?.call(
                                              data.currentPlayingItem!,
                                            );
                                          },
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          icon: const Icon(
                                            Icons.add_circle_rounded,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Stack(
                                    fit: StackFit.loose,
                                    children: [
                                      IconButton(
                                        onPressed: () async {
                                          await widget.playerController.methods
                                              .toggleShuffle();
                                        },
                                        icon: Icon(
                                          Icons.shuffle_rounded,
                                          size: 20,
                                          color: data.shuffleEnabled
                                              ? Theme.of(context)
                                                  .buttonTheme
                                                  .colorScheme
                                                  ?.primary
                                              : null,
                                        ),
                                      ),
                                      if (data.shuffleEnabled) ...[
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 17,
                                            top: 23,
                                          ),
                                          child: Icon(
                                            Icons.fiber_manual_record,
                                            size: 5,
                                            color: Theme.of(context)
                                                .buttonTheme
                                                .colorScheme
                                                ?.primary,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 10,
                                            top: 17,
                                          ),
                                          child: Icon(
                                            Icons.fiber_manual_record,
                                            size: 6,
                                            color: Theme.of(context)
                                                .buttonTheme
                                                .colorScheme
                                                ?.primary,
                                          ),
                                        ),
                                      ]
                                    ],
                                  ),
                                  Builder(builder: (context) {
                                    bool previousEnabled = true;
                                    if (data.queue.firstOrNull?.id ==
                                        data.currentPlayingItem!.id) {
                                      if (!data.shuffleEnabled) {
                                        if (data.repeatMode ==
                                                MusilyRepeatMode.noRepeat ||
                                            data.repeatMode ==
                                                MusilyRepeatMode.repeatOne) {
                                          if (data.currentPlayingItem!.position
                                                  .inSeconds <
                                              5) {
                                            previousEnabled = false;
                                          }
                                        }
                                      }
                                    }
                                    return IconButton(
                                      onPressed: !previousEnabled
                                          ? null
                                          : () async {
                                              if (data.currentPlayingItem!
                                                      .position.inSeconds <
                                                  5) {
                                                await widget
                                                    .playerController.methods
                                                    .previousInQueue();
                                              } else {
                                                widget.playerController.methods
                                                    .seek(
                                                  Duration.zero,
                                                );
                                              }
                                            },
                                      icon: const Icon(
                                        Icons.skip_previous_rounded,
                                        size: 30,
                                      ),
                                    );
                                  }),
                                  IconButton(
                                    onPressed: () {
                                      if (data.isPlaying) {
                                        widget.playerController.methods.pause();
                                      } else {
                                        widget.playerController.methods
                                            .resume();
                                      }
                                    },
                                    icon: Icon(
                                      data.isPlaying
                                          ? Icons.pause_circle_filled_rounded
                                          : Icons.play_circle_rounded,
                                      size: 40,
                                    ),
                                  ),
                                  Builder(builder: (context) {
                                    bool nextEnabled = true;
                                    if (data.queue.lastOrNull?.id ==
                                        data.currentPlayingItem!.id) {
                                      if (!data.shuffleEnabled) {
                                        if (data.repeatMode ==
                                                MusilyRepeatMode.noRepeat ||
                                            data.repeatMode ==
                                                MusilyRepeatMode.repeatOne) {
                                          nextEnabled = false;
                                        }
                                      }
                                    }
                                    return IconButton(
                                      onPressed: !nextEnabled
                                          ? null
                                          : () async {
                                              await widget
                                                  .playerController.methods
                                                  .nextInQueue();
                                            },
                                      icon: const Icon(
                                        Icons.skip_next_rounded,
                                        size: 30,
                                      ),
                                    );
                                  }),
                                  IconButton(
                                    onPressed: () async {
                                      await widget.playerController.methods
                                          .toggleRepeatState();
                                    },
                                    icon: Stack(
                                      children: [
                                        Icon(
                                          () {
                                            switch (data.repeatMode) {
                                              case MusilyRepeatMode.noRepeat:
                                                return Icons.repeat_rounded;
                                              case MusilyRepeatMode.repeat:
                                                return Icons.repeat_rounded;
                                              case MusilyRepeatMode.repeatOne:
                                                return Icons.repeat_one_rounded;
                                            }
                                          }(),
                                          size: 20,
                                          color: data.repeatMode !=
                                                  MusilyRepeatMode.noRepeat
                                              ? Theme.of(context)
                                                  .buttonTheme
                                                  .colorScheme
                                                  ?.primary
                                              : null,
                                        ),
                                        if (data.repeatMode ==
                                            MusilyRepeatMode.repeat)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 7,
                                              top: 7,
                                            ),
                                            child: Icon(
                                              Icons.fiber_manual_record,
                                              size: 6,
                                              color: Theme.of(context)
                                                  .buttonTheme
                                                  .colorScheme
                                                  ?.primary,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Builder(builder: (context) {
                                  late final Duration duration;
                                  if (_useSeekDuration) {
                                    duration = _seekDuration;
                                  } else {
                                    duration =
                                        data.currentPlayingItem!.position;
                                  }
                                  return Text(
                                    formatDuration(duration),
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  );
                                }),
                                Slider(
                                  min: 0,
                                  max: data
                                      .currentPlayingItem!.duration.inSeconds
                                      .toDouble(),
                                  value: () {
                                    if (data.currentPlayingItem!.position
                                            .inSeconds >
                                        data.currentPlayingItem!.duration
                                            .inSeconds) {
                                      return 0.0;
                                    }
                                    if (_useSeekDuration) {
                                      return _seekDuration.inSeconds.toDouble();
                                    }
                                    if (data.currentPlayingItem!.position
                                            .inSeconds
                                            .toDouble() >=
                                        0) {
                                      return data.currentPlayingItem!.position
                                          .inSeconds
                                          .toDouble();
                                    }
                                    return 0.0;
                                  }(),
                                  onChanged: (value) {
                                    setState(() {
                                      _useSeekDuration = true;
                                      _seekDuration =
                                          Duration(seconds: value.toInt());
                                    });
                                  },
                                  onChangeEnd: (value) async {
                                    setState(() {
                                      _useSeekDuration = false;
                                    });
                                    await widget.playerController.methods
                                        .seek(_seekDuration);
                                    await widget.playerController.methods
                                        .resume();
                                  },
                                ),
                                Text(
                                  formatDuration(
                                      data.currentPlayingItem!.duration),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                Stack(
                                  fit: StackFit.loose,
                                  children: [
                                    IconButton(
                                      onPressed: data.queue.length < 2
                                          ? null
                                          : () {
                                              widget.playerController.methods
                                                  .toggleShowQueue();
                                            },
                                      icon: Icon(
                                        Icons.queue_music_rounded,
                                        size: 20,
                                        color: data.showQueue
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : null,
                                      ),
                                    ),
                                    if (data.showQueue)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 28,
                                          left: 17,
                                        ),
                                        child: Icon(
                                          Icons.fiber_manual_record,
                                          size: 6,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                  ],
                                ),
                                Stack(
                                  fit: StackFit.loose,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        widget.playerController.methods
                                            .toggleLyrics(
                                          data.currentPlayingItem!.id,
                                        );
                                      },
                                      iconSize: 20,
                                      icon: Icon(
                                        Icons.lyrics_rounded,
                                        color: data.showLyrics
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : null,
                                      ),
                                    ),
                                    if (data.showLyrics)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 28,
                                          left: 16,
                                        ),
                                        child: Icon(
                                          Icons.fiber_manual_record,
                                          size: 6,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      )
                                  ],
                                ),
                                if (widget
                                        .playerController.trackOptionsWidget !=
                                    null)
                                  widget.playerController.trackOptionsWidget!
                                      .call(context, data.currentPlayingItem!),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    });
  }
}
