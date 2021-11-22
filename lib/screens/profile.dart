import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:umee/main.dart';
import 'package:umee/models/diaries_model.dart';
import 'package:umee/widgets/large_screen_profile.dart';
import 'package:umee/widgets/profile_categories/diaries_of_user.dart';
import 'package:umee/repositories/diary_provider.dart';
import 'package:umee/repositories/user_provider.dart';
import 'package:umee/screens/profile_camera.dart';
import 'package:umee/screens/view_all_screen.dart';
import 'package:umee/utils/constants.dart';
import 'package:umee/widgets/profile_categories/profile_pagination.dart';
import 'package:umee/widgets/profile_categories/profile_pagination_advice.dart';
import 'package:umee/widgets/secrets_dialog.dart';
import 'package:umee/widgets/slide.dart';
import '../utils/shared.dart';
import 'package:umee/widgets/filter_sheet.dart';

class UserProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final DiaryProvider diaryProvider = Provider.of<DiaryProvider>(context);
    print('profile');
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: bar,
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Profile',style: TextStyle(color: textColor,fontSize: 20),),
        ),
        actions: [
          IconButton(icon: Icon(Icons.edit,size: 28,color: textColor,),
              onPressed: (){
             Navigator.pushNamed(context, editProfileRoute);
          })
        ],
        leading: IconButton(
            onPressed: (){
              userProvider.resetCategoryIndex();
              diaryProvider.clearUserStreams();
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back,color: textColor,)
        ),
      ),
      backgroundColor: background,
      body: userProvider.getUser == null ?
      Center(
        child: CircularProgressIndicator(),
      ) :
      RefreshIndicator(
        backgroundColor: icons,
        onRefresh: () async{
          await Future.delayed(Duration(seconds: 1));
          userProvider.refreshUser();
          diaryProvider.clearUserStreams();
          diaryProvider.fetchNextUserDiary(userProvider.getUser);
        },
        child: Container(
          padding: EdgeInsets.all(10),
          child: SingleChildScrollView(
            physics: ScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget> [
                const SizedBox(height: 10,),
                Row(
                  children: [
                    Stack(
                      children:[
                         Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: InkWell(
                           onTap: ()async{
                            await showDialog(
                                context: context, builder: (_){
                              return new BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: userProvider.getUser.image.isNotEmpty ? LargeScreenProfile(image: userProvider.getUser.image,)
                                      : LargeScreenProfile(image: '',)
                              );
                            });
                          },
                           child: CircleAvatar(
                             radius: 50,
                             backgroundColor: textColor,
                             backgroundImage: userProvider.getUser.image.isEmpty ? AssetImage('assets/pic.jpg')
                            : CachedNetworkImageProvider(userProvider.getUser.image),
                          ),
                        ),
                      ),
                        Positioned(
                          bottom: 0,
                          child: CircleAvatar(
                            backgroundColor: icons,
                            radius: 20,
                            child: IconButton(
                                icon: Icon(Icons.camera,size: 25,color: textColor,), onPressed: ()async {
                                openCamera(context,userProvider.getUser.name);
                            }),
                          ),
                        ),
                        ]
                    ),
                    const SizedBox(width: 10,),
                    Flexible(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                         Text(userProvider.getUser.name,style: TextStyle(color: textColor,fontSize: 20,letterSpacing: 1,),),
                          SizedBox(height: 5,),
                         Text(userProvider.getUser.location ?? '',style: TextStyle(color: Colors.white70,fontSize: 15),)
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5,),
                     Container(
                       height: 60,
                       child: ListView.builder(
                           scrollDirection: Axis.horizontal,
                             itemCount: Utils.categories.length,
                             itemBuilder: (context,index){
                               return Padding(
                                 padding: const EdgeInsets.all(8.0),
                                 child: RaisedButton(
                                   color: buttons,
                                   shape: RoundedRectangleBorder(
                                     borderRadius: BorderRadius.circular(20.0),
                                   ),
                                   elevation: 2,
                                   onPressed: () async{
                                     if(index == 2 || index == 3){
                                       dynamic result = await showDialog(context: context, builder: (_){
                                         return new BackdropFilter(
                                             filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                             child: Dialog(
                                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                                               backgroundColor: buttons,
                                               child: SecretsDialog(user: userProvider.getUser,),
                                             )
                                         );
                                       });
                                       if(result == 'done'){
                                         userProvider.reloadProfilePage(Utils.categories[index]);
                                       }
                                     }else{
                                       userProvider.reloadProfilePage(Utils.categories[index]);
                                     }
                                   },
                                   child: Padding(
                                     padding: const EdgeInsets.all(5.0),
                                     child: Text(Utils.categories[index],
                                       style: TextStyle(letterSpacing: 1,fontSize: 16,color: textColor),),
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
                  child: Text(userProvider.getUser.about,style: TextStyle(color: textColor,fontSize: 17,),),
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
                    InkWell(
                      onTap: (){
                        diaryProvider.fetchNextUserDiary(userProvider.getUser);
                      },
                      child: Column(
                        children: [
                          Text('${userProvider.getUser.diariesNo}',style: TextStyle(color: icons,fontSize: 18),),
                          const SizedBox(height: 10,),
                          Text('Diaries',style: TextStyle(color: textColor,fontSize: 18),),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: (){
                        Navigator.push(context, MySlide(widgetBuilder: (_) =>
                            ViewAllScreen(title: 'Followers',userProvider: userProvider,list: userProvider.getUser.followers)));
                      },
                      child: Column(
                        children: [
                          Text('${userProvider.getUser.followers.length}',style: TextStyle(color: icons,fontSize: 18),),
                          const SizedBox(height: 10,),
                          Text('Followers',style: TextStyle(color: textColor,fontSize: 18),),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: (){
                        Navigator.push(context, MySlide(widgetBuilder: (_) =>
                            ViewAllScreen(title: 'Following',userProvider: userProvider,list: userProvider.getUser.following,)));
                      },
                      child: Column(
                        children: [
                          Text('${userProvider.getUser.following.length}',style: TextStyle(color: icons,fontSize: 18),),
                          const SizedBox(height: 10,),
                          Text('Following',style: TextStyle(color: textColor,fontSize: 18),),
                        ],
                      ),
                    ),
                  ],
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
                        child: Text('${Utils.categories[userProvider.currentIndex]}',
                          style: TextStyle(color: textColor,fontSize: 18,fontWeight: FontWeight.bold),)
                    ),
                    RaisedButton(
                      color: icons,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      elevation: 0,
                      onPressed: () async{
                       await showModalBottomSheet(context: context, builder:(context){
                        return FilterBottomSheet(diaryProvider: diaryProvider,userProvider: userProvider,userId: userProvider.getUser.id,);
                       });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.filter_alt_outlined,color: textColor,size: 28,),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Divider(height: 3,thickness: 1,),
                ),
                const SizedBox(height: 10,),
                loadScreen(userProvider,diaryProvider,context),
                const SizedBox(height: 15,),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: float,
          elevation: 4,
          onPressed: () {
            Navigator.pushNamed(context, writeRoute);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset('assets/think_pencil.png',),
          )
      ),
    );
  }

  openCamera(BuildContext context,String name)async{
    final firstCamera = cameras[0];
    final frontCamera = cameras[1];
    Navigator.push(context,MaterialPageRoute(builder: (_) => ProfileCamera(camera: firstCamera,frontCamera: frontCamera,name: name,)));
  }

 Widget loadScreen(UserProvider userProvider,DiaryProvider diaryProvider,BuildContext context){
    switch(userProvider.page.index){
     case 0:
        return UserPaginationWidget(diaryProvider: diaryProvider,userProvider: userProvider,user: userProvider.getUser,);
        break;
      case 1:
        return AdvicesPaginationWidget(diaryProvider: diaryProvider,userProvider: userProvider,user: userProvider.getUser,);
        break;
      case 2:
        return FutureBuilder<List<Diaries>>(
          future: diaryProvider.fetchSecretsOfUser(userProvider.getUser.id),
          builder: (BuildContext context, AsyncSnapshot<List<Diaries>> snapshot) {
            return snapshot.data != null && snapshot.data.isNotEmpty ? ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: snapshot.data.length ?? 0,
                itemBuilder: (context,index){
                  return ProfileDiariesWidget(diary: snapshot.data[index],diaryProvider: diaryProvider,userProvider: userProvider,);
                }) : Center(child: Text('you have no secrets yet',style: TextStyle(color: textColor,fontSize: 18),),);
          },
        );
        break;
      case 3:
        return FutureBuilder<List<Diaries>>(
          future: diaryProvider.fetchWillOfUser(userProvider.getUser.id),
          builder: (BuildContext context, AsyncSnapshot<List<Diaries>> snapshot) {
            return snapshot.data != null && snapshot.data.isNotEmpty ? ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: snapshot.data.length ?? 0,
                itemBuilder: (context,index){
                  return ProfileDiariesWidget(diary: snapshot.data[index],diaryProvider: diaryProvider,userProvider: userProvider,);
                }) : Center(child: Text('you have no will yet',style: TextStyle(color: textColor,fontSize: 18),),);
          },
        );
        break;
      default: return Container();
    }
  }

}
