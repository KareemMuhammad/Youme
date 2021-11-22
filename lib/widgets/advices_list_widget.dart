import 'package:flutter/material.dart';
import 'package:umee/models/diaries_model.dart';
import 'package:umee/models/user_model.dart';
import 'package:umee/repositories/diary_provider.dart';
import 'package:umee/repositories/user_provider.dart';
import 'package:umee/screens/others_profile.dart';
import 'package:umee/screens/post_advices_screen.dart';
import 'package:umee/utils/constants.dart';
import 'package:umee/utils/shared.dart';
import 'package:umee/widgets/slide.dart';

class CommentAdviceWidget extends StatelessWidget {
  final Advice advice;
  final String diaryId;
  final DiaryProvider diaryProvider;
  final UserProvider userProvider;
  final bool cancelTap;

  const CommentAdviceWidget({Key key, this.advice, this.diaryProvider, this.userProvider, this.diaryId, this.cancelTap = false, }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Container(
        alignment: Alignment.topLeft,
        padding: EdgeInsets.all(8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              onTap: ()async{
                if (!cancelTap) {
                  if (userProvider.getUser.id != advice.userId && !userProvider.getUser.blocked.contains(advice.userId)) {
                    userProvider.setOthersBool(true);
                    YouMeUser user = await userProvider.getUserOfDiary(advice.userId);
                    Admires admire = Admires.add(
                        userId: advice.userId,
                        userImage: advice.userImage,
                        userName: advice.userName,
                        userToken: user.token);
                    Navigator.push(context, MySlide(widgetBuilder: (_) => OthersProfile(admire: admire,)));
                  } else {
                    Navigator.pushNamed(context, profileRoute);
                  }
                }else{
                 await diaryProvider.refreshSingleDiary(diaryId);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => PostAdvicesScreen(diary: diaryProvider.diary,)));
                }
              },
              leading: CircleAvatar(
                radius: 20,
                backgroundColor: textColor,
                backgroundImage: advice.userImage.isEmpty ? AssetImage('assets/pic.jpg') : NetworkImage(advice.userImage),
              ),
              title:  Text('${advice.userName ?? 'Unknown'}',style: TextStyle(color: textColor,fontSize: 15,letterSpacing: 1,fontWeight: FontWeight.bold),),
              subtitle: Text('${advice.content}',style: TextStyle(color: textColor,fontSize: 15,letterSpacing: 1,),),
              trailing: Text('${diaryProvider.getAdviceTime(advice.date)}',style: TextStyle(color: Colors.white70,fontSize: 15,letterSpacing: 1,),),
              onLongPress: ()async{
                if(advice.userId == userProvider.getUser.id) {
                  await showDialog(context: context, builder: (_) {
                    return Dialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius
                          .circular(20.0)),
                      backgroundColor: background,
                      child: Container(
                        color: background,
                        height: MediaQuery.of(context).size.height - SizeConfig.screenHeight * 0.7,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Text(
                                  'Are you sure?\n you want to delete your advice!',
                                  style: TextStyle(fontSize: 18, color: textColor),
                                  textAlign: TextAlign.center,),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: RaisedButton(
                                  color: buttons,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('Delete', style: TextStyle(
                                        fontSize: 18,
                                        color: textColor
                                    ),),
                                  ),
                                  onPressed: () async {
                                    await diaryProvider.removeAdviceFromDiary(advice, diaryProvider.diary.id, userProvider.getUser);
                                    if(diaryProvider.getUserDiaries.isNotEmpty){
                                      diaryProvider.removeAdviceFromUserList(diaryProvider.diary, advice);
                                    }
                                      if(diaryProvider.homeFeed) {
                                        diaryProvider.removeAdviceFromPublicStreamList( diaryProvider.diary, advice);
                                        if(userProvider.followingCheck(advice.userId, userProvider.getUser)){
                                          diaryProvider.removeAdviceFromFollowingStreamList(diaryProvider.diary, advice);
                                        await diaryProvider.removeAdviceFromFollowingDiary(advice, diaryProvider.diary.id, userProvider.getUser);
                                        }
                                      }else{
                                        diaryProvider.removeAdviceFromFollowingStreamList(diaryProvider.diary, advice);
                                        await diaryProvider.removeAdviceFromFollowingDiary(advice, diaryProvider.diary.id, userProvider.getUser);
                                        if(diaryProvider.getPublicDiaries.isNotEmpty && diaryProvider.diary.category == Utils.PUBLIC){
                                          diaryProvider.removeAdviceFromPublicStreamList( diaryProvider.diary, advice);
                                        }
                                      }
                                    Utils.showToast('Your advice has been deleted');
                                    Navigator.pop(context, 'done');
                                  }
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  });
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 0,horizontal: 30),
              child: Divider(color: textColor,height: 1,),
            ),
          ],
        ),
      ),
    );
  }
}
