import 'package:audio_service/audio_service.dart';
import 'package:musily_player/musily_entities.dart';

MediaItem mapToMediaItem(MusilyTrack track, String url) {
  bool isUrl(String string) {
    return RegExp(r'^https?:\/\/[^\s/$.?#].[^\s]*$').hasMatch(string);
  }

  Uri? artUri({bool useLowResImg = false}) {
    if (useLowResImg) {
      if (track.lowResImg != null) {
        return isUrl(track.lowResImg!)
            ? Uri.parse(track.lowResImg!)
            : Uri.file(track.lowResImg!);
      }
    } else {
      if (track.highResImg != null) {
        return isUrl(track.highResImg!)
            ? Uri.parse(track.highResImg!)
            : Uri.file(track.highResImg!);
      }
    }
    return null;
  }

  return MediaItem(
    id: track.id,
    album: '',
    artist: track.artist?.name,
    title: track.title ?? '',
    artUri: artUri(),
    extras: {
      'url': track.url,
      if (track.lowResImg != null)
        'lowResImage': artUri(
          useLowResImg: true,
        ).toString(),
      if (track.ytId != null) 'ytid': track.ytId,
      if (track.highResImg != null) 'artWorkPath': artUri().toString(),
    },
  );
}
