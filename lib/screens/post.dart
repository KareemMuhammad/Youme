import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:umee/main.dart';
import 'package:umee/models/diaries_model.dart';
import 'package:umee/repositories/diary_provider.dart';
import 'package:umee/repositories/user_provider.dart';
import 'package:umee/screens/add_image_camera.dart';
import 'package:umee/screens/diary_options.dart';
import 'package:umee/screens/post_camera.dart';
import 'package:umee/screens/recording.dart';
import 'package:umee/screens/who_search.dart';
import 'package:umee/utils/constants.dart';
import 'package:umee/widgets/image_post_widget.dart';
import 'package:umee/widgets/post_record_widget.dart';
import 'package:umee/widgets/post_video_widget.dart';
import 'package:umee/widgets/slide.dart';
import 'package:uuid/uuid.dart';
import '../utils/shared.dart';
import 'package:umee/widgets/widgets.dart';

class PostNewMemory extends StatefulWidget {
  @override
  _PostNewMemoryState createState() => _PostNewMemoryState();
}

class _PostNewMemoryState extends State<PostNewMemory> {
  final formKey = GlobalKey<FormState>();

  final TextEditingController textController = new TextEditingController();

  final firstCamera = cameras[0];

  final frontCamera = cameras[1];

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final DiaryProvider diaryProvider = Provider.of<DiaryProvider>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: background,
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: bar,
        title: Text('Create a Diary',style: TextStyle(fontSize: 19,color: textColor),),
        leading: IconButton(
            onPressed: (){
              Navigator.pop(context);
              userProvider.setPostCategory('');
              userProvider.setWillCategory('');
              userProvider.person.clear();
              userProvider.registers.clear();
              userProvider.participate.clear();
            },
            icon: Icon(Icons.arrow_back,color: textColor,size: 30,)),
        actions: [
        userProvider.currentPostIndex == 0 ?
          IconButton(
              onPressed: (){
                Navigator.push(context, MySlide(widgetBuilder: (_) =>
                    RecordMemory(userProvider: userProvider,diaryProvider: diaryProvider,)));
              },
              icon: Icon(Icons.mic,color: textColor,size: 30,)) : SizedBox(),
          userProvider.currentPostIndex == 0 ?
          IconButton(
              onPressed: (){
                Navigator.push(context,MySlide(widgetBuilder: (_) =>
                    TakePictureScreen(camera: firstCamera,frontCamera: frontCamera,userProvider: userProvider,diaryProvider: diaryProvider,)));
              },
              icon: Icon(Icons.camera,color: textColor,size: 28,)) : SizedBox(),
          IconButton(
              onPressed: ()async{
                Navigator.push(context, MaterialPageRoute(builder: (_) => DiaryOptions(userProvider: userProvider,)));
              },
              icon: Icon(Icons.settings,color: textColor,size: 28,)),
        ],
      ),
      body: SingleChildScrollView(
        reverse: true,
        physics: ScrollPhysics(),
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.topLeft,
                      padding: EdgeInsets.all(8),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.add_circle_outline,color: textColor,size: 25,),
                            onPressed: ()async{
                              await showSearch(context: context, delegate: WhoSearch(tag: true,userProvider: userProvider,list: userProvider.getUser.followers));
                            },
                          ),
                          Text('Tag People',style: TextStyle(
                              fontSize: 16,
                              color: textColor
                          ),),
                        ],
                      ),
                    ),
                    userProvider.person.isNotEmpty ?
                    Container(
                      height: 70,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: userProvider.person.length,
                          itemBuilder: (context,index){
                            return Row(
                                children:[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('${userProvider.person[index].userName}',style: TextStyle(fontSize: 16,color: textColor),),
                                  ),
                                  InkWell(
                                    onTap: (){
                                      userProvider.clearPerson(index);
                                      userProvider.clearParticipate(index);
                                      userProvider.clearRegisters(index);
                                    },
                                    child: CircleAvatar(
                                        backgroundColor: icons,
                                        radius: 10,
                                        child: Icon(Icons.close,size: 15,color: textColor,)
                                    ),),
                                ]
                            );
                          }),
                    )
                        : const SizedBox(),
                    const SizedBox(height: 20,),
                    ClipRect(
                        child: Form(
                          child: TextFormField(
                            textAlign: Utils.isDirectionRTL(context) ? TextAlign.end : TextAlign.start,
                            style: textStyle(),
                            autofocus: false,
                            maxLength: 100,
                            maxLines: 5,
                            decoration: textInputDecoration('What\'s happening to you now?'),
                            controller: textController,
                            validator: (val) {
                              return val.isEmpty ? 'diary can\'t be empty ': null;
                            },
                          ),
                          key: formKey,
                        ),
                    ),
                   userProvider.isLoading ? Center(child: RefreshProgressIndicator(backgroundColor: icons,)
                    ) : const SizedBox(),
                    const SizedBox(height: 15,),
                    userProvider.getVideoPath.isEmpty ? const SizedBox() :
                    Card(
                        color: buttons,
                        elevation: 2,
                        child: PostVideoWidget(userProvider: userProvider,url: userProvider.getVideoPath,)
                    ),
                    userProvider.getImagePath.isEmpty ? const SizedBox() :
                     ImagePostWidget(userProvider: userProvider,),
                    userProvider.getImagePath.isEmpty ?
                    const SizedBox()
                    : InkWell(
                          onTap: (){
                            Navigator.push(context,MySlide(widgetBuilder: (_) =>
                                AddImageCamera(camera: firstCamera,frontCamera: frontCamera,
                                  userProvider: userProvider,diaryProvider: diaryProvider,)));
                          },
                          child: CircleAvatar(
                              backgroundColor: icons,
                              radius: 20,
                              child: Icon(Icons.add,size: 25,color: textColor,)
                          ),),
                    userProvider.getRecordPath.isEmpty ? Container() :
                    Stack(
                        children:[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: PostRecordWidget(path: userProvider.getRecordPath,),
                          ),
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.topRight,
                              child: InkWell(
                                onTap: ()async{
                                  await FirebaseStorage.instance.refFromURL(userProvider.getRecordPath).delete();
                                  userProvider.setRecordPath('');
                                  userProvider.reloadPostChoice(Utils.WORDS);
                                },
                                child: CircleAvatar(
                                    backgroundColor: icons,
                                    radius: 20,
                                    child: Icon(Icons.close,size: 28,color: textColor,)
                                ),),
                            ),
                          ),
                        ]
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(100,40,100,20),
                      child: Container(
                        decoration: BoxDecoration(
                            color: icons,
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: MaterialButton(
                          onPressed: () async{
                            if(formKey.currentState.validate()){
                              if (await Permission.location.request().isGranted) {
                                if(userProvider.getCategoryPath.isEmpty){
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => DiaryOptions(userProvider: userProvider,)));
                                } else {
                                  if (userProvider.getWillCategoryPath == Utils.WILL && userProvider.person.isEmpty) {
                                  Utils.showToast('You forgot to tag who can see your will');
                                  }else{
                                    if(!userProvider.isLoading) {
                                      uploadPost(userProvider, diaryProvider);
                                      Navigator.pop(context);
                                    }
                                  }
                                }
                              }
                            }
                          },
                          child: Row(mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.send_sharp,color: textColor,),
                              const SizedBox(width: 8,),
                             userProvider.isLoading ? Text('Loading..',style: TextStyle(fontSize: 18,color: textColor),)
                                 :Text('Memorize',style: TextStyle(fontSize: 18,color: textColor),),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom)),
                  ],
                ),
              ),
    );
  }

  void uploadPost(UserProvider userProvider,DiaryProvider diaryProvider)async{
    userProvider.refreshLoading();
    DateTime currentPhoneDate = DateTime.now();
    String dateFormat = DateFormat('yyyy-MM-dd').format(currentPhoneDate);
    String uuid = Uuid().v4();
    String location = await Utils.getCurrentLocation();
    String date = Utils.currentDate();
    Diaries diary = Diaries.post(
      id: uuid,
      userId: userProvider.getUser.id,
      date: '$date',
      location: location ?? '',
      content: textController.text,
      userImage: userProvider.getUser.image,
      userName: userProvider.getUser.name,
      category: userProvider.getCategoryPath ?? 'Public',
      images: userProvider.getImagePath ?? [],
      videoUrl: userProvider.getVideoPath ?? '',
      recordUrl: userProvider.getRecordPath ?? '',
      filterDate: '$dateFormat',
      taggedPeople: userProvider.person,
      willCategory: userProvider.getWillCategoryPath ?? '',
      diaryLikerList: [],
      advices: []
    );
    diaryProvider.addNewDiary(diary, uuid);
    userProvider.updateUserDiaryNumber();
    if(diary.category == Utils.PUBLIC || diary.category == Utils.FOLLOWERS){
      diaryProvider.postDiaryToFollowers(userProvider.getUser, diary);
    }
    userProvider.refreshLoading();
    if (userProvider.person.isNotEmpty && userProvider.getCategoryPath != Utils.WILL) {
      await Utils.sendPostPushMessage('${userProvider.getUser.name} tagged you in a diary',
          'YOUME',
          Utils.POST_TAGS_SECTION,
          userProvider.registers,
          '$date',
          userProvider.getUser.image,
          uuid,
          userProvider.getUser.id);
      userProvider.person.clear();
      userProvider.registers.clear();
    }
    userProvider.getImagePath.clear();
    userProvider.setVideoPath('');
    userProvider.setPostCategory('');
    userProvider.reloadPostChoice(Utils.WORDS);
  }

  @override
  void dispose() {
    super.dispose();
    textController.dispose();
  }
}


