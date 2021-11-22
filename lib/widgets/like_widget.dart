import 'package:flutter/material.dart';
import 'package:umee/models/diaries_model.dart';
import 'package:umee/repositories/diary_provider.dart';
import 'package:umee/repositories/user_provider.dart';
import 'package:umee/utils/constants.dart';
import 'package:umee/utils/shared.dart';

class LikeDiary extends StatefulWidget {
  final Diaries diary;
  final int likesCount;
  final UserProvider youMeProvider;
  final DiaryProvider diaryProvider;

  const LikeDiary({Key key, this.diary, this.youMeProvider, this.diaryProvider, this.likesCount}) : super(key: key);

  @override
  _LikeDiaryState createState() => _LikeDiaryState();
}

class _LikeDiaryState extends State<LikeDiary> {
  bool isLike = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
          padding: const EdgeInsets.all(1.0),
          child: widget.diaryProvider.isDiaryLiked(widget.youMeProvider.getUser, widget.diary.id)  ?
          IconButton(
            icon: Icon(Icons.favorite),
            iconSize: 28,
            color: red,
            onPressed: ()async{
                 unlikePost();
            },
          ) : isLike?
          IconButton(
            icon: Icon(Icons.favorite),
            iconSize: 28,
            color: red,
            onPressed: ()async{
                unlikePost();
            },
          )  :IconButton(
            icon: Icon(Icons.favorite_border),
            iconSize: 28,
            color: textColor,
            onPressed: ()async{
                likePost();
            },
          )
        );
  }

  void likePost(){
    setState(() {
      isLike = true;
    });
    Admires admire = Admires.add(userId: widget.youMeProvider.getUser.id,userImage: widget.youMeProvider.getUser.image,
        userName: widget.youMeProvider.getUser.name,userToken: widget.youMeProvider.getUser.token);
    widget.youMeProvider.updateUserLikedDiary(widget.diary.id);
    widget.diaryProvider.addLiker(admire, widget.diary.id,widget.youMeProvider.getUser);
    if(widget.diaryProvider.getUserDiaries.isNotEmpty){
      widget.diaryProvider.addLikerToUserList(widget.diary, admire);
    }
    if(widget.diaryProvider.homeFeed) {
      widget.diaryProvider.addLikerToPublicStreamList(widget.diary, admire);
      if(widget.youMeProvider.followingCheck(widget.diary.userId, widget.youMeProvider.getUser)){
      widget.diaryProvider.addLikerToFollowing(admire, widget.diary.id,widget.youMeProvider.getUser);
      if(widget.diaryProvider.getFollowingDiaries.isNotEmpty){
        widget.diaryProvider.addLikerToFollowingStreamList(widget.diary, admire);
      }
    }
    }else{
      widget.diaryProvider.addLikerToFollowing(admire, widget.diary.id,widget.youMeProvider.getUser);
      widget.diaryProvider.addLikerToFollowingStreamList(widget.diary, admire);
      if(widget.diaryProvider.getPublicDiaries.isNotEmpty && widget.diary.category == Utils.PUBLIC) {
        widget.diaryProvider.addLikerToPublicStreamList(widget.diary, admire);
      }
    }
  }

  void unlikePost() {
    setState(() {
      isLike = false;
    });
    Admires admire = Admires.add(userId: widget.youMeProvider.getUser.id,userImage: widget.youMeProvider.getUser.image,
        userName: widget.youMeProvider.getUser.name,userToken: widget.youMeProvider.getUser.token);
    widget.youMeProvider.removeUserLikedDiary(widget.diary.id);
    widget.diaryProvider.removeLiker(admire, widget.diary.id,widget.youMeProvider.getUser);
    if(widget.diaryProvider.getUserDiaries.isNotEmpty){
      widget.diaryProvider.removeLikerFromUserList(widget.diary, admire);
    }
    if(widget.diaryProvider.homeFeed) {
      widget.diaryProvider.removeLikerFromPublicStreamList(widget.diary, admire);
      if(widget.youMeProvider.followingCheck(widget.diary.userId, widget.youMeProvider.getUser)) {
        widget.diaryProvider.removeLikerFromFollowing(admire, widget.diary.id,widget.youMeProvider.getUser);
        if(widget.diaryProvider.getFollowingDiaries.isNotEmpty){
          widget.diaryProvider.removeLikerFromFollowingStreamList(widget.diary, admire);
        }
      }
    }else{
      widget.diaryProvider.removeLikerFromFollowing(admire, widget.diary.id,widget.youMeProvider.getUser);
      widget.diaryProvider.removeLikerFromFollowingStreamList(widget.diary, admire);
      if(widget.diaryProvider.getPublicDiaries.isNotEmpty && widget.diary.category == Utils.PUBLIC) {
        widget.diaryProvider.removeLikerFromPublicStreamList(widget.diary, admire);
      }
    }
  }
}
