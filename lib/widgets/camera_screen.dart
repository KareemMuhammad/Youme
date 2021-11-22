import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:umee/repositories/diary_provider.dart';
import 'package:umee/repositories/user_provider.dart';
import 'package:umee/utils/constants.dart';
import 'package:uuid/uuid.dart';
import '../utils/shared.dart';

class ScreenCameraPreview extends StatefulWidget {
  final String path;
  final UserProvider userProvider;
  final DiaryProvider diaryProvider;

  const ScreenCameraPreview({Key key, this.path, this.userProvider, this.diaryProvider}) : super(key: key);

  @override
  _ScreenCameraPreviewState createState() => _ScreenCameraPreviewState();
}

class _ScreenCameraPreviewState extends State<ScreenCameraPreview> {
  final formKey = GlobalKey<FormState>();

  TextEditingController textController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: bar,
        title: Text('Your Picture',style: TextStyle(fontSize: 19,color: textColor),),
      ),
      backgroundColor: background,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            widget.path == null ?
                CircularProgressIndicator(
                  backgroundColor: textColor,
                )
                :
           Container(
             padding: const EdgeInsets.all(8.0),
             child: Image.file(File(widget.path)),
           ),
          Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: ()async{
                               widget.userProvider.uploadImage(widget.path);
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
                  ),
          ],
        ),
      ),
    );
  }
}
