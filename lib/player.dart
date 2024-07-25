import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:musily_player/musily_player.dart';
import 'package:musily_player/widget/mini_player_widget.dart';
import 'package:musily_player/widget/player_controller/player_controller.dart';

class AudioPlayerScreen extends StatefulWidget {
  final PlayerController playerController;
  const AudioPlayerScreen({
    required this.playerController,
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
    return MusilyTrack(
      id: map['trackId'].toString(),
      title: map['trackName'],
      artist: MusilyArtist(
        id: '',
        name: map['artistName'],
      ),
      highResImg: largeArtworkUrl,
      lowResImg: artworkUrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YouTube Audio Player'),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
            child: TextField(
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
                  widget.playerController.methods.loadAndPlay(track);
                } else {
                  final item = await widget.playerController.methods
                      .getPlayableItem(track);
                  widget.playerController.methods.addToQueue(item);
                }
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: MiniPlayerWidget(
              playerController: widget.playerController,
            ),
          ),
        ],
      ),
    );
  }
}
