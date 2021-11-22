import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:umee/utils/shared.dart';
import 'package:video_player/video_player.dart';

class DiaryVideoWidget extends StatefulWidget {
  final String url;
  final bool ratio;

  const DiaryVideoWidget({Key key, this.url, this.ratio = false}) : super(key: key);
  @override
  _DiaryVideoWidgetState createState() => _DiaryVideoWidgetState();
}

class _DiaryVideoWidgetState extends State<DiaryVideoWidget> {
  VideoPlayerController _controller;
  ChewieController chewieController;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url)..initialize().then((_) {
      setState(() {});
    });

    chewieController = ChewieController(
      showControls: true,
      videoPlayerController: _controller,
      aspectRatio: _controller.value.aspectRatio,
      allowFullScreen: true,
      deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    chewieController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
            padding: const EdgeInsets.fromLTRB(0,0,0,10),
          alignment: Alignment.center,
            child: _controller.value.isInitialized ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: Chewie(controller: chewieController)
        )
            : Container(
                height: 300,
                width: MediaQuery.of(context).size.width,
                color: black,
            )
        ),
      ],
    );
  }
}
