import 'package:flutter/material.dart';
import 'package:musily_player/widget/player_controller/player_controller.dart';
import 'package:musily_player/widget/player_widget.dart';
import 'package:musily_player/widget/utils/app_animated_dialog.dart';
import 'package:musily_player/widget/utils/infinity_marquee.dart';

class MiniPlayerWidget extends StatelessWidget {
  final PlayerController playerController;
  const MiniPlayerWidget({
    required this.playerController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return playerController.builder(
      builder: (context, data) {
        if (data.currentPlayingItem != null) {
          return InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AppAnimatedDialog(
                  builder: (context, onClose) {
                    return PlayerWidget(
                      onClose: onClose,
                      playerController: playerController,
                    );
                  },
                ),
              );
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  width: 1,
                  color: Theme.of(context).colorScheme.outline.withOpacity(.2),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
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
                              child: Builder(
                                builder: (context) {
                                  if (data.currentPlayingItem!.lowResImg !=
                                          null &&
                                      data.currentPlayingItem!.lowResImg!
                                          .isNotEmpty) {
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        data.currentPlayingItem!.lowResImg!,
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
                            const SizedBox(
                              width: 12,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 180,
                                  child: InfinityMarquee(
                                    child: Text(
                                      data.currentPlayingItem!.title ?? '',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 180,
                                  child: InfinityMarquee(
                                    child: Text(
                                      data.currentPlayingItem!.artist?.name ??
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
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                playerController.methods.toggleFavorite();
                              },
                              icon: const Icon(
                                Icons.favorite_border_rounded,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                if (data.isPlaying) {
                                  playerController.methods.pause();
                                } else {
                                  playerController.methods.resume();
                                }
                              },
                              icon: Icon(
                                data.isPlaying ? Icons.pause : Icons.play_arrow,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: SizedBox(
                      height: 2,
                      child: Builder(builder: (context) {
                        late final double progressBarValue;
                        final progress = data.currentPlayingItem!.position;
                        final total = data.currentPlayingItem!.duration;
                        if (progress.inMilliseconds == 0 ||
                            total.inMilliseconds == 0) {
                          progressBarValue = 0;
                        } else {
                          progressBarValue =
                              progress.inMilliseconds / total.inMilliseconds;
                        }
                        return LinearProgressIndicator(
                          value: progressBarValue,
                          backgroundColor: Colors.white.withOpacity(.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).buttonTheme.colorScheme!.primary,
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return Container();
      },
    );
  }
}
