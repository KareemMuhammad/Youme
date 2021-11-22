import 'package:flutter/material.dart';
import 'package:umee/models/diaries_model.dart';
import 'package:umee/models/user_model.dart';
import 'package:umee/repositories/diary_provider.dart';
import 'package:umee/repositories/user_provider.dart';
import 'package:umee/utils/constants.dart';
import '../utils/shared.dart';


class CustomSheet extends StatelessWidget{
  final Diaries diary;
  final DiaryProvider diaryProvider;
  final UserProvider userProvider;

  const CustomSheet({Key key, this.diary, this.diaryProvider, this.userProvider}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      color: background,
      padding: EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height - SizeConfig.screenHeight * 0.7,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          !userProvider.followingCheck(diary.userId,userProvider.getUser) ?
       InkWell(
        onTap: ()async{
          YouMeUser user = await userProvider.getUserOfDiary(diary.userId);
          Admires admire = Admires.add(userId: diary.userId,userImage: diary.userImage,userName: diary.userName,userToken: user.token);
          await userProvider.updateFollowersId(admire.userId);
          await userProvider.updateFollowId(admire.userId);
          userProvider.addFollower(admire);
          diaryProvider.saveDiariesOfFollow(diary.userId, userProvider.getUser.id);
          userProvider.refreshUser();
          String date = Utils.currentDate();
          if(user.token != userProvider.getUser.token) {
            await Utils.sendPushMessage(
                user.token,
                '${userProvider.getUser.name} started following you',
                'YOUME'
                ,
                Utils.NOTIFICATIONS_SECTION,
                userProvider.getUser.id,
                '$date',
                userProvider.getUser.image,
                '');
          }
          Navigator.pop(context);
        },
        child: Row(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            iconStyle(Icons.person_add_alt_1),
            SizedBox(width: 10,),
            textStyle('Follow @${diary.userName}'),
          ],
        ),
      )
        :InkWell(
            onTap: ()async{
              YouMeUser user = await userProvider.getUserOfDiary(diary.userId);
              Admires admire = Admires.add(userId: diary.userId,userImage: diary.userImage,userName: diary.userName,userToken: user.token);
              await userProvider.removeFollowId(admire.userId);
              await userProvider.removeFollowersId(admire.userId);
              userProvider.removeFollower(admire);
              diaryProvider.deleteDiariesOfFollow(diary.userId, userProvider.getUser.id);
              userProvider.refreshUser();
              Navigator.pop(context);
            },
            child: Row(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                iconStyle(Icons.person_add_disabled),
                SizedBox(width: 10,),
                textStyle('Unfollow @${diary.userName}'),
              ],
            ),
          ),
          SizedBox(height: 20,),
          InkWell(
            onTap: ()async{
              YouMeUser user = await userProvider.getUserOfDiary(diary.userId);
              Admires admire = Admires.add(userId: diary.userId,
                  userImage: diary.userImage,userName: diary.userName,userToken: user.token);
              userProvider.blockUser(diary.userId,admire);
              diaryProvider.deleteDiariesOfFollow(diary.userId, userProvider.getUser.id);
              Navigator.pop(context,'done');
            },
            child: Row(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                iconStyle(Icons.block),
                SizedBox(width: 10,),
                textStyle('Block @${diary.userName}'),
              ],
            ),
          ),
          SizedBox(height: 20,),
          InkWell(
            onTap: (){
            userProvider.updateUserFeedHiddenDiaries(diary.id, userProvider.getUser.id);
            Navigator.pop(context,'done');
            },
            child: Row(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                iconStyle(Icons.lock),
                SizedBox(width: 10,),
                textStyle('Hide This Diary'),
              ],
            ),
          ),
       /*   SizedBox(height: 20,),
          InkWell(
            onTap: (){

            },
            child: Row(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                iconStyle(Icons.flag),
                SizedBox(width: 10,),
                textStyle('Report This Diary'),
              ],
            ),
          ), */
        ],
      ),
    );
  }

  Widget textStyle(String text){
    return Text(text,style: TextStyle(color: textColor,fontSize: 20),);
  }

  Widget iconStyle(IconData icon){
    return Icon(icon,size: 28,color: textColor,);
  }

}
