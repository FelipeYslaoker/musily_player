import 'package:flutter/material.dart';
import 'package:flutter_download_manager/flutter_download_manager.dart';
import 'package:musily_player/core/utils/display_helper.dart';
import 'package:musily_player/core/utils/is_valid_directory.dart';
import 'package:musily_player/musily_player.dart';
import 'package:musily_player/presenter/controllers/downloader/downloader_controller.dart';
import 'package:musily_player/presenter/controllers/downloader/downloader_data.dart';
import 'package:percent_indicator/percent_indicator.dart';

class DownloadButton extends StatelessWidget {
  final DownloaderController controller;
  final MusilyTrack track;
  const DownloadButton({
    super.key,
    required this.controller,
    required this.track,
  });

  @override
  Widget build(BuildContext context) {
    return controller.builder(
      builder: (context, data) {
        final displayHelper = DisplayHelper(context);
        final item = controller.methods.getItem(track);
        final iconSize = displayHelper.isDesktop ? 20.0 : null;
        if (item != null) {
          if (item.status == DownloadStatus.queued) {
            return IconButton(
              onPressed: () {},
              iconSize: iconSize,
              icon: Icon(
                Icons.hourglass_bottom_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          }
          if (item.status == DownloadStatus.downloading) {
            return IconButton(
              onPressed: () {},
              icon: SizedBox(
                height: iconSize,
                width: iconSize,
                child: CircularPercentIndicator(
                  lineWidth: 4,
                  startAngle: 180,
                  progressColor: Theme.of(context).colorScheme.primary,
                  backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                  percent: item.progress,
                  radius: 10,
                ),
              ),
            );
          }
          if (item.status == DownloadStatus.completed &&
              isValidDirectory(item.track.url ?? '')) {
            return IconButton(
              onPressed: () {},
              iconSize: iconSize,
              icon: Icon(
                Icons.download_done_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          }
        }
        return IconButton(
          onPressed: () {
            controller.methods.addDownload(
              track,
            );
          },
          iconSize: iconSize,
          icon: Icon(
            Icons.download_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
        );
      },
    );
  }
}

class DownloadButtonBuilder extends StatelessWidget {
  final DownloaderController controller;
  final MusilyTrack track;
  final Function(
    BuildContext context,
    DownloadingItem? item,
  ) builder;
  const DownloadButtonBuilder({
    required this.controller,
    required this.track,
    required this.builder,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return controller.builder(
      builder: (context, data) => builder(
        context,
        controller.methods.getItem(track),
      ),
    );
  }
}
