import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_download_manager/flutter_download_manager.dart';
import 'package:musily_player/musily_player.dart';
import 'package:musily_player/presenter/controllers/downloader/downloader_data.dart';

class DownloaderMethods {
  final Future<void> Function(
    MusilyTrack track, {
    int position,
  }) addDownload;
  final void Function(String key) setDownloadingKey;
  final Future<DownloadTask?> Function(
    String path,
    String url,
  ) downloadFile;
  final Future<void> Function(
    MusilyTrack track,
  ) downloadArtworks;
  final Future<void> Function(
    File file,
  ) saveMd5;
  final Future<bool> Function(
    String path,
  ) checkFileIntegrity;

  final Widget Function(
    BuildContext context,
    DownloadingItem item,
  ) trailing;

  final Future<void> Function({
    MusilyTrack? track,
    String? path,
  }) deleteDownloadedFile;
  final Future<void> Function(
    String url,
  ) cancelDownload;
  final Future<void> Function(
    List<MusilyTrack> tracks,
  ) cancelDownloadCollection;

  final Future<void> Function() loadStoredQueue;
  final Future<void> Function() updateStoredQueue;
  final bool Function(MusilyTrack track) isOffline;
  final DownloadingItem? Function(MusilyTrack track) getItem;
  final Future<String> Function(MusilyTrack track) getTrackPath;
  final Future<void> Function(
    DownloadTask task,
    DownloadingItem item,
    String downloadDir,
  ) registerListeners;

  DownloaderMethods({
    required this.addDownload,
    required this.setDownloadingKey,
    required this.downloadFile,
    required this.downloadArtworks,
    required this.saveMd5,
    required this.checkFileIntegrity,
    required this.trailing,
    required this.deleteDownloadedFile,
    required this.loadStoredQueue,
    required this.updateStoredQueue,
    required this.getTrackPath,
    required this.registerListeners,
    required this.isOffline,
    required this.getItem,
    required this.cancelDownload,
    required this.cancelDownloadCollection,
  });
}
