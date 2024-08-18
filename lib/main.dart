import 'package:flutter/material.dart';
import 'package:musily_player/musily_player.dart';
import 'package:musily_player/musily_service.dart';
import 'package:musily_player/player.dart';
import 'package:musily_player/presenter/controllers/downloader/downloader_controller.dart';
import 'package:musily_player/presenter/controllers/player/player_controller.dart';
import 'package:musily_repository/core/data/entities/simplified_album_entity_impl.dart';
import 'package:musily_repository/core/data/entities/simplified_artist_entity_impl.dart';
import 'package:musily_repository/core/data/repositories/musily_repository.dart';
import 'package:musily_repository/core/domain/entities/track_entity.dart';
import 'package:musily_repository/core/domain/enums/source.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  await MusilyService.init(
    config: MusilyServiceConfig(
      androidNotificationChannelId: 'com.example.musily_player',
      androidNotificationChannelName: 'Musily Player',
      androidShowNotificationBadge: true,
    ),
  );

  final downloaderController = DownloaderController();
  final musilyRepository = MusilyRepository();
  await musilyRepository.initialize();

  final playerController = PlayerController(
    loadUrl: (track) async {
      final yt = YoutubeExplode();
      final searchResults = await yt.search.search(
        '${track.title} ${track.artist?.name}',
      );
      final ytId = searchResults.firstOrNull?.id;
      final manifest = await yt.videos.streamsClient.getManifest(ytId);
      final audioStremInfo = manifest.audioOnly.withHighestBitrate();
      final streamUrl = audioStremInfo.url.toString();
      return streamUrl;
    },
    favoriteButton: (context, track) => IconButton(
      onPressed: () {},
      icon: const Icon(
        Icons.favorite_rounded,
      ),
    ),
    getLyrics: (trackId) async {
      await Future.delayed(
        const Duration(
          seconds: 2,
        ),
      );
      return null;
    },
    onAddSmartQueueItem: (track) {
      track.fromSmartQueue = false;
    },
    getSmartQueue: (currentQueue) async {
      final smartQueue = await musilyRepository.getRelatedTracks(
        currentQueue
            .map(
              (track) => TrackEntity(
                id: track.id,
                hash: track.hash ?? '',
                title: track.title ?? '',
                artist: SimplifiedArtistEntityImpl(
                  id: track.artist?.id,
                  name: track.artist?.name,
                  source: Source.youtube,
                  highResImg: null,
                  lowResImg: null,
                ),
                album: SimplifiedAlbumEntityImpl(
                  id: track.album?.id ?? '',
                  title: track.album?.title ?? '',
                  artist: SimplifiedArtistEntityImpl(
                    id: track.artist?.id,
                    name: track.artist?.name,
                    source: Source.youtube,
                    highResImg: null,
                    lowResImg: null,
                  ),
                  lowResImg: null,
                  highResImg: null,
                  source: Source.youtube,
                ),
                lowResImg: track.lowResImg,
                highResImg: track.highResImg,
                source: Source.youtube,
                lyrics: null,
              ),
            )
            .toList(),
      );
      return smartQueue
          .map(
            (track) => MusilyTrack(
              id: track.id,
              ytId: track.id,
              album: MusilyAlbum(
                id: track.album.id,
                title: track.album.title,
              ),
              artist: MusilyArtist(
                id: track.artist.id ?? '',
                name: track.artist.name ?? '',
              ),
              fromSmartQueue: track.recommendedTrack,
              hash: track.hash,
              title: track.title,
              highResImg: track.highResImg,
              lowResImg: track.lowResImg,
            ),
          )
          .toList();
    },
  );

  runApp(
    MyApp(
      downloaderController: downloaderController,
      playerController: playerController,
    ),
  );
}

class MyApp extends StatefulWidget {
  final PlayerController playerController;
  final DownloaderController downloaderController;
  const MyApp({
    super.key,
    required this.playerController,
    required this.downloaderController,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      home: Scaffold(
        body: AudioPlayerScreen(
          playerController: widget.playerController,
          downloaderController: widget.downloaderController,
        ),
      ),
    );
  }
}
