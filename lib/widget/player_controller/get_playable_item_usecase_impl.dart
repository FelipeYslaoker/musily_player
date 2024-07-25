import 'package:musily_player/musily_player.dart';
import 'package:musily_player/widget/utils/app_error.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class GetPlayableItemUsecaseImpl {
  Future<MusilyTrack> exec(MusilyTrack track) async {
    final yt = YoutubeExplode();

    final searchResults = await yt.search.search(
      '${track.title} ${track.artist?.name ?? ''}',
    );

    if (searchResults.isEmpty) {
      throw AppError(
        code: 404,
        error: 'not_found',
        title: 'Arquivo não encontrado',
        message: 'O arquivo da música não foi encontrado.',
      );
    }

    final videoId = searchResults.first.id;

    final manifest = await yt.videos.streamsClient.getManifest(videoId);
    final audioSteamInfo = manifest.audioOnly.withHighestBitrate();

    return MusilyTrack(
      id: track.id,
      title: track.title,
      artist: MusilyArtist(
        id: track.artist?.id ?? '',
        name: track.artist?.name ?? '',
      ),
      ytId: videoId.toString(),
      highResImg: track.highResImg,
      lowResImg: track.lowResImg,
      url: audioSteamInfo.url.toString(),
    );
  }
}
