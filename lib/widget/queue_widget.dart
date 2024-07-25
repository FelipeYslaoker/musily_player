import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:musily_player/widget/player_controller/player_controller.dart';
import 'package:musily_player/widget/utils/infinity_marquee.dart';

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
        return ReorderableListView.builder(
          itemCount: data.queue.length,
          onReorder: (oldIndex, newIndex) async {
            await playerController.methods.reorderQueue(newIndex, oldIndex);
          },
          itemBuilder: (context, index) {
            final playing = data.queue[index].id == data.currentPlayingItem?.id;
            return ListTile(
              onTap: () async {
                await playerController.methods.queueJumpTo(index);
              },
              contentPadding: const EdgeInsets.only(left: 12, right: 80),
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
                        padding: const EdgeInsets.all(8),
                        child: LoadingAnimationWidget.staggeredDotsWave(
                          color: Theme.of(context)
                                  .buttonTheme
                                  .colorScheme
                                  ?.primary ??
                              Colors.white,
                          size: 30,
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
                                width: 42,
                                child: Image.network(
                                  data.queue[index].lowResImg!,
                                  width: 42,
                                  height: 45,
                                ),
                              ),
                            );
                          }
                          return SizedBox(
                            height: 45,
                            width: 42,
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
              key: Key('$index'),
            );
          },
        );
      },
    );
  }
}
