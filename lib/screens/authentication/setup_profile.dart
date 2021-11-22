import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:umee/models/user_model.dart';
import 'package:umee/repositories/user_provider.dart';
import '../../utils/shared.dart';
import 'package:umee/widgets/widgets.dart';

class SetupProfile extends StatefulWidget {
  final bool showName;

  const SetupProfile({Key key, this.showName}) : super(key: key);
  @override
  _SetupProfileState createState() => _SetupProfileState();
}

class _SetupProfileState extends State<SetupProfile> {
  TextEditingController nameController = new TextEditingController();
  TextEditingController addressController = new TextEditingController();
  TextEditingController aboutController = new TextEditingController();

  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String date = '';
  int selectedRadio = 0;
  int index = 0;
  final List<String> groupList = ['Male', 'Female','Other'];

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      backgroundColor: bar,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: bar,
        title: Text('Setup Profile',style: TextStyle(fontSize: 19,color: textColor),),
        actions: [
          InkWell(
            onTap: ()async{
            await FirebaseMessaging.instance.getToken().then((token) {
                userProvider.updateToken(token);
              });
              userProvider.getCurrentUser();
              Navigator.pushReplacementNamed(context, wrapper);
            },
            child: Container(
              alignment: Alignment.topRight,
              padding: EdgeInsets.all(10),
              child: Text('Later',style: TextStyle(fontSize: 19,color: textColor),),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text('Hey! we need few details from you before you start sharing on YOUME'
                ,style: TextStyle(color: textColor,fontSize: 17,),textAlign: TextAlign.center,),
            ),
            SizedBox(height: 40,),
            Form(
                key: formKey,
                child: Column(
                  children: [
                  !widget.showName ?  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18,vertical: 10),
                      child: Material(
                        borderRadius: BorderRadius.circular(10.0),
                        color: buttons,
                        elevation: 2,
                        child: MaterialButton(
                            minWidth: MediaQuery.of(context).size.width,
                            onPressed: () {

                            },
                            child: TextFormField(
                              style: TextStyle(color: textColor,fontSize: 18,),
                              decoration: textInputDecorationSignUp('Full Name'),
                              controller: nameController,
                              validator: (val) {
                                return val.isEmpty ? 'please write your name' : null;
                              },
                            )
                        ),
                      ),
                    ) : Container(),
                    Padding(
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
                                  date = value.toString().split(' ')[0] ?? '';
                                });
                                });
                            },
                            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('$date',
                                  style: TextStyle(color: textColor,fontSize: 17,),
                                ),
                                Icon(Icons.date_range,size: 25,color: grey,),
                              ],
                            )
                        ),
                      ),
                    ),
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
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18,vertical: 10),
                      child: Material(
                        borderRadius: BorderRadius.circular(10.0),
                        color: buttons,
                        elevation: 2,
                        child: MaterialButton(
                            minWidth: MediaQuery.of(context).size.width,
                            onPressed: () {

                            },
                            child: TextFormField(
                              style: TextStyle(color: textColor,fontSize: 18,),
                              decoration: textInputDecorationSignUp('Address'),
                              controller: addressController,
                              validator: (val) {
                                return val.isEmpty ? 'please write your address' : null;
                              },
                            )
                        ),
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18,vertical: 10),
                      child: Material(
                        borderRadius: BorderRadius.circular(10.0),
                        color: buttons,
                        elevation: 2,
                        child: MaterialButton(
                            minWidth: MediaQuery.of(context).size.width,
                            onPressed: () {

                            },
                            child: TextFormField(
                              style: TextStyle(color: textColor,fontSize: 18,),
                              decoration: textInputDecorationSignUp('About'),
                              controller: aboutController,
                              maxLength: 100,
                              validator: (val) {
                                return val.isEmpty || val.length < 2 ? 'please tell us more about yourself' : null;
                              },
                            )
                        ),
                      ),
                    ),
                  ],
                )
            ),
            SizedBox(height: 15,),
            userProvider.isLoading ? buildLoadingUi() : Container(),
            SizedBox(height: 25,),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18,vertical: 1),
              child: Material(
                borderRadius: BorderRadius.circular(10.0),
                color: icons,
                elevation: 2,
                child: MaterialButton(
                  minWidth: MediaQuery.of(context).size.width,
                  onPressed: () async{
                   if(formKey.currentState.validate() && date.isNotEmpty){
                     userProvider.refreshLoading();
                    await FirebaseMessaging.instance.getToken().then((token) {
                       userProvider.updateToken(token);
                     });
                     if(!widget.showName) {
                       YouMeUser youMe = YouMeUser.create(
                           name: nameController.text,
                           gender: groupList[index],
                           birthday: date,
                           location: addressController.text,
                           about: aboutController.text);
                       userProvider.updateUserProfile(youMe);
                       userProvider.refreshLoading();
                       userProvider.getCurrentUser();
                       Navigator.pushReplacementNamed(context, wrapper);
                     }else{
                       YouMeUser youMe = YouMeUser.create(
                           name: userProvider.getUser.name,
                           gender: groupList[index],
                           birthday: date,
                           location: addressController.text,
                           about: aboutController.text);
                       userProvider.updateUserProfile(youMe);
                       userProvider.refreshLoading();
                       userProvider.getCurrentUser();
                       Navigator.pushReplacementNamed(context, wrapper);
                     }
                   }
                  },
                  child: Text('Set Go!',style: TextStyle(fontSize: 18,color: textColor),),
                ),
              ),
            ),
            SizedBox(height: 10,),
          ],
        ),
      ),
    );
  }
  Widget buildLoadingUi() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    aboutController.dispose();
    addressController.dispose();
  }
}
