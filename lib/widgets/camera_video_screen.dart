import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:umee/repositories/diary_provider.dart';
import 'package:umee/repositories/user_provider.dart';
import 'package:umee/utils/constants.dart';
import 'package:uuid/uuid.dart';
import '../utils/shared.dart';
import 'package:video_player/video_player.dart';

class CameraVideoUme extends StatefulWidget {
  final String path;
  final UserProvider userProvider;
  final DiaryProvider diaryProvider;

  const CameraVideoUme({Key key, this.path, this.userProvider, this.diaryProvider}) : super(key: key);
  @override
  _CameraVideoUmeState createState() => _CameraVideoUmeState();
}

class _CameraVideoUmeState extends State<CameraVideoUme> {
  VideoPlayerController _controller;
  final formKey = GlobalKey<FormState>();
  TextEditingController textController = new TextEditingController();
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.path))
      ..initialize().then((_) {
        setState(() {});
      });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: bar,
        title: Text('Your Video',style: TextStyle(fontSize: 19,color: textColor),),
    ),
      body: Column(
        children: [
          Stack(
                children: [
                  Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(8),
                      child: _controller.value.isInitialized ? AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller)
                      )
                          : Container()
                  ),
                  Positioned.fill(
                      child: Align(
                        alignment: Alignment.center,
                        child: InkWell(
                          onTap: (){
                            setState(() {
                              _controller.value.isPlaying? _controller.pause()
                                  :_controller.play();
                            });
                          },
                          child: CircleAvatar(
                            backgroundColor: icons,
                            radius: 30,
                            child: _controller.value.isPlaying?
                            Icon(Icons.pause,size: 40,color: textColor,)
                            :Icon(Icons.play_arrow,size: 40,color: textColor,),
                        ),),
                      )
                  ),
                ],
              ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: ()async{
                  widget.userProvider.uploadVideo(widget.path);
                  widget.userProvider.reloadPostChoice(Utils.OTHERS);
                  Navigator.pop(context);
                },
                child: CircleAvatar(
                  backgroundColor: icons,
                  radius: 25,
                  child: Icon(Icons.check,size: 28,color: textColor,),
                ),),
              SizedBox(width: 15,),
              InkWell(
                onTap: (){
                  Navigator.pop(context);
                },
                child: CircleAvatar(
                  backgroundColor: icons,
                  radius: 25,
                  child: Icon(Icons.clear,size: 28,color: textColor,),
                ),),
            ],
          ),
        ],
      ),
    );
  }
}
