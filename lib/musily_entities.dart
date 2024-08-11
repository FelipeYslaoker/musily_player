enum MusilyPlayerState {
  playing,
  stopped,
  paused,
  completed,
  disposed,
  loading,
  buffering,
}

enum MusilyRepeatMode {
  repeat,
  noRepeat,
  repeatOne,
}

enum MusilyPlayerAction {
  play,
  pause,
  stop,
  queueChanged,
}

class MusilyAlbum {
  String id;
  String title;
  MusilyAlbum({
    required this.id,
    required this.title,
  });
}

class MusilyArtist {
  String id;
  String name;
  MusilyArtist({
    required this.id,
    required this.name,
  });
}

class MusilyTrack {
  final String id;
  String? title;
  String? hash;
  MusilyArtist? artist;
  MusilyAlbum? album;
  String? highResImg;
  String? lowResImg;
  String? filePath;
  String? url;
  String? ytId;
  Duration duration;
  Duration position;
  Duration bufferedPosition;
  bool fromSmartQueue;

  MusilyTrack({
    required this.id,
    this.filePath,
    this.url,
    this.ytId,
    this.artist,
    this.album,
    this.highResImg,
    this.lowResImg,
    this.title,
    this.duration = Duration.zero,
    this.position = Duration.zero,
    this.bufferedPosition = Duration.zero,
    this.hash,
    this.fromSmartQueue = false,
  });
}
