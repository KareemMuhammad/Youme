import 'package:chewie/chewie.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:umee/repositories/user_provider.dart';
import 'package:umee/utils/constants.dart';
import 'package:umee/utils/shared.dart';
import 'package:video_player/video_player.dart';

class PostVideoWidget extends StatefulWidget {
  final String url;
  final UserProvider userProvider;

  const PostVideoWidget({Key key, this.url, this.userProvider}) : super(key: key);
  @override
  _PostVideoWidgetState createState() => _PostVideoWidgetState();
}

class _PostVideoWidgetState extends State<PostVideoWidget> {
  VideoPlayerController _controller;
  ChewieController chewieController;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
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
    return Stack(
      children: [
        Container(
            padding: const EdgeInsets.fromLTRB(0,0,0,10),
            alignment: Alignment.center,
            child: _controller.value.isInitialized ? AspectRatio(
                aspectRatio:  _controller.value.aspectRatio ,
                child: Chewie(controller: chewieController)
            )
                : Container(
              height: 300,
              width: MediaQuery.of(context).size.width,
              color: black,
            )
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.topRight,
            child: InkWell(
              onTap: ()async{
                await FirebaseStorage.instance.refFromURL(widget.url).delete();
                widget.userProvider.setVideoPath('');
                widget.userProvider.reloadPostChoice(Utils.WORDS);
              },
              child: CircleAvatar(
                  backgroundColor: icons,
                  radius: 20,
                  child: Icon(Icons.close,size: 25,color: textColor,)
              ),),
          ),
        ),
      ],
    );
  }
}
