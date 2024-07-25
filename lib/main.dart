import 'package:flutter/material.dart';
import 'package:musily_player/musily_player.dart';
import 'package:musily_player/musily_service.dart';
import 'package:musily_player/player.dart';
import 'package:musily_player/widget/player_controller/player_controller.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await MusilyService.init(
    config: MusilyServiceConfig(
      androidNotificationChannelId: 'org.app.musily',
      androidNotificationChannelName: 'Musily Player',
      androidShowNotificationBadge: true,
    ),
  );
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final playerController = PlayerController(
    musilyPlayer: MusilyPlayer(),
  );
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
          playerController: playerController,
        ),
      ),
    );
  }
}
