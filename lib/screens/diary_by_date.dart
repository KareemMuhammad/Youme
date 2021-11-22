import 'package:flutter/material.dart';
import 'package:umee/models/diaries_model.dart';
import 'package:umee/repositories/diary_provider.dart';
import 'package:umee/repositories/user_provider.dart';
import 'package:umee/utils/shared.dart';
import 'package:umee/widgets/profile_categories/by_date_widget.dart';

class DiaryByDateScreen extends StatelessWidget {
  final String date;
  final String userId;
  final DiaryProvider diaryProvider;
  final UserProvider userProvider;

  const DiaryByDateScreen({Key key, this.date, this.userId, this.diaryProvider, this.userProvider}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: bar,
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('$date',style: TextStyle(color: textColor,fontSize: 19),),
        ),
      ),
      backgroundColor: background,
      body: FutureBuilder<List<Diaries>>(
        future: diaryProvider.fetchDiariesByDateOfUser(userId,date),
        builder: (BuildContext context, AsyncSnapshot<List<Diaries>> snapshot) {
          return snapshot.data != null && snapshot.data.isNotEmpty ?
          ListView.builder(
              itemCount: snapshot.data.length ?? 0,
              itemBuilder: (context,index){
                return ByDateWidget(diary: snapshot.data[index],diaryProvider: diaryProvider,userProvider: userProvider,);
              }) : Center(child: Text('No diaries at this date',style: TextStyle(color: textColor,fontSize: 18),),);
        },
      )
    );
  }
}
