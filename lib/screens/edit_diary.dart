import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:umee/models/diaries_model.dart';
import 'package:umee/repositories/diary_provider.dart';
import 'package:umee/repositories/user_provider.dart';
import 'package:umee/utils/constants.dart';
import 'package:umee/utils/shared.dart';
import 'package:umee/widgets/widgets.dart';

class EditDiaryScreen extends StatefulWidget {
  final Diaries diary;

  const EditDiaryScreen({Key key, this.diary}) : super(key: key);

  @override
  _EditDiaryScreenState createState() => _EditDiaryScreenState();
}

class _EditDiaryScreenState extends State<EditDiaryScreen> {
  final formKey = GlobalKey<FormState>();
  String text = '';

  @override
  Widget build(BuildContext context) {
    final DiaryProvider diaryProvider = Provider.of<DiaryProvider>(context);
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: bar,
        title: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text('Edit Diary',style: TextStyle(
              fontSize: 19,
              color: textColor
          ),),
        ),
        actions: [
          InkWell(
            onTap: (){
              if(text.isNotEmpty){
                diaryProvider.updateDiary(text, widget.diary.id,userProvider.getUser);
                diaryProvider.updateDiaryOfFollow(text, widget.diary.id,userProvider.getUser);
                diaryProvider.updateContentOfUserDiary(widget.diary, text);
                Navigator.pop(context);
              }else{
                Utils.showToast('You did\'nt make any change!');
              }
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0,15,10,10),
              child: Text('Save',style: TextStyle(
                  fontSize: 18,
                  color: textColor
              ),),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 30,),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ClipRect(
                child: Form(
                  child: TextFormField(
                    textAlign: Utils.isDirectionRTL(context) ? TextAlign.end : TextAlign.start,
                    style: textStyle(),
                    autofocus: false,
                    maxLength: 100,
                    maxLines: 5,
                    initialValue: widget.diary.content,
                    onChanged: (val){
                      setState(() {
                        text = val;
                      });
                    },
                    decoration: textInputDecoration(''),
                    validator: (val) {
                      return val.isEmpty ? 'diary can\'t be empty ': null;
                    },
                  ),
                  key: formKey,
                ),
              ),
            ),
            SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                width: 300,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: buttons),
                ),
                child: Center(
                  child: Text('Other contents will be added after editing',style: TextStyle(
                      fontSize: 17,
                      color: textColor
                  ),textAlign: TextAlign.center,),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
