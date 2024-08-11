import 'package:flutter/material.dart';
import 'package:musily_player/core/presenter/widgets/app_image.dart';
import 'package:musily_player/core/presenter/widgets/infinity_marquee.dart';
import 'package:musily_player/musily_player.dart';

class TrackTileStatic extends StatefulWidget {
  final MusilyTrack track;
  final Widget? trailing;
  const TrackTileStatic({
    required this.track,
    this.trailing,
    super.key,
  });

  @override
  State<TrackTileStatic> createState() => _TrackTileStaticState();
}

class _TrackTileStaticState extends State<TrackTileStatic> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: InfinityMarquee(
        child: Text(
          widget.track.title ?? '',
        ),
      ),
      leading: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            width: 1,
            color: Theme.of(context).colorScheme.outline.withOpacity(.2),
          ),
        ),
        child: Builder(
          builder: (context) {
            if (widget.track.lowResImg != null &&
                widget.track.highResImg!.isNotEmpty) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AppImage(
                  widget.track.lowResImg!,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              );
            }
            return SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                Icons.music_note,
                color: Theme.of(context).iconTheme.color?.withOpacity(.7),
              ),
            );
          },
        ),
      ),
      subtitle: InfinityMarquee(
        child: Text(
          widget.track.artist?.name ?? '',
        ),
      ),
      trailing: widget.trailing,
    );
  }
}
