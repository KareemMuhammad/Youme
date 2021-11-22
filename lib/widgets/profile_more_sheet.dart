import 'package:flutter/material.dart';
import 'package:umee/models/diaries_model.dart';
import 'package:umee/repositories/diary_provider.dart';
import 'package:umee/repositories/user_provider.dart';
import 'package:umee/screens/edit_diary.dart';
import 'package:umee/utils/constants.dart';
import '../utils/shared.dart';

class ProfileCustomSheet extends StatelessWidget{
  final Diaries diary;
  final DiaryProvider diaryProvider;
  final UserProvider youMeProvider;

  const ProfileCustomSheet({Key key, this.diary, this.diaryProvider, this.youMeProvider}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      color: background,
      padding: EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height - SizeConfig.screenHeight * 0.8,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: (){
             diaryProvider.deleteDiary(diary.id);
             youMeProvider.decrementUserDiaryNumber();
             diaryProvider.deleteSingleDiaryOfFollow(diary.id, youMeProvider.getUser);
             diaryProvider.deleteUserDiaryFromList(diary);
             Utils.showToast('Diary has been deleted');
             Navigator.pop(context);
            },
            child: Row(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                iconStyle(Icons.delete),
                SizedBox(width: 10,),
                textStyle('Delete This Diary'),
              ],
            ),
          ),
          SizedBox(height: 20,),
          InkWell(
            onTap: (){
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => EditDiaryScreen(diary: diary,)));
            },
            child: Row(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                iconStyle(Icons.edit),
                SizedBox(width: 10,),
                textStyle('Edit This Diary'),
              ],
            ),
          ),
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
