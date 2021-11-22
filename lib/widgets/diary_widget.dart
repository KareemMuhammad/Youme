import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:umee/models/diaries_model.dart';
import 'package:umee/models/user_model.dart';
import 'package:umee/repositories/diary_provider.dart';
import 'package:umee/repositories/user_provider.dart';
import 'package:umee/screens/others_profile.dart';
import 'package:umee/screens/post_advices_screen.dart';
import 'package:umee/screens/view_all_advices.dart';
import 'package:umee/screens/view_all_screen.dart';
import 'package:umee/utils/constants.dart';
import 'package:umee/utils/shared.dart';
import 'package:umee/widgets/diary_video_widget.dart';
import 'package:umee/widgets/large_screen_image.dart';
import 'package:umee/widgets/like_widget.dart';
import 'package:umee/widgets/more_sheet.dart';
import 'package:umee/widgets/post_record_widget.dart';
import 'package:umee/widgets/profile_more_sheet.dart';
import 'package:umee/widgets/slide.dart';

class DiaryWidget extends StatelessWidget {
  final Diaries diary;
  final UserProvider youMeProvider;
  final DiaryProvider diaryProvider;

  const DiaryWidget({Key key, this.diary, this.youMeProvider, this.diaryProvider}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: diaryProvider.isHiddenDiary(diary, youMeProvider.getUser) ?
      Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('This diary has been hidden',style: TextStyle(color: textColor,fontSize: 16,letterSpacing: 1,),),
          const  SizedBox(height: 10,),
          IconButton(onPressed: (){
            youMeProvider.cancelUserFeedHiddenDiaries(diary.id, youMeProvider.getUser.id);
          },
              icon: Icon(Icons.redo),
            iconSize: 40,
            color: textColor,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Divider(color: textColor,),
          ),
        ],
        ),
      ):
      Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(8),
            onTap: ()async{
              youMeProvider.setOthersBool(true);
              YouMeUser user = await youMeProvider.getUserOfDiary(diary.userId);
              Admires admire = Admires.add(userId: diary.userId,userImage: diary.userImage,userName: diary.userName,userToken: user.token);
              if(admire.userId == youMeProvider.getUser.id){
                diaryProvider.clearUserStreams();
                Navigator.pushNamed(context, profileRoute);
              }else{
                Navigator.push(context, MySlide(widgetBuilder: (_) => OthersProfile(admire: admire,)));
              }
            },
            leading: CircleAvatar(
              radius: 25,
              backgroundColor: textColor,
              backgroundImage: diary.userImage.isEmpty || diary.userImage == null ? ResizeImage(AssetImage('assets/pic.jpg'),width: 60,height: 56)
                  : CachedNetworkImageProvider('${diary.userImage}'),
            ),
            title: Text('${diary.userName}',style: TextStyle(color: textColor,fontSize: 17,letterSpacing: 1,),),
            subtitle: Text('${diaryProvider.getDiaryTime(diary.date)}',style: TextStyle(color: textColor,fontSize: 13),),
            trailing: IconButton(
                icon: Icon(Icons.more_horiz,color: textColor,size: 25,),
                onPressed: (){
                  showModalBottomSheet(context: context, builder: (context){
                    return diary.userId == youMeProvider.getUser.id ?
                    ProfileCustomSheet(diaryProvider: diaryProvider,youMeProvider: youMeProvider,diary: diary,)
                    : CustomSheet(diary: diary,diaryProvider: diaryProvider,userProvider: youMeProvider,);
                  });
                }),
          ),
                      diary.taggedPeople.isNotEmpty ?
                       SizedBox(
                         height: 40,
                         child: ListView.builder(
                             scrollDirection: Axis.horizontal,
                             itemCount: diary.taggedPeople.length ?? 0,
                             itemBuilder: (_,index){
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: ()async{
                                  youMeProvider.setOthersBool(true);
                                  YouMeUser user = await youMeProvider.getUserOfDiary(diary.taggedPeople[index].userId);
                                  Admires admire = Admires.add(userId: diary.taggedPeople[index].userId,
                                      userImage: diary.taggedPeople[index].userImage,userName: diary.taggedPeople[index].userName,userToken: user.token);
                                  if(admire.userId == youMeProvider.getUser.id){
                                    diaryProvider.clearUserStreams();
                                    Navigator.pushNamed(context, profileRoute);
                                  }else{
                                    Navigator.push(context, MySlide(widgetBuilder: (_) => OthersProfile(admire: admire,)));
                                  }
                                },
                                child: Text('${diary.taggedPeople[index].userName}',
                                  style: TextStyle(color: icons,fontSize: 16,letterSpacing: 1,fontWeight: FontWeight.bold),),
                              ),
                            );
                         }),
                       )
                          : const SizedBox(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 8),
                        child: Row(mainAxisAlignment: RegExp(Utils.REGEX_PATTERN).hasMatch(diary.content)? MainAxisAlignment.end : MainAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Text('${diary.content}',
                                style: TextStyle(color: textColor,fontSize: 17,letterSpacing: 1,),
                                textAlign: RegExp(Utils.REGEX_PATTERN).hasMatch(diary.content)? TextAlign.end : TextAlign.start,),
                            ),
                          ],
                        ),
                      ),

                    diary.images.isNotEmpty ?
                    Container(
                      height: MediaQuery.of(context).size.height - SizeConfig.screenHeight * 0.6,
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.fromLTRB(0,0,0,10),
                      child: Swiper(
                        loop: false,
                        itemCount: diary.images.length,
                        pagination: new SwiperPagination(
                          alignment: Alignment.bottomCenter,
                          builder: new DotSwiperPaginationBuilder(color: textColor, activeColor: icons),
                        ),
                        itemBuilder: (BuildContext context,int index){
                          return InkWell(
                            onTap: ()async{
                              await showDialog(
                                  context: context, builder: (_){
                                return new BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                    child:  LargeScreenImage(image: diary.images[index],)
                                );
                              });
                            },
                            child: CachedNetworkImage(
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                    decoration: BoxDecoration(
                                    image: DecorationImage(
                                      fit: BoxFit.fitWidth,
                                      image: imageProvider,
                                  ),
                                ),
                              ),
                              width: double.maxFinite,
                              height: double.maxFinite,
                              imageUrl: diary.images[index],
                              progressIndicatorBuilder: (context, url, downloadProgress) =>
                                  Image.asset('assets/image-not-found.png'),
                              errorWidget: (context, url, error) => Icon(Icons.error),
                            ),
                          );
                        },
                      ),
                    )
                        : const SizedBox(),
                    diary.videoUrl.isNotEmpty ?
                    DiaryVideoWidget(url: diary.videoUrl,)
                        : const SizedBox(),
                    diary.recordUrl.isNotEmpty ?
                    PostRecordWidget(path: diary.recordUrl,)
                        : const SizedBox(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 8),
            child: Row(mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.location_on,size: 20,color: textColor,),
                const SizedBox(width: 5,),
                Flexible(child: Text('${diary.location}',style: TextStyle(color: textColor),))
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Row(mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    RaisedButton(
                      color: icons,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      onPressed: () {
                         diaryProvider.refreshSingleDiary(diary.id);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => PostAdvicesScreen(diary: diary,)));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: Text('Advice',style: TextStyle(letterSpacing: 1,fontSize: 17,color: textColor),),
                      ),
                    ),
                    const SizedBox(width: 5,),
                   InkWell(
                       onTap: (){
                         Navigator.push(context, MySlide(widgetBuilder: (_) =>
                             ViewAllAdvices(title: 'Advices by',userProvider: youMeProvider,list: diary.advices,)));
                       },
                       child: Text('${diary.advices.length}',style: TextStyle(fontSize: 18,color: textColor),)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 45),
                child: Row(mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    LikeDiary(youMeProvider: youMeProvider,diary: diary,diaryProvider: diaryProvider,likesCount: diary.diaryLikerList.length,),
                    const SizedBox(width: 5,),
                    InkWell(
                        onTap: (){
                          Navigator.push(context, MySlide(widgetBuilder: (_) =>
                              ViewAllScreen(title: 'Liked by',userProvider: youMeProvider,list: diary.diaryLikerList,)));
                        },
                        child: Text('${diary.diaryLikerList.length}',style: TextStyle(fontSize: 18,color: textColor),)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10,),
          Divider(color: black,height: 10,),
        ],
      ),
    );
  }
}
