import 'package:flutter/material.dart';
import 'package:umee/models/diaries_model.dart';
import 'package:umee/repositories/diary_provider.dart';
import 'package:umee/repositories/user_provider.dart';
import 'package:umee/utils/shared.dart';
import 'package:umee/widgets/advices_list_widget.dart';

class AdviceByList extends StatelessWidget {
  final List<Advice> advice;
  final DiaryProvider diaryProvider;
  final UserProvider userProvider;

  const AdviceByList({Key key, this.advice, this.diaryProvider, this.userProvider}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Diary Advices',style: TextStyle(color: textColor,fontSize: 18),),
      ),
      backgroundColor: background,
      body: ListView.builder(
          padding: EdgeInsets.all(10),
          itemCount: advice.length ?? 0,
          itemBuilder: (BuildContext context,int index){
            return advice.isEmpty ? Container()
                : CommentAdviceWidget(advice: advice[index],diaryProvider: diaryProvider,userProvider: userProvider,);
          }),
    );
  }
}
