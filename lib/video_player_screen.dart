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
  bool _alertShown = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickVideo() async {
    final XFile? pickedFile =
        await _picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _alertShown = false;
      });
      _videoPlayerController = VideoPlayerController.file(File(pickedFile.path))
        ..addListener(() {
          if (_videoPlayerController.value.duration ==
                  _videoPlayerController.value.position &&
              !_alertShown) {
            setState(() {
              _alertShown = true;
            });
            _showAlert();
          }
        })
        ..initialize().then((_) {
          setState(() {
            _chewieController = ChewieController(
              videoPlayerController: _videoPlayerController,
              autoPlay: true,
              looping: false,
              allowFullScreen: true,
              fullScreenByDefault: false,
              materialProgressColors: ChewieProgressColors(
                playedColor: Colors.deepOrange,
                handleColor: Colors.deepOrangeAccent,
                backgroundColor: Colors.grey.withOpacity(0.3),
              ),
            );
          });
        });
    }
  }

  void _showAlert() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Colors.black87,
              title: const Text(
                "Video Ended!",
                style: TextStyle(color: Colors.white),
              ),
              content: const Text(
                "Hope you enjoyed it...",
                style: TextStyle(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _videoPlayerController.seekTo(Duration.zero);
                    setState(() {
                      _alertShown = false;
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    "Ok",
                    style: TextStyle(color: Colors.orange),
                  ),
                )
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
        backgroundColor: Colors.black87,
        title: const Text(
          "Flutter Video Player",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          IconButton(
            onPressed: _pickVideo,
            icon: const Icon(
              Icons.video_library,
              color: Colors.orange,
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _chewieController?.dispose();
                _videoPlayerController.dispose();
                _chewieController = null;
              });
            },
            icon: const Icon(
              Icons.cancel,
              color: Colors.red,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: _chewieController != null &&
                _chewieController!.videoPlayerController.value.isInitialized
            ? Chewie(
                controller: _chewieController!,
              )
            : const Text(
                "Pick A Video!",
                style: TextStyle(color: Colors.orange),
              ),
      ),
    );
  }
}
