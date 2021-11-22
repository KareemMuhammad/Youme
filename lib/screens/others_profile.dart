import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:umee/main.dart';
import 'package:umee/models/diaries_model.dart';
import 'package:umee/models/user_model.dart';
import 'package:umee/repositories/diary_provider.dart';
import 'package:umee/repositories/user_provider.dart';
import 'package:umee/screens/profile_camera.dart';
import 'package:umee/screens/view_all_screen.dart';
import 'package:umee/utils/constants.dart';
import 'package:umee/widgets/block_sheet.dart';
import 'package:umee/widgets/large_screen_profile.dart';
import 'package:umee/widgets/profile_categories/profile_pagination.dart';
import 'package:umee/widgets/profile_categories/profile_pagination_advice.dart';
import 'package:umee/widgets/slide.dart';
import '../utils/shared.dart';

class OthersProfile extends StatefulWidget {
  final Admires admire;

  const OthersProfile({Key key, this.admire}) : super(key: key);

  @override
  _OthersProfileState createState() => _OthersProfileState();
}

class _OthersProfileState extends State<OthersProfile> {
  bool isFollowing = false;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final DiaryProvider diaryProvider = Provider.of<DiaryProvider>(context);
    if(userProvider.getOthersBool || userProvider.userOfDiary == null) {
      diaryProvider.clearUserStreams();
      userProvider.refreshUserOfDiary(widget.admire.userId);
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: bar,
        centerTitle: false,
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('${widget.admire.userName}',style: TextStyle(color: textColor,fontSize: 18),),
        ),
        actions: [
          IconButton(
              onPressed: ()async{
               await showModalBottomSheet(context: context, builder: (context){
                  return BlockSheet(diaryProvider: diaryProvider,youMeProvider: userProvider,admire: widget.admire,);
                }).then((value)  {
                if(value == 'done'){
                  Navigator.pop(context,'done');
                }
               });
            },
              icon: Icon(Icons.block)
          ),
          InkWell(
              onTap: ()async{
                if(!userProvider.followingCheck(widget.admire.userId,userProvider.getUser)) {
                 followUser(userProvider, diaryProvider);
                }else{
                  unFollowUser(userProvider, diaryProvider);
                }
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0,15,10,10),
                child: userProvider.followingCheck(widget.admire.userId,userProvider.getUser) ?
                Text('Following', style: TextStyle(color: icons,fontSize: 17,letterSpacing: 1)) :
                    isFollowing ?
                Text('Following', style: TextStyle(color: icons,fontSize: 17,letterSpacing: 1)) :
                    Text('Follow', style: TextStyle(color: textColor,fontSize: 17,letterSpacing: 1))
              )),
        ],
        leading: IconButton(
            onPressed: (){
            userProvider.setUserOfDiary();
            diaryProvider.clearUserStreams();
            userProvider.resetCategoryIndex();
            Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back,color: textColor,)
        ),
      ),
      backgroundColor: background,
      body: RefreshIndicator(
        backgroundColor: icons,
        onRefresh: () async{
          await Future.delayed(Duration(seconds: 1));
          userProvider.refreshUserOfDiary(widget.admire.userId);
        },
        child: Container(
          padding: EdgeInsets.all(10),
          child: SingleChildScrollView(
            physics: ScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget> [
                const  SizedBox(height: 10,),
                FutureBuilder<YouMeUser>(
                  future: userProvider.getUserOfDiary(widget.admire.userId),
                  builder: (BuildContext context, AsyncSnapshot<YouMeUser> snapshot){
                    return !snapshot.hasData ?
                    Center(
                        child: RefreshProgressIndicator(backgroundColor: icons,)
                    )
                    :Column( crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                            children: [
                              InkWell(
                                onTap: ()async{
                                  await showDialog(
                                      context: context, builder: (_){
                                    return new BackdropFilter(
                                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                        child: snapshot.data.image.isNotEmpty ? LargeScreenProfile(image: snapshot.data.image,)
                                            : LargeScreenProfile(image: '',)
                                    );
                                  });
                                },
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: textColor,
                                  backgroundImage: snapshot.data.image.isEmpty ? AssetImage('assets/pic.jpg')
                                      : CachedNetworkImageProvider(snapshot.data.image),
                                ),
                              ),
                              const  SizedBox(width: 10,),
                              Text(snapshot.data.name,style: TextStyle(color: textColor,fontSize: 20,letterSpacing: 1,),),
                            ]
                        ),
                        const SizedBox(height: 10,),
                        Container(
                          height: 60,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: Utils.othersCategories.length,
                              itemBuilder: (context,index){
                                return
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: RaisedButton(
                                      color: buttons,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20.0),
                                      ),
                                      elevation: 2,
                                      onPressed: (){
                                        userProvider.reloadOthersProfilePage(Utils.othersCategories[index]);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Text(Utils.othersCategories[index],style: TextStyle(letterSpacing: 1,fontSize: 16,color: textColor),),
                                      ),
                                    ),
                                  );
                              }),
                        ),
                        const SizedBox(height: 10,),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Divider(height: 3,thickness: 1,color: textColor,),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('About',style: TextStyle(color: textColor,fontSize: 18,fontWeight: FontWeight.bold),),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(snapshot.data.about,style: TextStyle(color: textColor,fontSize: 17,),),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Divider(height: 3,thickness: 1,color: textColor,),
                        ),
                        const SizedBox(height: 10,),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Stats',style: TextStyle(color: textColor,fontSize: 18,fontWeight: FontWeight.bold),),
                        ),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text('${snapshot.data.diariesNo}',style: TextStyle(color: icons,fontSize: 18),),
                                const SizedBox(height: 10,),
                                Text('Diaries',style: TextStyle(color: textColor,fontSize: 18),),
                              ],
                            ),
                            InkWell(
                              onTap: ()async{
                                if(userProvider.getUser.followersIDs.contains(widget.admire.userId)) {
                                 List<Admires> listOfFollowers = await userProvider.getUserAdmires(snapshot.data.followersIDs);
                                  Navigator.push(context, MySlide(widgetBuilder: (_) =>
                                      ViewAllScreen(title: 'Followers', userProvider: userProvider, list: listOfFollowers)));
                                }
                              },
                              child: Column(
                                children: [
                                  Text('${snapshot.data.followers.length}',style: TextStyle(color: icons,fontSize: 18),),
                                  const SizedBox(height: 10,),
                                  Text('Followers',style: TextStyle(color: textColor,fontSize: 18),),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: ()async{
                                if(userProvider.getUser.followersIDs.contains(widget.admire.userId)) {
                                  List<Admires> listOfFollowing = await userProvider.getUserAdmires(snapshot.data.followingIDs);
                                  Navigator.push(context, MySlide(widgetBuilder: (_) =>
                                      ViewAllScreen(title: 'Following', userProvider: userProvider, list: listOfFollowing)));
                                }
                              },
                              child: Column(
                                children: [
                                  Text('${snapshot.data.following.length}',style: TextStyle(color: icons,fontSize: 18),),
                                  const SizedBox(height: 10,),
                                  Text('Following',style: TextStyle(color: textColor,fontSize: 18),),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                ),

                const SizedBox(height: 10,),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Divider(height: 3,thickness: 1,color: textColor,),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        child: Text('${Utils.othersCategories[userProvider.currentIndex]}',style: TextStyle(color: textColor,fontSize: 18,fontWeight: FontWeight.bold),)
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Divider(height: 3,thickness: 1,),
                ),
                const SizedBox(height: 10,),
                userProvider.userOfDiary != null && userProvider.userOfDiary.id == widget.admire.userId? loadScreen(userProvider,diaryProvider) :
                Center(
                    child: RefreshProgressIndicator(backgroundColor: icons,)
                ),
                const SizedBox(height: 15,),
              ],
            ),
          ),
        ),
      ),
    );
  }

  openCamera(BuildContext context,String name)async{
    final firstCamera = cameras[0];
    final frontCamera = cameras[1];
    Navigator.push(context,MaterialPageRoute(builder: (_) => ProfileCamera(camera: firstCamera,frontCamera: frontCamera,name: name,)));
  }

  Widget loadScreen(UserProvider userProvider,DiaryProvider diaryProvider){
    switch(userProvider.getOthersPage.index){
      case 0:
        return UserPaginationWidget(diaryProvider: diaryProvider,userProvider: userProvider,user: userProvider.userOfDiary,others: true,);
        break;
      case 1:
        return AdvicesPaginationWidget(diaryProvider: diaryProvider,userProvider: userProvider,user: userProvider.userOfDiary,others: true,);
        break;
      case 2:
        return Container(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text('Birthday',style: TextStyle(color: textColor,fontSize: 17,fontWeight: FontWeight.bold),),
                    const SizedBox(width: 10,),
                    Text('${userProvider.userOfDiary.birthday}',style: TextStyle(color: textColor,fontSize: 16),),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text('Address',style: TextStyle(color: textColor,fontSize: 17,fontWeight: FontWeight.bold),),
                    const  SizedBox(width: 10,),
                    Text('${userProvider.userOfDiary.location}',style: TextStyle(color: textColor,fontSize: 16),),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text('Gender',style: TextStyle(color: textColor,fontSize: 17,fontWeight: FontWeight.bold),),
                    const SizedBox(width: 10,),
                    Text('${userProvider.userOfDiary.gender}',style: TextStyle(color: textColor,fontSize: 16),),
                  ],
                ),
              ),
            ],
        ),
      );
      break;
      default: return const SizedBox();
    }
  }

  void followUser(UserProvider userProvider,DiaryProvider diaryProvider)async{
    setState(() {
      isFollowing = true;
    });
    userProvider.updateFollowId(widget.admire.userId);
    userProvider.updateFollowersId(widget.admire.userId);
    userProvider.addFollower(widget.admire);
    diaryProvider.saveDiariesOfFollow(widget.admire.userId, userProvider.getUser.id);
    userProvider.refreshUser();
    String date = Utils.currentDate();
    if(widget.admire.userToken != userProvider.getUser.token) {
      await Utils.sendPushMessage(
          widget.admire.userToken,
          '${userProvider.getUser.name} started following you',
          'YOUME',
          Utils.NOTIFICATIONS_SECTION,
          userProvider.getUser.id,
          date,
          userProvider.getUser.image,
          '');
    }
  }

  void unFollowUser(UserProvider userProvider,DiaryProvider diaryProvider)async{
    setState(() {
      isFollowing = false;
    });
    userProvider.removeFollowId(widget.admire.userId);
    userProvider.removeFollowersId(widget.admire.userId);
    userProvider.removeFollower(widget.admire);
    diaryProvider.deleteDiariesOfFollow(widget.admire.userId, userProvider.getUser.id);
    userProvider.refreshUser();
  }
}
