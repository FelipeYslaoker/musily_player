import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:musily_player/core/presenter/widgets/app_image.dart';

import 'package:musily_player/musily_entities.dart';
import 'package:musily_player/presenter/controllers/player/player_controller.dart';
import 'package:musily_player/presenter/widgets/track_lyrics.dart';

class PlayerBanner extends StatefulWidget {
  final MusilyTrack track;
  final PlayerController playerController;

  const PlayerBanner({
    super.key,
    required this.track,
    required this.playerController,
  });

  @override
  State<PlayerBanner> createState() => _PlayerBannerState();
}

class _PlayerBannerState extends State<PlayerBanner> {
  @override
  Widget build(BuildContext context) {
    return widget.playerController.builder(
      builder: (context, data) {
        return Stack(
          children: [
            AnimatedOpacity(
              opacity: data.showLyrics ? 1.0 : 0.0,
              duration: Duration(milliseconds: data.showLyrics ? 400 : 70),
              child: SizedBox(
                height: MediaQuery.of(context).size.height - 414,
                width: MediaQuery.of(context).size.width,
                child: Builder(builder: (context) {
                  if (data.loadingLyrics) {
                    return Center(
                      child: LoadingAnimationWidget.waveDots(
                        color: IconTheme.of(context).color ?? Colors.white,
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
                                    ?.lyricsNotFound ??
                                'Lyrics not found',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w400,
                                    ),
                          )
                        ],
                      ),
                    );
                  }
                  return TrackLyrics(
                    totalDuration: widget.track.duration,
                    currentPosition: widget.track.position,
                    synced: data.syncedLyrics,
                    lyrics: data.lyrics.lyrics!,
                  );
                }),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height - 414,
              child: Center(
                child: AnimatedOpacity(
                  opacity: data.showLyrics ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: data.showLyrics
                      ? const SizedBox.shrink()
                      : MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap:
                                widget.track.album != null && !data.showLyrics
                                    ? () {
                                        if (widget.track.album != null) {
                                          Navigator.pop(context);
                                          widget.playerController.onAlbumInvoked
                                              ?.call(
                                            widget.track.album!,
                                            context,
                                          );
                                        }
                                      }
                                    : null,
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Builder(
                                    builder: (context) {
                                      if (widget.track.highResImg != null &&
                                          widget.track.highResImg!.isNotEmpty) {
                                        return ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: AppImage(
                                            height: 350,
                                            width: 350,
                                            widget.track.highResImg!,
                                            fit: BoxFit.cover,
                                          ),
                                        );
                                      }
                                      return Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          side: BorderSide(
                                            width: 1,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outline
                                                .withOpacity(.2),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              height: 350,
                                              width: 350,
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
                                if (data.tracksFromSmartQueue.contains(
                                  widget.track.hash ?? widget.track.id,
                                ))
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Container(
                                      height: 350,
                                      width: 350,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
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
                                          size: 60,
                                        ),
                                      ),
                                    ),
                                  )
                              ],
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
