import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:umee/models/diaries_model.dart';
import 'package:umee/models/user_model.dart';
import 'package:umee/repositories/diary_provider.dart';
import 'package:umee/repositories/user_provider.dart';
import 'package:umee/screens/others_profile.dart';
import 'package:umee/screens/profile_advices.dart';
import 'package:umee/screens/view_all_screen.dart';
import 'package:umee/utils/constants.dart';
import 'package:umee/utils/shared.dart';
import 'package:umee/widgets/diary_video_widget.dart';
import 'package:umee/widgets/large_screen_image.dart';
import 'package:umee/widgets/post_record_widget.dart';
import 'package:umee/widgets/slide.dart';

class ByDateWidget extends StatelessWidget {
  final Diaries diary;
  final UserProvider userProvider;
  final DiaryProvider diaryProvider;

  const ByDateWidget({Key key, this.diary, this.userProvider, this.diaryProvider}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            radius: 25,
            backgroundColor: textColor,
            backgroundImage: diary.userImage.isEmpty ? AssetImage('assets/pic.jpg')
                : CachedNetworkImageProvider(diary.userImage),
          ),
          title: Text('${diary.userName}',style: TextStyle(color: textColor,fontSize: 17,letterSpacing: 1,),),
          subtitle: Text('${diaryProvider.getDiaryTime(diary.date)}',style: TextStyle(color: textColor,fontSize: 13),),
          trailing: Text('${diary.category}',style: TextStyle(color: textColor,fontSize: 16,letterSpacing: 1,),),
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
                      userProvider.setOthersBool(true);
                      YouMeUser user = await userProvider.getUserOfDiary(diary.taggedPeople[index].userId);
                      Admires admire = Admires.add(userId: diary.taggedPeople[index].userId,userImage: diary.taggedPeople[index].userImage,userName: diary.taggedPeople[index].userName,userToken: user.token);
                      if(admire.userId == userProvider.getUser.id){
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
            : SizedBox(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child:Row(mainAxisAlignment: RegExp(Utils.REGEX_PATTERN).hasMatch(diary.content)? MainAxisAlignment.end : MainAxisAlignment.start,
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
              builder: new DotSwiperPaginationBuilder(
                  color: textColor, activeColor: icons),
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
                  imageBuilder: (context, imageProvider) => Container(
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
            : Container(),
        diary.videoUrl.isNotEmpty ?
        DiaryVideoWidget(url: diary.videoUrl,)
            : Container(),
        diary.recordUrl.isNotEmpty ?
        PostRecordWidget(path: diary.recordUrl,)
            : Container(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Icon(Icons.location_on,size: 20,color: textColor,),
              SizedBox(width: 5,),
              Flexible(child: Text('${diary.location}',style: TextStyle(color: textColor),))
            ],
          ),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: (){
                Navigator.push(context, MySlide(widgetBuilder: (_) =>
                    AdviceByList(advice: diary.advices,diaryProvider: diaryProvider,userProvider: userProvider,)));
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Row(mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('${diary.advices.length}',style: TextStyle(letterSpacing: 1,fontSize: 16,color: textColor),),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: Text('Advices',style: TextStyle(letterSpacing: 1,fontSize: 17,color: textColor),),
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: (){
                Navigator.push(context, MySlide(widgetBuilder: (_) =>
                    ViewAllScreen(title: 'Liked by',userProvider: userProvider,list: diary.diaryLikerList)));
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Row(mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('${diary.diaryLikerList.length}',style: TextStyle(letterSpacing: 1,fontSize: 16,color: textColor),),
                    ),
                    Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: Text('Likes',style: TextStyle(letterSpacing: 1,fontSize: 17,color: textColor),)
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Divider(height: 1,color: textColor,),
        ),
      ],
    );
  }
}
