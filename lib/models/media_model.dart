import 'dart:io';

class MediaItem {
  final File file;
  final bool isVideo;
  final DateTime dateTime;

  MediaItem({
    required this.file,
    required this.isVideo,
    required this.dateTime,
  });
}