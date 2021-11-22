import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:umee/repositories/user_provider.dart';
import 'package:umee/utils/constants.dart';
import 'package:umee/widgets/password_sheet.dart';
import '../utils/shared.dart';

class DiaryOptions extends StatefulWidget {
  final UserProvider userProvider;

  const DiaryOptions({Key key, this.userProvider}) : super(key: key);
  @override
  _DiaryOptionsState createState() => _DiaryOptionsState();
}

class _DiaryOptionsState extends State<DiaryOptions> {
  int selectedRadio = 0;
  int extendedSelectedRadio = 0;
  int index = 0;
  int extendIndex = 0;
  bool extend = false;
  bool who = false;
  bool whoName = false;
  List<String> person = [];
  final List<String> groupList = [Utils.PUBLIC, Utils.FOLLOWERS,Utils.ONLY_DIARIES,Utils.SECRETS,Utils.WILL];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        centerTitle: true,
        backgroundColor: bar,
        title: Padding(
         padding: const EdgeInsets.all(8.0),
         child: Text('Diary Settings',style: TextStyle(color: textColor,fontSize: 20),),
        ),
      ),
      backgroundColor: background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.all(18.0),
              child: Text('Choose who can see your diary',style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: textColor
              ),),
            ),
            RadioListTile(
                value: 1,
                groupValue: selectedRadio,
                title: Text(groupList[0],style: TextStyle(
                    fontSize: 18,
                    color: textColor,
                ),),
                activeColor: icons,
                onChanged: (value){
                  setState(() {
                    index = 0;
                    selectedRadio = value;
                    extend = false;
                    who = false;
                    whoName = false;
                    extendedSelectedRadio = 0;
                  });
                }),
            RadioListTile(
                value: 2,
                groupValue: selectedRadio,
                title: Text(groupList[1],style: TextStyle(
                    fontSize: 18,
                    color: textColor,
                ),),
                activeColor: icons,
                onChanged: (value){
                  setState(() {
                    index = 1;
                    selectedRadio = value;
                    extend = false;
                    who = false;
                    whoName = false;
                    extendedSelectedRadio = 0;
                  });
                }),
            RadioListTile(
                value: 3,
                groupValue: selectedRadio,
                title: Text(groupList[2],style: TextStyle(
                    fontSize: 18,
                    color: textColor,
                ),),
                activeColor: icons,
                onChanged: (value){
                  setState(() {
                    index = 2;
                    selectedRadio = value;
                    extend = false;
                    who = false;
                    whoName = false;
                    extendedSelectedRadio = 0;
                  });
                }),
            RadioListTile(
                value: 4,
                groupValue: selectedRadio,
                title: Text(groupList[3],style: TextStyle(
                    fontSize: 18,
                    color: textColor,
                ),),
                activeColor: icons,
                onChanged: (value){
                  setState(() {
                    index = 3;
                    selectedRadio = value;
                    extend = false;
                    who = false;
                    whoName = false;
                    extendedSelectedRadio = 0;
                  });
                }),
            RadioListTile(
                value: 5,
                groupValue: selectedRadio,
                title: Text(groupList[4],style: TextStyle(
                    fontSize: 18,
                    color: textColor,
                ),),
                activeColor: icons,
                onChanged: (value){
                  setState(() {
                    index = 4;
                    selectedRadio = value;
                    extend = true;
                    extendedSelectedRadio = 0;
                  });
                }),
            extend == false ? Container() :
                extendedRadio(),
            who ? Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.symmetric(horizontal: 25,vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: buttons,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      Icon(Icons.info,color: textColor,size: 20,),
                      SizedBox(width: 10,),
                      Text('Tag them in your diary',style: TextStyle(fontSize: 16,color: textColor),),
                    ],
                  ),
                ),
            )
                : SizedBox(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18,vertical: 10),
              child: Material(
                borderRadius: BorderRadius.circular(10.0),
                color: buttons,
                elevation: 2,
                child: MaterialButton(
                  minWidth: MediaQuery.of(context).size.width,
                  onPressed: () async{
                    if(index == 4) {
                        widget.userProvider.setPostCategory(groupList[index]);
                        widget.userProvider.setWillCategory(groupList[extendIndex]);
                    }else if(index == 3){
                      if(widget.userProvider.getUser.secretsPassword.isEmpty) {
                        await showDialog(context: context, builder: (_) {
                          return new BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Dialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                                backgroundColor: buttons,
                                child: PasswordSheet(youMeProvider: widget.userProvider,)),
                          );
                        }).then((value) {
                          if (value == 'done') {
                            widget.userProvider.setPostCategory(groupList[index]);
                            Navigator.pop(context);
                          }else{
                            Utils.showToast('You did\'nt set any password!');
                          }
                        });
                      }else{
                        widget.userProvider.setPostCategory(groupList[index]);
                        Navigator.pop(context);
                      }
                    }else{
                      widget.userProvider.setPostCategory(groupList[index]);
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Submit',style: TextStyle(fontSize: 18,color: textColor),),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget extendedRadio(){
    return  Container(
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 30,vertical: 0),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: buttons,
        borderRadius: BorderRadius.all(Radius.circular(13)),
      ),
        child: Column(
          children: [
            RadioListTile(
                value: 1,
                groupValue: extendedSelectedRadio,
                title:  Text(groupList[0],
                  style: TextStyle(
                  fontSize: 18,
                  color: textColor,
                ),),
                activeColor: icons,
                onChanged: (value){
                  setState(() {
                    extendIndex = 0;
                    extendedSelectedRadio = value;
                    who = false;
                    whoName = false;
                  });
                }),
            RadioListTile(
                value: 2,
                groupValue: extendedSelectedRadio,
                title:  Text(groupList[1],style: TextStyle(
                  fontSize: 18,
                  color: textColor,
                ),),
                activeColor: icons,
                onChanged: (value){
                  setState(() {
                    extendIndex = 1;
                    extendedSelectedRadio = value;
                    who = false;
                    whoName = false;
                  });
                }),
            RadioListTile(
                value: 3,
                groupValue: extendedSelectedRadio,
                title:  Text(groupList[2],style: TextStyle(
                  fontSize: 18,
                  color: textColor,
                ),),
                activeColor: icons,
                onChanged: (value){
                  setState(() {
                    extendIndex = 2;
                    extendedSelectedRadio = value;
                    who = false;
                    whoName = false;
                  });
                }),
            RadioListTile(
                value: 4,
                groupValue: extendedSelectedRadio,
                title:  Text('Specific account',style: TextStyle(
                  fontSize: 18,
                  color: textColor,
                ),),
                activeColor: icons,
                onChanged: (value){
                  setState(() {
                    extendIndex = 4;
                    extendedSelectedRadio = value;
                    who = true;
                  });
                }),
          ],
        ),
    );
  }
}
