import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:musily_player/musily_player.dart';
import 'package:musily_player/presenter/controllers/downloader/downloader_controller.dart';
import 'package:musily_player/presenter/controllers/player/player_controller.dart';
import 'package:musily_player/presenter/widgets/mini_player_widget.dart';

class AudioPlayerScreen extends StatefulWidget {
  final PlayerController playerController;
  final DownloaderController downloaderController;
  const AudioPlayerScreen({
    required this.playerController,
    required this.downloaderController,
    super.key,
  });

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  List<MusilyTrack> queue = [];
  bool loading = false;

  Future<MusilyTrack?> searchTrack(String name, BuildContext context) async {
    setState(() {
      loading = true;
    });
    final dio = Dio();
    final url = Uri.encodeFull(
      'https://itunes.apple.com/search?key=music&term=$name&limit=1&explicit=Yes',
    );
    final response = await dio.get(url);
    final data = jsonDecode(response.data)['results'];
    if (data == null || (data as List).isEmpty) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Música não encontrada.',
          ),
        ),
      );
      setState(() {
        loading = false;
      });
      return null;
    }
    final map = data[0];
    String artworkUrl = map['artworkUrl100'];
    String largeArtworkUrl = artworkUrl.replaceAll('100x100', '600x600');
    setState(() {
      loading = false;
    });
    final track = MusilyTrack(
      hash: map['trackId'].toString(),
      id: map['trackId'].toString(),
      title: map['trackName'],
      artist: MusilyArtist(
        id: '',
        name: map['artistName'],
      ),
      highResImg: largeArtworkUrl,
      fromSmartQueue: true,
      lowResImg: artworkUrl,
    );
    return track;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
            child: Column(
              children: [
                TextField(
                  enabled: !loading,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Nome da música',
                    isDense: true,
                  ),
                  onSubmitted: (value) async {
                    final track = await searchTrack(value, context);
                    if (track == null) {
                      return;
                    }
                    final queue = widget.playerController.data.queue;
                    if (queue.isEmpty) {
                      widget.playerController.methods
                          .loadAndPlay(track, track.id);
                    } else {
                      widget.playerController.methods.addToQueue([track]);
                    }
                  },
                ),
                const SizedBox(
                  height: 12,
                ),
                FilledButton(
                  onPressed: () async {
                    final trackNames = [
                      'Royals Pure Heroine Lorde',
                      'Асия Не по пути',
                      'Алоэ Асия',
                      'bad_news Bastille',
                      'Sleepsong Bastille',
                      'I Am My Own Dune Moss',
                    ];
                    trackNames.shuffle();
                    for (final trackName in trackNames) {
                      final queue = widget.playerController.data.queue;
                      final track = await searchTrack(trackName, context);
                      if (queue.map((e) => e.id).contains(track?.id)) {
                        continue;
                      }
                      if (track == null) {
                        continue;
                      }
                      if (queue.isEmpty) {
                        widget.playerController.methods
                            .loadAndPlay(track, track.id);
                      } else {
                        widget.playerController.methods.addToQueue([track]);
                        widget.playerController.updateData(
                          widget.playerController.data.copyWith(
                            tracksFromSmartQueue: widget
                                .playerController.data.tracksFromSmartQueue
                              ..add(track.id),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Construir fila'),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: MiniPlayerWidget(
              playerController: widget.playerController,
              downloaderController: widget.downloaderController,
            ),
          ),
        ],
      ),
    );
  }
}
