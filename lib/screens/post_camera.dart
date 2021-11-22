import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:umee/repositories/diary_provider.dart';
import 'package:umee/repositories/user_provider.dart';
import 'package:umee/widgets/camera_screen.dart';
import 'package:umee/widgets/camera_video_screen.dart';
import '../utils/shared.dart';

enum CapVid{CAPTURE,VIDEO}
class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;
  final CameraDescription frontCamera;
  final UserProvider userProvider;
  final DiaryProvider diaryProvider;

  const TakePictureScreen({
    Key key,
    @required this.camera, @required this.frontCamera, this.userProvider, this.diaryProvider,
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  bool isRecording = false;
  bool flash = false;
  bool isCameraFront = true;
  final List<String> rowList = ['Capture','Video'];
  CapVid _capVid = CapVid.CAPTURE;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: bar,
        title: Text('Camera/Video',style: TextStyle(fontSize: 19,color: textColor),),
        actions: [
          IconButton(
              icon: Icon(flash ? Icons.flash_on : Icons.flash_off,),
              iconSize: 28,
              color: textColor
              , onPressed: ()async{
                setState(() {
                  flash = !flash;
                });
                flash ? _controller.setFlashMode(FlashMode.torch)
                    : _controller.setFlashMode(FlashMode.off);
              }),
          IconButton(
              icon: Icon(Icons.flip_camera_ios,),
              iconSize: 28,
              color: textColor
              , onPressed: (){
            setState(() {
              isCameraFront = !isCameraFront;
            });
            final cameraPos = isCameraFront ? widget.camera : widget.frontCamera;
            _controller = CameraController(
                cameraPos, ResolutionPreset.high);
            _initializeControllerFuture = _controller.initialize();
          })
        ],
      ),
      body: Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: [
           Positioned.fill(
             child: FutureBuilder<void>(
                future: _initializeControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return CameraPreview(_controller);

                  } else {
                    return Center(child: CircularProgressIndicator(backgroundColor: black,));
                  }
                },
              ),
           ),
         _capVid == CapVid.CAPTURE ?
       Positioned(
           bottom: 0,
           child: captureIcons()
       )
          :
         Positioned(
           bottom: 0,
             child:  videoIcons()
         ),
        ],
      ),
      bottomNavigationBar: Row( mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: RaisedButton(
              color: buttons,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              elevation: 2,
              onPressed: () {
                setState(() {
                  _capVid = CapVid.CAPTURE;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(rowList[0],
                  style: TextStyle(letterSpacing: 1,fontSize: 16,color: textColor),),
              ),
            ),
          ),
          SizedBox(width: 10,),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: RaisedButton(
              color: buttons,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              elevation: 2,
              onPressed: () {
                setState(() {
                  _capVid = CapVid.VIDEO;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(rowList[1],
                  style: TextStyle(letterSpacing: 1,fontSize: 16,color: textColor),),
              ),
            ),
          ),
        ],
      )
    );
  }

  Widget videoIcons(){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: IconButton(
                onPressed: ()async{
                  if(!isRecording){
                    try {
                      await _controller.startVideoRecording();
                    } on CameraException catch (e) {
                      print(e);
                      return null;
                    }
                    setState(() {
                      isRecording = true;
                    });
                  }else{
                    try {
                      XFile video = await _controller.stopVideoRecording();
                      setState(() {
                        isRecording = false;
                      });
                      print(video.path);
                      Navigator.pushReplacement(context,MaterialPageRoute(builder: (_) =>
                          CameraVideoUme(path: video.path,userProvider: widget.userProvider,diaryProvider: widget.diaryProvider,)));
                    } on CameraException catch (e) {
                      print(e);
                      return null;
                    }
                  }
                },
                icon: isRecording ? Icon(Icons.stop_circle_outlined,color: red,size: 50,)
                    : Icon(Icons.radio_button_on,color: textColor,size: 50,)
            ),
      ),
    );
  }

  Widget captureIcons(){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: IconButton(
                onPressed: ()async{
                  if(!isRecording){
                    try {
                      await _initializeControllerFuture;
                      final image = await _controller.takePicture();
                      Navigator.pushReplacement(context,MaterialPageRoute(builder: (_) =>
                          ScreenCameraPreview(path: image.path,userProvider: widget.userProvider,diaryProvider: widget.diaryProvider,)));
                    } catch (e) {
                      print(e);
                    }
                  }
                },
                icon: Icon(Icons.panorama_fish_eye,color: textColor,size: 50,)
            ),
      ),
    );
  }
}
