import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:umee/repositories/diary_provider.dart';
import 'package:umee/repositories/user_provider.dart';
import 'package:uuid/uuid.dart';
import '../utils/shared.dart';

class ProfileCamera extends StatefulWidget {
  final CameraDescription camera;
  final CameraDescription frontCamera;
  final String name;
  const ProfileCamera({
    Key key,
    @required this.camera, @required this.frontCamera, this.name,
  }) : super(key: key);

  @override
  ProfileCameraState createState() => ProfileCameraState();
}

class ProfileCameraState extends State<ProfileCamera> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  bool iscamerafront = true;
  bool flash = false;
  bool down = false;

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
    final userProvider = Provider.of<UserProvider>(context);
    final diaryProvider = Provider.of<DiaryProvider>(context);
    return Scaffold(
      backgroundColor: background,
      appBar:AppBar(
        centerTitle: true,
        backgroundColor: bar,
        title: Text('Take a Photo',style: TextStyle(fontSize: 19,color: textColor),),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Center(
                child:  CameraPreview(_controller)
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: down ?
        Center(child: RefreshProgressIndicator(backgroundColor: icons,))
        :Row(
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
            FloatingActionButton(
              backgroundColor: icons,
              child: Icon(Icons.camera_alt,color: textColor,size: 30,),
              onPressed: () async {
                try {
                  setState(() {
                    down = true;
                  });
                  String uuid = Uuid().v4();
                  final image = await _controller.takePicture();
                  userProvider.uploadProfileCamera(image.path, diaryProvider, uuid, widget.name);
                  Navigator.pop(context);
                } catch (e) {
                  print(e);
                  setState(() {
                    down = false;
                  });
                }
              },
            ),
            SizedBox(width: 20,),
            IconButton(icon: Icon(Icons.flip_camera_ios,color: textColor,size: 30,), onPressed: (){
              setState(() {
                iscamerafront = !iscamerafront;
              });
              final cameraPos = iscamerafront ? widget.camera : widget.frontCamera;
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