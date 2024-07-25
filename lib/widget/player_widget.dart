import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:musily_player/musily_player.dart';
import 'package:musily_player/widget/player_controller/player_controller.dart';
import 'package:musily_player/widget/queue_widget.dart';
import 'package:musily_player/widget/utils/infinity_marquee.dart';

class PlayerWidget extends StatefulWidget {
  final PlayerController playerController;
  final void Function()? onClose;
  const PlayerWidget({
    required this.playerController,
    this.onClose,
    super.key,
  });

  @override
  State<PlayerWidget> createState() => _PlayerWidgetState();
}

class _PlayerWidgetState extends State<PlayerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  Duration _seekDuration = Duration.zero;
  bool _useSeekDuration = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10), // Duração da animação
      vsync: this,
    )
      ..forward()
      ..addListener(() {
        setState(() {
          _animation = Tween<Offset>(
            begin: Offset.zero,
            end: const Offset(0.08, 0), // Quantidade de deslocamento
          ).animate(
            CurvedAnimation(
              parent: _controller,
              curve: Curves.easeInOut, // Curva linear para movimento suave
            ),
          );
        });
        if (_controller.isCompleted) {
          _controller.repeat(reverse: true);
        }
      });
    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.2, 0), // Quantidade de deslocamento
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut, // Curva linear para movimento suave
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width;
    final maxHeight = MediaQuery.of(context).size.height;
    return widget.playerController.builder(
      builder: (context, data) {
        final currentPlayingItem = data.currentPlayingItem!;
        return Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              if (currentPlayingItem.highResImg != null &&
                  currentPlayingItem.highResImg!.isNotEmpty)
                AnimatedPositioned(
                  duration: const Duration(
                    milliseconds: 500,
                  ),
                  curve: Curves.easeInOut,
                  left: _animation.value.dx * maxWidth,
                  top: _animation.value.dy * maxHeight,
                  child: SizedBox(
                    width: maxWidth,
                    height: maxHeight,
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Image.network(
                        currentPlayingItem.highResImg!,
                        fit: BoxFit.cover,
                        color: Colors.black.withOpacity(0.6),
                        colorBlendMode: BlendMode.darken,
                      ),
                    ),
                  ),
                ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Builder(
                          builder: (context) {
                            if (widget.onClose != null) {
                              return IconButton(
                                onPressed: () {
                                  widget.onClose!.call();
                                },
                                icon: const Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 30,
                                ),
                              );
                            }
                            return Container();
                          },
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.more_vert,
                            size: 25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Builder(
                      builder: (context) {
                        if (currentPlayingItem.highResImg != null &&
                            currentPlayingItem.highResImg!.isNotEmpty) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              currentPlayingItem.highResImg!,
                              fit: BoxFit.cover,
                            ),
                          );
                        }
                        return Card(
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 350,
                                child: Icon(
                                  Icons.music_note,
                                  size: 75,
                                  color: Theme.of(context)
                                      .iconTheme
                                      .color
                                      ?.withOpacity(.8),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
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
                          subtitle: InfinityMarquee(
                            child: Text(
                              currentPlayingItem.artist?.name ?? '',
                            ),
                          ),
                          trailing: IconButton(
                            onPressed: () {
                              widget.playerController.methods.toggleFavorite();
                            },
                            icon: const Icon(
                              Icons.favorite_outline_rounded,
                            ),
                          ),
                        ),
                      ),
                      Slider(
                        min: 0,
                        max: currentPlayingItem.duration.inSeconds.toDouble(),
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
                            _seekDuration = Duration(seconds: value.toInt());
                          });
                        },
                        onChangeEnd: (value) async {
                          setState(() {
                            _useSeekDuration = false;
                          });
                          await widget.playerController.methods
                              .seek(_seekDuration);
                          await widget.playerController.methods.resume();
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Builder(builder: (context) {
                              late final Duration duration;
                              if (_useSeekDuration) {
                                duration = _seekDuration;
                              } else {
                                duration = currentPlayingItem.position;
                              }
                              return Text(
                                  '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}');
                            }),
                            Text(
                                '${currentPlayingItem.duration.inMinutes}:${(currentPlayingItem.duration.inSeconds % 60).toString().padLeft(2, '0')}'),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                        left: 21.5, top: 28),
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
                                        left: 12, top: 20),
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
                                    if (currentPlayingItem.position.inSeconds <
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
                                          await widget.playerController.methods
                                              .previousInQueue();
                                        } else {
                                          widget.playerController.methods.seek(
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
                            IconButton(
                              onPressed: () {
                                if (data.isPlaying) {
                                  widget.playerController.methods.pause();
                                } else {
                                  widget.playerController.methods.resume();
                                }
                              },
                              icon: Icon(
                                data.isPlaying
                                    ? Icons.pause_circle_filled_rounded
                                    : Icons.play_circle_rounded,
                                size: 70,
                              ),
                            ),
                            Builder(builder: (context) {
                              bool nextEnabled = true;
                              if (data.queue.last.id == currentPlayingItem.id) {
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
                                        await widget.playerController.methods
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
                                          return Icons.repeat_one_rounded;
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
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.share_rounded,
                              size: 20,
                            ),
                          ),
                          IconButton(
                            onPressed: data.queue.length < 2
                                ? null
                                : () {
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (context) {
                                        return QueueWidget(
                                          playerController:
                                              widget.playerController,
                                        );
                                      },
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
            ],
          ),
        );
      },
    );
  }
}
