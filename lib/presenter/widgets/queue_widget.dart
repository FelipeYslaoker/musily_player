import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:musily_player/core/presenter/widgets/app_image.dart';
import 'package:musily_player/core/presenter/widgets/infinity_marquee.dart';
import 'package:musily_player/presenter/controllers/player/player_controller.dart';
import 'package:musily_player/presenter/widgets/track_tile_static.dart';

class QueueWidget extends StatelessWidget {
  final PlayerController playerController;
  const QueueWidget({
    required this.playerController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return playerController.builder(
      builder: (context, data) {
        return Column(
          children: [
            if (data.currentPlayingItem != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    playerController.customQueueHeader?.call(context) ??
                        Text(
                          playerController.localization?.playingNow ??
                              'Playing Now',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                    if (playerController.onAddSmartQueueItem != null)
                      IconButton(
                        iconSize: 20,
                        onPressed: data.loadingSmartQueue
                            ? null
                            : () {
                                playerController.methods.toggleSmartQueue();
                              },
                        icon: data.loadingSmartQueue
                            ? LoadingAnimationWidget.threeRotatingDots(
                                color: IconTheme.of(context).color ??
                                    Theme.of(context).primaryColor,
                                size: 20,
                              )
                            : Icon(
                                data.tracksFromSmartQueue.isEmpty
                                    ? CupertinoIcons.wand_rays_inverse
                                    : CupertinoIcons.wand_stars,
                                color: data.tracksFromSmartQueue.isEmpty
                                    ? IconTheme.of(context).color
                                    : Theme.of(context).colorScheme.primary,
                              ),
                      ),
                  ],
                ),
              ),
              TrackTileStatic(
                track: data.currentPlayingItem!,
              ),
              const Divider(),
            ],
            Expanded(
              child: ReorderableListView.builder(
                itemCount: data.queue.length,
                onReorder: (oldIndex, newIndex) async {
                  await playerController.methods
                      .reorderQueue(newIndex, oldIndex);
                },
                itemBuilder: (context, index) {
                  final playing =
                      data.queue[index].id == data.currentPlayingItem?.id;
                  return Container(
                    color: data.tracksFromSmartQueue
                            .contains(data.queue[index].hash)
                        ? Theme.of(context).colorScheme.primary.withOpacity(.2)
                        : Colors.transparent,
                    margin: EdgeInsets.zero,
                    key: Key(index.toString()),
                    child: ListTile(
                      onTap: () async {
                        await playerController.methods.queueJumpTo(index);
                      },
                      contentPadding:
                          const EdgeInsets.only(left: 12, right: 80),
                      title: InfinityMarquee(
                        child: Text(
                          data.queue[index].title ?? '',
                          style: playing
                              ? TextStyle(
                                  color: Theme.of(context)
                                      .buttonTheme
                                      .colorScheme
                                      ?.primary,
                                  fontWeight: FontWeight.bold,
                                )
                              : null,
                        ),
                      ),
                      subtitle: InfinityMarquee(
                        child: Text(
                          data.queue[index].artist?.name ?? '',
                          style: playing
                              ? TextStyle(
                                  color: Theme.of(context)
                                      .buttonTheme
                                      .colorScheme
                                      ?.primary,
                                )
                              : null,
                        ),
                      ),
                      leading: playing
                          ? SizedBox(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 13.5),
                                child: LoadingAnimationWidget.staggeredDotsWave(
                                  color: Theme.of(context)
                                          .buttonTheme
                                          .colorScheme
                                          ?.primary ??
                                      Colors.white,
                                  size: 20,
                                ),
                              ),
                            )
                          : Card(
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
                                  if (data.queue[index].lowResImg != null &&
                                      data.queue[index].lowResImg!.isNotEmpty) {
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: SizedBox(
                                        width: 40,
                                        child: AppImage(
                                          data.queue[index].lowResImg!,
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  }
                                  return SizedBox(
                                    height: 40,
                                    width: 40,
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
                      trailing: data.tracksFromSmartQueue
                              .contains(data.queue[index].hash)
                          ? Icon(
                              CupertinoIcons.wand_stars,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
                      key: Key('$index'),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
