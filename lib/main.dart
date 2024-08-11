import 'package:flutter/material.dart';
import 'package:musily_player/musily_service.dart';
import 'package:musily_player/player.dart';
import 'package:musily_player/presenter/controllers/downloader/downloader_controller.dart';
import 'package:musily_player/presenter/controllers/player/player_controller.dart';
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
    getSmartQueue: (currentQueue) async {
      await Future.delayed(
        const Duration(
          seconds: 2,
        ),
      );
      return currentQueue;
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
