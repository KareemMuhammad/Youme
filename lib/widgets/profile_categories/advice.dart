import 'package:flutter/material.dart';
import 'package:umee/models/diaries_model.dart';
import 'package:umee/repositories/diary_provider.dart';
import 'package:umee/repositories/user_provider.dart';
import 'package:umee/widgets/advices_list_widget.dart';

class ProfileAdviceWidget extends StatelessWidget {
  final UserProvider userProvider;
  final DiaryProvider diaryProvider;
  final List<Advice> adviceList;
  final String diaryId;

  const ProfileAdviceWidget({Key key, this.userProvider, this.diaryProvider, this.adviceList, this.diaryId,}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: adviceList.length,
        itemBuilder: (BuildContext context,index){
      return CommentAdviceWidget(advice: adviceList[index],diaryProvider: diaryProvider,userProvider: userProvider,cancelTap: true,diaryId: diaryId,);
    });
  }
}