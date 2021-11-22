import 'package:flutter/material.dart';
import 'package:umee/models/diaries_model.dart';
import 'package:umee/repositories/diary_provider.dart';
import 'package:umee/repositories/user_provider.dart';
import 'package:umee/utils/constants.dart';
import 'package:umee/utils/shared.dart';

class AdviceWidget extends StatefulWidget {
  final DiaryProvider diaryProvider;
  final UserProvider userProvider;
  final Diaries diary;

  const AdviceWidget({Key key, this.diaryProvider, this.userProvider, this.diary}) : super(key: key);
  @override
  _AdviceWidgetState createState() => _AdviceWidgetState();
}

class _AdviceWidgetState extends State<AdviceWidget> {
  TextEditingController msgText = new TextEditingController();
  bool isSendAdvice = false;
  @override
  void initState() {
    super.initState();
    widget.userProvider.refreshUserOfDiary(widget.diary.userId);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Stack(
      children: [
        Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
          ),
          elevation: 1,
          child: Container(
            padding: EdgeInsets.all(14),
            width: SizeConfig.screenWidth,
            decoration: BoxDecoration(
                color: buttons,
                borderRadius: BorderRadius.circular(10)
            ),
            child: TextField(
              style: TextStyle(color: textColor,fontSize: 17),
              decoration: InputDecoration(
                hintStyle: TextStyle(fontSize: 16,color: Colors.white70),
                hintText: 'Write your advice',
                border: InputBorder.none,
              ),
              controller: msgText,
            ),
          ),
        ),
        Positioned(
            bottom: 16,
            right: 2,
            child: isSendAdvice ?
            Center(child: RefreshProgressIndicator(backgroundColor: icons,),)
            :IconButton(icon: Icon(Icons.send),color: icons,
              iconSize: 25,
              onPressed: ()async{
                if(msgText.text.isNotEmpty){
                  sendAdvice();
                }else{
                  Utils.showToast('Advice can\'t be empty');
                }
              },)
        ),
      ],
      overflow: Overflow.visible,
    );
  }
  void sendAdvice()async{
    setState(() {
      isSendAdvice = true;
    });
    String date = Utils.currentDate();
    Advice advice = Advice.add(content: msgText.text,date: '$date', userName: widget.userProvider.getUser.name,
        userId: widget.userProvider.getUser.id, userImage: widget.userProvider.getUser.image);
    widget.diaryProvider.addNewAdviceToDiary(advice, widget.diary.id,widget.userProvider.getUser);
    if(widget.diaryProvider.getUserDiaries.isNotEmpty){
      widget.diaryProvider.addAdviceToUserList(widget.diary, advice);
    }
    if(widget.diaryProvider.homeFeed) {
      widget.diaryProvider.addAdviceToPublicStreamList(widget.diaryProvider.diary, advice);
      if(widget.userProvider.followingCheck(widget.diary.userId, widget.userProvider.getUser)){
        widget.diaryProvider.addAdviceToFollowingStreamList(widget.diaryProvider.diary, advice);
        widget.diaryProvider.addNewAdviceToDiaryOfFollowing(advice,widget.diary.id,widget.userProvider.getUser);

      }
    }else{
      widget.diaryProvider.addAdviceToFollowingStreamList(widget.diaryProvider.diary, advice);
      widget.diaryProvider.addNewAdviceToDiaryOfFollowing(advice,widget.diary.id,widget.userProvider.getUser);
       if(widget.diaryProvider.getPublicDiaries.isNotEmpty && widget.diary.category == Utils.PUBLIC){
         widget.diaryProvider.addAdviceToPublicStreamList(widget.diaryProvider.diary, advice);
       }
    }
    msgText.clear();
    setState(() {
      isSendAdvice = false;
    });
    if(widget.userProvider.getUser.token != widget.userProvider.userOfDiary.token) {
      await Utils.sendPushMessage(
          widget.userProvider.userOfDiary.token,
          '${widget.userProvider.getUser.name} commented on your diary',
          'YOUME',
          Utils.DIARY_TAGS_SECTION,
          widget.userProvider.getUser.id,
          '$date',
          widget.userProvider.getUser.image,
          widget.diary.id);
    }
  }
}
