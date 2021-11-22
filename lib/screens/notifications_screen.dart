import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:umee/models/diaries_model.dart';
import 'package:umee/models/notification_model.dart';
import 'package:umee/models/user_model.dart';
import 'package:umee/repositories/diary_provider.dart';
import 'package:umee/repositories/user_provider.dart';
import 'package:umee/screens/others_profile.dart';
import 'package:umee/screens/post_advices_screen.dart';
import 'package:umee/utils/constants.dart';
import 'package:umee/widgets/slide.dart';
import '../utils/shared.dart';

class YouMeNotifications extends StatelessWidget {
  final bool screenWidget;
  final UserProvider userProvider;
  final DiaryProvider diaryProvider;

  const YouMeNotifications({Key key, this.screenWidget = false, this.userProvider, this.diaryProvider}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    if(userProvider.getUser != null){
    userProvider.getUser.notifications.sort((a,b) => b.time.compareTo(a.time));
    }
    return Scaffold(
        backgroundColor: background,
        appBar: screenWidget ? AppBar(
          centerTitle: true,
          title: Text('Notifications',style: TextStyle(color: textColor,fontSize: 19),),
          leading: IconButton(
            icon: Icon(Icons.arrow_back,color: textColor,),
            onPressed: (){
              Navigator.pushReplacementNamed(context, wrapper);
            },
          ),
        ) : AppBar(elevation: 0,backgroundColor: background,toolbarHeight: 0,),
      body: userProvider.getUser != null ? Container(
        padding: const EdgeInsets.all(15),
        child: RefreshIndicator(
          onRefresh: () async{
            await Future.delayed(Duration(seconds: 1));
            userProvider.refreshUser();
          },
          child: Container(
            color: background,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Notifications',style: TextStyle(color: textColor,fontSize: 18),),
                ),
                userProvider.getUser.notifications.isEmpty ?
                Center(child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text('You have no notifications yet',style: TextStyle(color: textColor,fontSize: 18),),
                )):
                Expanded(
                  child: ListView.builder(
                            itemCount: userProvider.getUser.notifications.length ?? 0,
                            itemBuilder: (_, index){
                              NotificationModel notificationModel = userProvider.getUser.notifications[index];
                              return userProvider.getUser.notifications.isEmpty?
                                  Center(child: Text('You have no notifications yet',style: TextStyle(color: textColor,fontSize: 18),)) :
                                Card(
                                  color: buttons,
                                  elevation: 4,
                                  child: ListTile(
                                    onTap: ()async{
                                      switch (notificationModel.route){
                                        case Utils.NOTIFICATIONS_SECTION:
                                          if(notificationModel.userId == userProvider.getUser.id){
                                            Navigator.pushNamed(context, profileRoute);
                                          }else{
                                            YouMeUser user = await userProvider.getUserOfDiary(notificationModel.userId);
                                            Admires admire = Admires.add(userId: user.id,userImage: user.image,
                                                userName: user.name,userToken: user.token);
                                            Navigator.push(context, MySlide(widgetBuilder: (_) => OthersProfile(admire: admire,)));
                                          }
                                          break;
                                        case Utils.REMINDER_TAGS_SECTION:
                                           Navigator.pushNamed(context, reminderRoute);
                                          break;
                                        case Utils.POST_TAGS_SECTION:
                                         await diaryProvider.refreshSingleDiary(notificationModel.diaryId);
                                          Navigator.push(context, MaterialPageRoute(builder: (_) => PostAdvicesScreen(diary: diaryProvider.diary,)));
                                          break;
                                        case Utils.DIARY_TAGS_SECTION:
                                          await diaryProvider.refreshSingleDiary(notificationModel.diaryId);
                                          Navigator.push(context, MaterialPageRoute(builder: (_) => PostAdvicesScreen(diary: diaryProvider.diary,)));
                                          break;
                                      }
                                    },
                                    leading: notificationModel.icon.isNotEmpty ?
                                    CachedNetworkImage(
                                      imageUrl: notificationModel.icon,
                                      progressIndicatorBuilder: (context, url, downloadProgress) =>
                                          Image.asset('assets/image-not-found.png'),
                                      errorWidget: (context, url, error) => Icon(Icons.error),
                                    ) :  Image.asset('assets/pic.jpg'),
                                    title: Text(
                                      '${notificationModel.title}',style: TextStyle(color: textColor,),
                                    ),
                                    subtitle: Text(
                                      '${userProvider.getNotificationTime(notificationModel.time)}',style: TextStyle(color: textColor,),
                                    ),
                                  ),
                                );
                      }
                        ),
                ),
              ],
            ),
          ),
        )
      ) : Center(child: CircularProgressIndicator(backgroundColor: icons,),),
    );
  }
}
