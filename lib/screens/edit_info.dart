import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:umee/repositories/diary_provider.dart';
import 'package:umee/repositories/user_provider.dart';
import 'package:umee/utils/shared.dart';
import 'package:umee/widgets/widgets.dart';

enum WidgetLoad{NAME,EMAIL,BIO,ADDRESS,GENDER,BIRTHDAY}
class EditInfoScreen extends StatefulWidget {
  final int load;
  final String title;

  const EditInfoScreen({Key key, this.load, this.title}) : super(key: key);
  @override
  _EditInfoScreenState createState() => _EditInfoScreenState();
}

class _EditInfoScreenState extends State<EditInfoScreen> {
  TextEditingController aboutController = new TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String dateTest = '';
  String address = 'Location';
  int selectedRadio = 1;
  int index = 0;
  final List<String> groupList = ['Male', 'Female','Other'];
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final diaryProvider = Provider.of<DiaryProvider>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: bar,
        title: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(widget.title,style: TextStyle(
              fontSize: 19,
              color: textColor
          ),),
        ),
      ),
      backgroundColor: background,
      body: Container(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            SizedBox(height: 40,),
            _loadScreen(userProvider),
           SizedBox(height: 20,),
           isLoading ?
           Center(child: RefreshProgressIndicator(backgroundColor: icons,))
           :Padding(
              padding: const EdgeInsets.all(10),
              child: RaisedButton(
                color: icons,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                elevation: 2,
                onPressed: () async{
                  if(formKey.currentState != null) {
                    if (formKey.currentState.validate()) {
                      setState(() {
                        isLoading = true;
                      });
                      performUpdate(widget.load, userProvider,diaryProvider);
                      Navigator.pop(context);
                    }
                  }else{
                    if(dateTest.isNotEmpty){
                      setState(() {
                        isLoading = true;
                      });
                      performUpdate(widget.load, userProvider,diaryProvider);
                      Navigator.pop(context);
                    }
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Save',style: TextStyle(letterSpacing: 1,fontSize: 18,color: textColor),),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _loadScreen(UserProvider userProvider){
    switch(widget.load){
      case 0 :
        return customEditText(userProvider.getUser.name);
        break;
      case 1 :
        return customEditText(userProvider.getUser.email);
        break;
      case 2 :
        return customEditText(userProvider.getUser.about);
        break;
      case 3 :
        return customEditText(userProvider.getUser.location);
        break;
      case 4 :
        return customGroup();
        break;
      case 5 :
        return customDate(userProvider.getUser.birthday);
        break;
      default : return Container();
    }
  }

  Widget customEditText(String text){
    return Form(
      key: formKey,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15,vertical: 10),
        child: Material(
          borderRadius: BorderRadius.circular(10.0),
          color: buttons,
          elevation: 2,
          child: MaterialButton(
              minWidth: MediaQuery.of(context).size.width,
              onPressed: () {

              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  style: TextStyle(color: textColor,fontSize: 18,),
                  decoration: textInputDecorationSignUp(text),
                  controller: aboutController,
                  validator: (val) {
                    return val.isEmpty ? 'please fill the field' : null;
                  },
                ),
              )
          ),
        ),
      ),
    );
  }

  Widget customGroup(){
    return Column(
      children: [
        RadioListTile(
            value: 1,
            groupValue: selectedRadio,
            title:  Text(groupList[0],style: TextStyle(
              fontSize: 18,
              color: textColor,
            ),),
            activeColor: icons,
            onChanged: (value){
              setState(() {
                index = 0;
                selectedRadio = value;
              });
            }),
        RadioListTile(
            value: 2,
            groupValue: selectedRadio,
            title:  Text(groupList[1],style: TextStyle(
              fontSize: 18,
              color: textColor,
            ),),
            activeColor: icons,
            onChanged: (value){
              setState(() {
                index = 1;
                selectedRadio = value;
              });
            }),
        RadioListTile(
            value: 3,
            groupValue: selectedRadio,
            title:  Text(groupList[2],style: TextStyle(
              fontSize: 18,
              color: textColor,
            ),),
            activeColor: icons,
            onChanged: (value){
              setState(() {
                index = 2;
                selectedRadio = value;
              });
            }),
      ],
    );
  }

  Widget customDate(String date){
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18,vertical: 10),
      child: Material(
        borderRadius: BorderRadius.circular(10.0),
        color: buttons,
        elevation: 2,
        child: MaterialButton(
            minWidth: MediaQuery.of(context).size.width,
            onPressed: () async{
              await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1940),
                lastDate: DateTime.now(),
                builder: (BuildContext context, Widget child) {
                  return Theme(
                    data: ThemeData.light().copyWith(
                      primaryColor: bar,
                      accentColor: background,
                      colorScheme: ColorScheme.light(primary: icons),
                      buttonTheme: ButtonThemeData(
                          textTheme: ButtonTextTheme.primary
                      ),
                    ),
                    child: child,
                  );
                },
              ).then((value) {
                setState(() {
                  dateTest = value.toString().split(' ')[0] ?? '';
                });
              });
            },
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(dateTest.isNotEmpty ? '$dateTest' :'$date',
                  style: TextStyle(color: textColor,fontSize: 17,),
                ),
                Icon(Icons.date_range,size: 25,color: grey,),
              ],
            )
        ),
      ),
    );
  }

  void performUpdate(int load,UserProvider userProvider,DiaryProvider diaryProvider){
    switch(load){
      case 0 :
        userProvider.updateName(aboutController.text,diaryProvider);
        break;
      case 1 :
        userProvider.updateUserEmail(aboutController.text);
        break;
      case 2 :
        userProvider.updateAbout(aboutController.text);
        break;
      case 3 :
        userProvider.updateLocation(aboutController.text);
        break;
      case 4 :
        userProvider.updateGender(groupList[index]);
        break;
      case 5 :
        userProvider.updateBirth(dateTest);
        break;
      default : return;
    }
  }
  @override
  void dispose() {
    super.dispose();
    aboutController.dispose();
  }
}
