import 'dart:io';

import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:image_picker/image_picker.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickVideo() async {
    final XFile? pickedFile =
        await _picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      // If there's a previous controller, dispose it to remove listeners
      if (_videoPlayerController.value.isInitialized) {
        _videoPlayerController.removeListener(() {});
      }

      _videoPlayerController = VideoPlayerController.file(File(pickedFile.path))
        ..addListener(() {
          if (_videoPlayerController.value.duration ==
              _videoPlayerController.value.position) {
            _showAlert();
          }
        })
        ..initialize().then((_) {
          setState(() {
            _chewieController = ChewieController(
              videoPlayerController: _videoPlayerController,
              looping: false,
              allowFullScreen: true,
              fullScreenByDefault: false,
            );
          });
        });
    }
  }

  void _showAlert() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Video Ended!"),
              content: const Text("Hope you enjoyed it..."),
              actions: [
                TextButton(
                    onPressed: () {
                      _videoPlayerController.seekTo(Duration.zero);
                      Navigator.of(context).pop();
                    },
                    child: const Text("Ok"))
              ],
            ));
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter Video Player"),
        actions: [
          IconButton(
              onPressed: _pickVideo, icon: const Icon(Icons.video_library)),
        ],
      ),
      body: Center(
        child: _chewieController != null &&
                _chewieController!.videoPlayerController.value.isInitialized
            ? Chewie(
                controller: _chewieController!,
              )
            : const Text("Pick A Video!"),
      ),
    );
  }
}
