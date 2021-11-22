import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:umee/models/diaries_model.dart';
import 'package:umee/models/user_model.dart';
import 'package:umee/repositories/diary_provider.dart';
import 'package:umee/repositories/user_provider.dart';
import 'package:umee/screens/likers_advices.dart';
import 'package:umee/utils/constants.dart';
import 'package:umee/widgets/diary_video_widget.dart';
import 'package:umee/widgets/post_record_widget.dart';
import 'package:umee/widgets/send_advice_widget.dart';
import 'package:umee/widgets/advices_list_widget.dart';
import 'package:umee/widgets/like_widget.dart';
import 'package:umee/widgets/slide.dart';
import '../utils/shared.dart';
import 'package:umee/widgets/more_sheet.dart';
import 'others_profile.dart';
import 'package:http/http.dart' as http;

class PostAdvicesScreen extends StatelessWidget {
  final Diaries diary;

  const PostAdvicesScreen({Key key, this.diary,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DiaryProvider diaryProvider = Provider.of<DiaryProvider>(context);
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: bar,
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('${diary.userName}\'s Diary',style: TextStyle(color: textColor,fontSize: 18),),
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.more_horiz,color: textColor,size: 25,),
              onPressed: (){
                showModalBottomSheet(context: context, builder: (context){
                  return CustomSheet(diaryProvider: diaryProvider,diary: diary,userProvider: userProvider,);
                }).then((value) {
                  if(value == 'done'){
                    Navigator.pop(context);
                  }
                });
              })
        ],
      ),
      body: SingleChildScrollView(
        physics: ScrollPhysics(),
        child: diaryProvider.diary == null ?
        Center(child: CircularProgressIndicator(backgroundColor: icons,color: icons,))
        : Column(
          children: [
            const SizedBox(height: 20,),
            ListTile(
              onTap: ()async{
                YouMeUser user = await userProvider.getUserOfDiary(diary.userId);
                Admires admire = Admires.add(userId: diary.userId,userImage: diary.userImage,userName: diary.userName,userToken: user.token);
                if(admire.userId == userProvider.getUser.id){
                  Navigator.pushNamed(context, profileRoute);
                }else{
                 Navigator.push(context, MySlide(widgetBuilder: (_) => OthersProfile(admire: admire,))).then((value) {
                  if(value == 'done'){
                    Navigator.pop(context);
                  }
                });
                }
              },
              leading: CircleAvatar(
                radius: 30,
                backgroundColor: textColor,
                backgroundImage: diary.userImage.isEmpty ? AssetImage('assets/pic.jpg')
                    : CachedNetworkImageProvider(diary.userImage),
              ),
              title: Text('${diary.userName}',style: TextStyle(color: textColor,fontSize: 16,letterSpacing: 1,),),
              subtitle: Text('${diaryProvider.getDiaryTime(diary.date)}',style: TextStyle(color: textColor,fontSize: 14,letterSpacing: 1,),),
            ),
            IntrinsicHeight(
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(13)),
                  ),
                  child: Column(
                    children: [
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
                                    YouMeUser user = await userProvider.getUserOfDiary(diary.taggedPeople[index].userId);
                                    Admires admire = Admires.add(userId: diary.taggedPeople[index].userId,
                                        userImage: diary.taggedPeople[index].userImage,userName: diary.taggedPeople[index].userName
                                        ,userToken: user.token);
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
                          : const SizedBox(),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
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
                        height: MediaQuery.of(context).size.height - SizeConfig.screenHeight * 0.2,
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.fromLTRB(0,0,0,10),
                        child: Swiper(
                          itemCount: diary.images.length,
                          loop: false,
                          pagination: new SwiperPagination(
                            alignment: Alignment.bottomCenter,
                            builder: new DotSwiperPaginationBuilder(
                                color: textColor, activeColor: icons),
                          ),
                          itemBuilder: (BuildContext context,int index){
                            return CachedNetworkImage(
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
                            );
                          },
                        ),
                      )
                          : Container(),
                      diary.videoUrl.isNotEmpty ?
                      DiaryVideoWidget(url: diary.videoUrl,ratio: true,)
                          : Container(),
                      diary.recordUrl.isNotEmpty ?
                      PostRecordWidget(path: diary.recordUrl,)
                          : Container(),
                    ],
                  )
              ),
            ),
            const  SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Icon(Icons.location_on,size: 23,color: textColor,),
                  SizedBox(width: 5,),
                  Flexible(child: Text('${diary.location}',style: TextStyle(color: textColor),))
                ],
              ),
            ),
           const SizedBox(height: 10,),
            Container(
              color: buttons,
              height: 70,
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: Row(
                      children: [
                        LikeDiary(diaryProvider: diaryProvider,diary: diary,youMeProvider: userProvider,),
                        SizedBox(width: 5,),
                        Text('${diaryProvider.diary.diaryLikerList.length}',style: TextStyle(color: textColor,fontSize: 19),),
                      ],
                    ),
                  ),
                  const  SizedBox(width: 20,),
                      Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: IconButton(
                          icon: Icon(Icons.share),
                          iconSize: 30,
                          color: textColor,
                          onPressed: ()async{
                            final temp = await getTemporaryDirectory();
                            if(diary.images.isNotEmpty){
                                final url = Uri.parse(diary.images.first);
                                final response = await http.get(url);
                                final bytes = response.bodyBytes;
                                final path = '${temp.path}/image.jpg';
                                File(path).writeAsBytesSync(bytes);
                              await Share.shareFiles([path],text: diary.content).catchError((e) {
                                print(e.toString());
                              });
                            }else if(diary.videoUrl.isNotEmpty){
                                final url = Uri.parse(diary.videoUrl);
                                final response = await http.get(url);
                                final bytes = response.bodyBytes;
                                final path = '${temp.path}/video.mp4';
                                File(path).writeAsBytesSync(bytes);
                              await Share.shareFiles([path],text: diary.content).catchError((e) {
                                print(e.toString());
                              });
                            }else if(diary.recordUrl.isNotEmpty){
                              final url = Uri.parse(diary.recordUrl);
                              final response = await http.get(url);
                              final bytes = response.bodyBytes;
                              final path = '${temp.path}/record.mp4';
                              File(path).writeAsBytesSync(bytes);
                              await Share.shareFiles([path],text: diary.content).catchError((e) {
                                print(e.toString());
                              });
                            }else {
                              await Share.share(diary.content).catchError((e) {
                                print(e.toString());
                              });
                            }
                          },
                        ),
                      ),
                ],
              ),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text('${diaryProvider.diary.advices.length} Advices',style: TextStyle(color: icons,),),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: InkWell(
                    child: Text('View All',style: TextStyle(color: icons,  decoration: TextDecoration.underline,fontSize: 15),),
                    onTap: (){
                      Navigator.push(context, MySlide(widgetBuilder: (_) =>
                          LikesAdvices(userProvider: userProvider,likesList: diaryProvider.diary.diaryLikerList,advicesList: diaryProvider.diary.advices,)));
                    },
                  ),
                )
              ],
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: diaryProvider.diary.advices.length ?? 0,
              itemBuilder: (BuildContext context,int index){
                 return diaryProvider.diary.advices.isEmpty || userProvider.isUserBlocked(diaryProvider.diary.advices[index].userId,userProvider.getUser)? const SizedBox()
                  : CommentAdviceWidget(advice: diaryProvider.diary.advices[index],diaryProvider: diaryProvider,userProvider: userProvider,diaryId: diary.id,);
            }),
            const SizedBox(height: 15,),
            AdviceWidget(userProvider: userProvider,diary: diary,diaryProvider: diaryProvider,)
          ],
        ),
      ),
    );
  }
}
