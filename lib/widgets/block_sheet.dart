import 'package:flutter/material.dart';
import 'package:umee/models/diaries_model.dart';
import 'package:umee/repositories/diary_provider.dart';
import 'package:umee/repositories/user_provider.dart';
import '../utils/shared.dart';


class BlockSheet extends StatelessWidget{
  final Admires admire;
  final DiaryProvider diaryProvider;
  final UserProvider youMeProvider;

  const BlockSheet({Key key, this.admire, this.diaryProvider, this.youMeProvider}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      color: background,
      padding: EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height - SizeConfig.screenHeight * 0.6,
      child: Column(crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Block ${admire.userName}?',style: TextStyle(color: textColor,fontSize: 18,fontWeight: FontWeight.bold),),
                SizedBox(width: 5,),
                iconStyle(Icons.block),
              ],
            ),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('if you block ${admire.userName} you will not be able to see his/her diaries again unless you cancel the block',style: TextStyle(color: textColor,fontSize: 16,),),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: RaisedButton(
              color: buttons,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              elevation: 2,
              onPressed: () {
                youMeProvider.blockUser(admire.userId,admire);
                Navigator.pop(context,'done');
              },
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text('Continue',style: TextStyle(letterSpacing: 1,fontSize: 16,color: textColor),),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget iconStyle(IconData icon){
    return Icon(icon,size: 25,color: textColor,);
  }

}
