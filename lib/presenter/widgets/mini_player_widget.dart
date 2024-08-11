import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:musily_player/core/presenter/widgets/app_image.dart';
import 'package:musily_player/core/presenter/widgets/infinity_marquee.dart';
import 'package:musily_player/presenter/controllers/downloader/downloader_controller.dart';
import 'package:musily_player/presenter/controllers/player/player_controller.dart';
import 'package:musily_player/core/presenter/routers/downup_router.dart';
import 'package:musily_player/presenter/widgets/mini_player_desktop.dart';
import 'package:musily_player/presenter/widgets/player_widget.dart';

class MiniPlayerWidget extends StatefulWidget {
  final DownloaderController downloaderController;
  final PlayerController playerController;

  const MiniPlayerWidget({
    required this.playerController,
    required this.downloaderController,
    super.key,
  });

  @override
  State<MiniPlayerWidget> createState() => _MiniPlayerWidgetState();
}

class _MiniPlayerWidgetState extends State<MiniPlayerWidget> {
  @override
  Widget build(BuildContext context) {
    return widget.playerController.builder(
      builder: (context, data) {
        final isDesktop = MediaQuery.of(context).size.width > 1100;
        if (data.currentPlayingItem != null) {
          return isDesktop
              ? MiniPlayerDesktop(
                  playerController: widget.playerController,
                  downloaderController: widget.downloaderController,
                )
              : InkWell(
                  onTap: () async {
                    widget.playerController.onPlayerExpanded?.call();
                    Navigator.of(context).push(
                      DownupRouter(
                        builder: (context) => PlayerWidget(
                          playerController: widget.playerController,
                          downloaderController: widget.downloaderController,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        width: 1,
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withOpacity(.2),
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
                                        if (data.currentPlayingItem!
                                                    .lowResImg !=
                                                null &&
                                            data.currentPlayingItem!.lowResImg!
                                                .isNotEmpty) {
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
                                  const SizedBox(
                                    width: 12,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 180,
                                        child: InfinityMarquee(
                                          child: Text(
                                            data.currentPlayingItem!.title ??
                                                '',
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
                                ],
                              ),
                              Row(
                                children: [
                                  if (widget.playerController.favoriteButton !=
                                      null)
                                    widget.playerController.favoriteButton!
                                        .call(
                                            context, data.currentPlayingItem!),
                                  Builder(builder: (context) {
                                    if (data.currentPlayingItem?.duration
                                            .inSeconds ==
                                        0) {
                                      return SizedBox(
                                        width: 48,
                                        height: 30,
                                        child: Center(
                                          child: LoadingAnimationWidget
                                              .halfTriangleDot(
                                            color: Theme.of(context)
                                                    .iconTheme
                                                    .color ??
                                                Colors.white,
                                            size: 18,
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
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                        size: 30,
                                      ),
                                    );
                                  }),
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
                              final progress =
                                  data.currentPlayingItem!.position;
                              final total = data.currentPlayingItem!.duration;
                              if (progress.inMilliseconds == 0 ||
                                  total.inMilliseconds == 0) {
                                progressBarValue = 0;
                              } else {
                                progressBarValue = progress.inMilliseconds /
                                    total.inMilliseconds;
                              }
                              return LinearProgressIndicator(
                                value: progressBarValue,
                                backgroundColor: Colors.white.withOpacity(.2),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context)
                                      .buttonTheme
                                      .colorScheme!
                                      .primary,
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
