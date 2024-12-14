import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ns/models/media_model.dart';
import 'package:video_player/video_player.dart';

class PreviewScreen extends StatefulWidget {
  final MediaItem mediaItem;

  const PreviewScreen({
    super.key,
    required this.mediaItem,
  });

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  VideoPlayerController? _videoController;
  bool _isPlaying = false;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    if (widget.mediaItem.isVideo) {
      _videoController = VideoPlayerController.file(widget.mediaItem.file)
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
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.mediaItem.isVideo ? 'Video Preview' : 'Photo Preview'),
      ),
      body: Center(
        child: widget.mediaItem.isVideo
            ? _buildVideoPreview()
            : _buildPhotoPreview(),
      ),
    );
  }

  Widget _buildVideoPreview() {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return const CircularProgressIndicator();
    }

    return Stack(
      children: [
        // Full-screen video
        Positioned.fill(
          child: AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: VideoPlayer(_videoController!),
          ),
        ),
        // Controls overlay
        Positioned(
          bottom: 40,
          left: 20,
          right: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Play/Pause Button
              IconButton(
                icon: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
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
                iconSize: 40,
                splashColor: Colors.blueAccent,
                highlightColor: Colors.blueAccent,
              ),
              // Replay Button
              IconButton(
                icon: const Icon(
                  Icons.replay,
                  color: Colors.white,
                ),
                onPressed: () {
                  _videoController!.seekTo(Duration.zero);
                  setState(() {
                    _isPlaying = false;
                  });
                },
                iconSize: 40,
                splashColor: Colors.blueAccent,
                highlightColor: Colors.blueAccent,
              ),
              // Full-Screen Toggle Button
              IconButton(
                icon: Icon(
                  _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                  color: Colors.black,
                ),
                onPressed: () {
                  setState(() {
                    _isFullScreen = !_isFullScreen;
                    if (_isFullScreen) {
                      // If entering full screen, hide the app bar and system UI
                      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
                    } else {
                      // Reset to normal UI when exiting full screen
                      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
                    }
                  });
                },
                iconSize: 40,
                splashColor: Colors.blueAccent,
                highlightColor: Colors.blueAccent,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoPreview() {
    return InteractiveViewer(
      child: Image.file(widget.mediaItem.file),
    );
  }
}
