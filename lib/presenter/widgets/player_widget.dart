import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:musily_player/core/presenter/widgets/infinity_marquee.dart';
import 'package:musily_player/core/utils/format_duration.dart';
import 'package:musily_player/musily_player.dart';
import 'package:musily_player/presenter/controllers/downloader/downloader_controller.dart';
import 'package:musily_player/presenter/widgets/download_button.dart';
import 'package:musily_player/presenter/widgets/player_background.dart';
import 'package:musily_player/presenter/widgets/player_banner.dart';
import 'package:musily_player/presenter/controllers/player/player_controller.dart';
import 'package:musily_player/presenter/widgets/queue_widget.dart';

class PlayerWidget extends StatefulWidget {
  final PlayerController playerController;
  final DownloaderController downloaderController;

  const PlayerWidget({
    required this.playerController,
    required this.downloaderController,
    super.key,
  });

  @override
  State<PlayerWidget> createState() => _PlayerWidgetState();
}

class _PlayerWidgetState extends State<PlayerWidget> {
  Duration _seekDuration = Duration.zero;
  bool _useSeekDuration = false;
  bool loadingAlbum = true;

  @override
  Widget build(BuildContext context) {
    return widget.playerController.builder(
      eventListener: (context, event, data) {
        if (event.id == 'closePlayer') {
          try {
            Navigator.pop(context);
          } catch (e) {
            Navigator.canPop(context);
          }
          widget.playerController.onPlayerCollapsed?.call();
        }
      },
      builder: (context, data) {
        return PopScope(
          onPopInvoked: (didPop) {
            widget.playerController.onPlayerCollapsed?.call();
          },
          child: widget.playerController.builder(
            builder: (context, data) {
              final currentPlayingItem = data.currentPlayingItem!;
              return Scaffold(
                body: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (currentPlayingItem.highResImg != null &&
                        currentPlayingItem.highResImg!.isNotEmpty)
                      PlayerBackground(
                        imageUrl: currentPlayingItem.highResImg!,
                        playerController: widget.playerController,
                      ),
                    SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: 8,
                              left: 12,
                              right: 12,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Builder(
                                  builder: (context) {
                                    return IconButton(
                                      onPressed: () {
                                        widget.playerController.methods
                                            .closePlayer();
                                      },
                                      icon: const Icon(
                                        Icons.keyboard_arrow_down,
                                        size: 30,
                                      ),
                                    );
                                  },
                                ),
                                Stack(
                                  children: [
                                    AnimatedOpacity(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      opacity: data.showLyrics ? 1 : 0,
                                      child: Switch(
                                        activeColor: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                        thumbIcon: const WidgetStatePropertyAll(
                                          Icon(Icons.sync_rounded),
                                        ),
                                        value: data.syncedLyrics,
                                        onChanged: data.showLyrics
                                            ? (value) {
                                                widget.playerController.methods
                                                    .toggleSyncedLyrics();
                                              }
                                            : null,
                                      ),
                                    ),
                                    if (widget.playerController.getSmartQueue !=
                                        null)
                                      AnimatedOpacity(
                                        opacity: data.showLyrics ? 0 : 1,
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        child: data.showLyrics
                                            ? const SizedBox.shrink()
                                            : IconButton(
                                                onPressed:
                                                    data.loadingSmartQueue
                                                        ? null
                                                        : () {
                                                            widget
                                                                .playerController
                                                                .methods
                                                                .toggleSmartQueue();
                                                          },
                                                icon: data.loadingSmartQueue
                                                    ? LoadingAnimationWidget
                                                        .threeRotatingDots(
                                                        color: IconTheme.of(
                                                                    context)
                                                                .color ??
                                                            Theme.of(context)
                                                                .primaryColor,
                                                        size: 20,
                                                      )
                                                    : Icon(
                                                        data.tracksFromSmartQueue
                                                                .isEmpty
                                                            ? CupertinoIcons
                                                                .wand_rays_inverse
                                                            : CupertinoIcons
                                                                .wand_stars,
                                                        color: data
                                                                .tracksFromSmartQueue
                                                                .isEmpty
                                                            ? IconTheme.of(
                                                                    context)
                                                                .color
                                                            : Theme.of(context)
                                                                .colorScheme
                                                                .primary,
                                                      ),
                                              ),
                                      ),
                                  ],
                                ),
                                if (widget
                                        .playerController.trackOptionsWidget !=
                                    null)
                                  widget.playerController.trackOptionsWidget!
                                      .call(
                                    context,
                                    data.currentPlayingItem!,
                                  ),
                              ],
                            ),
                          ),
                          PlayerBanner(
                            track: currentPlayingItem,
                            playerController: widget.playerController,
                          ),
                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: ListTile(
                                  title: InfinityMarquee(
                                    child: Text(
                                      currentPlayingItem.title ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  subtitle: InkWell(
                                    onTap: () {
                                      Navigator.pop(context);
                                      if (currentPlayingItem.artist != null) {
                                        widget.playerController.onArtistInvoked
                                            ?.call(currentPlayingItem.artist!,
                                                context);
                                      }
                                    },
                                    child: InfinityMarquee(
                                      child: Text(
                                        currentPlayingItem.artist?.name ?? '',
                                      ),
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      DownloadButton(
                                        controller: widget.downloaderController,
                                        track: data.currentPlayingItem!,
                                      ),
                                      if (data.tracksFromSmartQueue
                                          .contains(currentPlayingItem.hash))
                                        IconButton(
                                          onPressed: () {
                                            widget.playerController
                                                .onAddSmartQueueItem
                                                ?.call(
                                              currentPlayingItem,
                                            );
                                          },
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          icon: const Icon(
                                            Icons.add_circle_rounded,
                                          ),
                                        ),
                                      if (widget.playerController
                                              .favoriteButton !=
                                          null)
                                        widget.playerController.favoriteButton!
                                            .call(context,
                                                data.currentPlayingItem!),
                                    ],
                                  ),
                                ),
                              ),
                              Slider(
                                inactiveColor: Theme.of(context)
                                    .buttonTheme
                                    .colorScheme
                                    ?.primary
                                    .withOpacity(.3),
                                min: 0,
                                max: currentPlayingItem.duration.inSeconds
                                    .toDouble(),
                                value: () {
                                  if (currentPlayingItem.position.inSeconds >
                                      currentPlayingItem.duration.inSeconds) {
                                    return 0.0;
                                  }
                                  if (_useSeekDuration) {
                                    return _seekDuration.inSeconds.toDouble();
                                  }
                                  if (currentPlayingItem.position.inSeconds
                                          .toDouble() >=
                                      0) {
                                    return currentPlayingItem.position.inSeconds
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
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 24),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Builder(builder: (context) {
                                      late final Duration duration;
                                      if (_useSeekDuration) {
                                        duration = _seekDuration;
                                      } else {
                                        duration = currentPlayingItem.position;
                                      }
                                      return Text(
                                        formatDuration(duration),
                                      );
                                    }),
                                    Text(
                                      formatDuration(
                                        currentPlayingItem.duration,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Stack(
                                      fit: StackFit.loose,
                                      children: [
                                        IconButton(
                                          onPressed: () async {
                                            await widget
                                                .playerController.methods
                                                .toggleShuffle();
                                          },
                                          icon: Icon(
                                            Icons.shuffle_rounded,
                                            size: 30,
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
                                              left: 21.5,
                                              top: 28,
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
                                              left: 11,
                                              top: 19,
                                            ),
                                            child: Icon(
                                              Icons.fiber_manual_record,
                                              size: 8,
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
                                      if (data.queue.first.id ==
                                          currentPlayingItem.id) {
                                        if (!data.shuffleEnabled) {
                                          if (data.repeatMode ==
                                                  MusilyRepeatMode.noRepeat ||
                                              data.repeatMode ==
                                                  MusilyRepeatMode.repeatOne) {
                                            if (currentPlayingItem
                                                    .position.inSeconds <
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
                                                if (currentPlayingItem
                                                        .position.inSeconds <
                                                    5) {
                                                  await widget
                                                      .playerController.methods
                                                      .previousInQueue();
                                                } else {
                                                  widget
                                                      .playerController.methods
                                                      .seek(
                                                    Duration.zero,
                                                  );
                                                }
                                              },
                                        icon: const Icon(
                                          Icons.skip_previous_rounded,
                                          size: 50,
                                        ),
                                      );
                                    }),
                                    Builder(builder: (context) {
                                      if (currentPlayingItem
                                              .duration.inSeconds ==
                                          0) {
                                        return SizedBox(
                                          width: 86,
                                          height: 86,
                                          child: Center(
                                            child: LoadingAnimationWidget
                                                .halfTriangleDot(
                                              color: Theme.of(context)
                                                      .iconTheme
                                                      .color ??
                                                  Colors.white,
                                              size: 30,
                                            ),
                                          ),
                                        );
                                      }
                                      return IconButton(
                                        onPressed: () {
                                          if (data.isPlaying) {
                                            widget.playerController.methods
                                                .pause();
                                          } else {
                                            widget.playerController.methods
                                                .resume();
                                          }
                                        },
                                        icon: Icon(
                                          data.isPlaying
                                              ? Icons
                                                  .pause_circle_filled_rounded
                                              : Icons.play_circle_rounded,
                                          size: 70,
                                        ),
                                      );
                                    }),
                                    Builder(builder: (context) {
                                      bool nextEnabled = true;
                                      if (data.queue.last.id ==
                                          currentPlayingItem.id) {
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
                                          size: 50,
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
                                                  return Icons
                                                      .repeat_one_rounded;
                                              }
                                            }(),
                                            size: 30,
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
                                                left: 11,
                                                top: 11,
                                              ),
                                              child: Icon(
                                                Icons.fiber_manual_record,
                                                size: 8,
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  IconButton(
                                    onPressed: () {},
                                    icon: const Icon(
                                      Icons.share_rounded,
                                      size: 20,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => widget
                                        .playerController.methods
                                        .toggleLyrics(
                                      currentPlayingItem.id,
                                    ),
                                    iconSize: 20,
                                    icon: Icon(
                                      !data.showLyrics
                                          ? Icons.lyrics_rounded
                                          : Icons.album_rounded,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (context) => Scaffold(
                                          body: SafeArea(
                                            child: QueueWidget(
                                              playerController:
                                                  widget.playerController,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.queue_music_rounded,
                                      size: 25,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
