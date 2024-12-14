import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FirebaseVideoThumbnail extends StatefulWidget {
  final String url;

  const FirebaseVideoThumbnail({
    Key? key,
    required this.url,
  }) : super(key: key);

  @override
  State<FirebaseVideoThumbnail> createState() => _FirebaseVideoThumbnailState();
}

class _FirebaseVideoThumbnailState extends State<FirebaseVideoThumbnail> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isInitialized
        ? VideoPlayer(_controller)
        : const Center(child: CircularProgressIndicator());
  }
}

class FirebasePreviewScreen extends StatefulWidget {
  final Map<String, dynamic> mediaData;

  const FirebasePreviewScreen({
    Key? key,
    required this.mediaData,
  }) : super(key: key);

  @override
  State<FirebasePreviewScreen> createState() => _FirebasePreviewScreenState();
}

class _FirebasePreviewScreenState extends State<FirebasePreviewScreen> {
  VideoPlayerController? _videoController;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    if (widget.mediaData['type'] == 'video') {
      _videoController = VideoPlayerController.network(widget.mediaData['url'])
        ..initialize().then((_) {
          setState(() {});
        });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isVideo = widget.mediaData['type'] == 'video';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isVideo ? 'Video Preview' : 'Photo Preview'),
      ),
      body: Center(
        child: isVideo ? _buildVideoPreview() : _buildPhotoPreview(),
      ),
    );
  }

  Widget _buildVideoPreview() {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return const CircularProgressIndicator();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: VideoPlayer(_videoController!),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow,),
              onPressed: () {
                setState(() {
                  if (_isPlaying) {
                    _videoController!.pause();
                  } else {
                    _videoController!.play();
                  }
                  _isPlaying = !_isPlaying;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.replay),
              onPressed: () {
                _videoController!.seekTo(Duration.zero);
                setState(() {
                  _isPlaying = false;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhotoPreview() {
    return InteractiveViewer(
      child: Image.network(widget.mediaData['url']),
    );
  }
}