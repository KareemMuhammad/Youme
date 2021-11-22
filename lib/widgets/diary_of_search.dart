import 'package:flutter/material.dart';
import 'package:umee/models/diaries_model.dart';
import 'package:umee/repositories/diary_provider.dart';
import 'package:umee/repositories/user_provider.dart';
import 'package:umee/widgets/diary_widget.dart';

class DiariesOfSearch extends StatelessWidget {
  final DiaryProvider diaryProvider;
  final UserProvider userProvider;
  final List<Diaries> list;

  const DiariesOfSearch({Key key, this.diaryProvider, this.userProvider, this.list}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: list.length ?? 0,
      itemBuilder: (BuildContext context, int index) {
        return userProvider.isUserBlocked(list[index].userId,userProvider.getUser)
            || diaryProvider.isHiddenDiary(list[index], userProvider.getUser) ? SizedBox()
            : DiaryWidget(diaryProvider: diaryProvider, youMeProvider: userProvider,
          diary: list[index],);
      },
    );
  }
}
