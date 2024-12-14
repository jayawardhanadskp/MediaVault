import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ns/widgets/video_thumbnail.dart';

class FirebaseMediaItem extends StatelessWidget {
  final Map<String, dynamic> mediaData;
  final VoidCallback onDelete;

  const FirebaseMediaItem({
    super.key,
    required this.mediaData,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isVideo = mediaData['type'] == 'video';
    final String url = mediaData['url'];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FirebasePreviewScreen(mediaData: mediaData),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            isVideo
                ? FirebaseVideoThumbnail(url: url)
                : Image.network(
                    url,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
            Positioned(
              right: 4,
              top: 4,
              child: Row(
                children: [
                  Icon(
                    isVideo ? Icons.videocam : Icons.camera_alt,
                    color: Colors.white,
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}