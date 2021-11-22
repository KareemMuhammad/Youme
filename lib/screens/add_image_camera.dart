
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:umee/repositories/diary_provider.dart';
import 'package:umee/repositories/user_provider.dart';
import 'package:umee/utils/shared.dart';
import 'package:umee/widgets/camera_screen.dart';

class AddImageCamera extends StatefulWidget {
  final CameraDescription camera;
  final CameraDescription frontCamera;
  final UserProvider userProvider;
  final DiaryProvider diaryProvider;

  const AddImageCamera({Key key, this.camera, this.frontCamera, this.userProvider, this.diaryProvider}) : super(key: key);
  @override
  _AddImageCameraState createState() => _AddImageCameraState();
}

class _AddImageCameraState extends State<AddImageCamera> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  bool isRecording = false;
  bool flash = false;
  bool isCameraFront = true;

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
        centerTitle: true,
        backgroundColor: bar,
        title: Text('Capture Photo',style: TextStyle(fontSize: 19,color: textColor),),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Center(
                child:  CameraPreview(_controller)
            );
          } else {
            return Center(child: CircularProgressIndicator(backgroundColor: black,));
          }
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(icon: Icon(flash ? Icons.flash_on : Icons.flash_off,),
                iconSize: 30,
                color: textColor
                , onPressed: ()async{
                  setState(() {
                    flash = !flash;
                  });
                  flash
                      ? _controller
                      .setFlashMode(FlashMode.torch)
                      : _controller.setFlashMode(FlashMode.off);
                }),
            SizedBox(width: 20,),
            GestureDetector(
                onTap: ()async{
                    try {
                      await _initializeControllerFuture;
                      final image = await _controller.takePicture();
                      Navigator.pushReplacement(context,MaterialPageRoute(builder: (_) =>
                          ScreenCameraPreview(path: image.path,userProvider: widget.userProvider,diaryProvider: widget.diaryProvider,)));
                    } catch (e) {
                      print(e);
                    }
                },
                child: Icon(Icons.panorama_fish_eye,color: textColor,size: 50,)
            ),
            SizedBox(width: 20,),
            IconButton(icon: Icon(Icons.flip_camera_ios,color: textColor,size: 30,), onPressed: (){
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
      ),
    );
  }
}
