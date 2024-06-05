import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends ConsumerStatefulWidget {
  String path;

  VideoPlayerScreen(this.path, {super.key});

  @override
  // ignore: library_private_types_in_public_api
  _VideoPlayerScreenState createState() {
    return _VideoPlayerScreenState();
  }
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> {
  VideoPlayerController? _playerController;
  ChewieController? _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video'),
      ),
      body: _controller != null
          ? Chewie(controller: _controller!)
          : const Center(
             child: CircularProgressIndicator()
          ),
    );
  }

  @override
  void initState() {
    initialization();
    super.initState();
  }

  initialization() async {
    try {
      print(widget.path);
      // ignore: deprecated_member_use
      _playerController = VideoPlayerController.network(widget.path);
      await _playerController?.initialize();
      _controller = ChewieController(
          videoPlayerController: _playerController!,
          autoPlay: true,
          looping: false);
      setState(() {});
    } catch (e) {
      print("$e");
    }
  }

  @override
  void dispose() {
    _playerController?.dispose();
    _controller?.dispose();
    super.dispose();
  }
}
