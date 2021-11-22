import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:umee/repositories/diary_provider.dart';
import 'package:umee/repositories/user_provider.dart';
import 'package:umee/screens/policy.dart';
import 'package:umee/screens/settings_menu.dart';
import 'package:umee/utils/constants.dart';
import 'package:umee/utils/shared.dart';

class MySettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final DiaryProvider diaryProvider = Provider.of<DiaryProvider>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: bar,
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Settings',style: TextStyle(color: textColor,fontSize: 20),),
        ),
      ),
      backgroundColor: background,
      body: SingleChildScrollView(
        physics: ScrollPhysics(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const  SizedBox(height: 15,),
            InkWell(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsMenu(title: 'General',index: 0,)));
              },
              child: Container(
                padding: const EdgeInsets.all(8.0),
                margin: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: buttons,
                    boxShadow: [
                      BoxShadow(color: textColor,spreadRadius: 1),
                    ]
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('General',style: TextStyle(color: textColor,fontSize: 18),),
                      Icon(Icons.settings,size: 25,color: textColor,)
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15,),
            InkWell(
              onTap: (){

              },
              child: Container(
                padding: const EdgeInsets.all(8.0),
                margin: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: buttons,
                    boxShadow: [
                      BoxShadow(color: textColor,spreadRadius: 1),
                    ]
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Help Center',style: TextStyle(color: textColor,fontSize: 18),),
                      Icon(Icons.help,size: 25,color: textColor,)
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15,),
            InkWell(
              onTap: (){

              },
              child: Container(
                padding: const EdgeInsets.all(8.0),
                margin: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: buttons,
                    boxShadow: [
                      BoxShadow(color: textColor,spreadRadius: 1),
                    ]
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Review',style: TextStyle(color: textColor,fontSize: 18),),
                      Icon(Icons.reviews,size: 25,color: textColor,)
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15,),
            InkWell(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (_) => PrivacyPolicy()));
              },
              child: Container(
                padding: const EdgeInsets.all(8.0),
                margin: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: buttons,
                    boxShadow: [
                      BoxShadow(color: textColor,spreadRadius: 1),
                    ]
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Privacy Policy',style: TextStyle(color: textColor,fontSize: 18),),
                      Icon(Icons.privacy_tip,size: 25,color: textColor,)
                    ],
                  ),
                ),
              ),
            ),
            const  SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Image.asset('assets/splash.png',height: 150,width: 150,),
            ),
            Text(packageInfo.appName ?? '',style: TextStyle(fontSize: 20,color: textColor),),
            const SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('App Version',style: TextStyle(fontSize: 18,color: textColor),),
                  SizedBox(width: 10,),
                  Text(packageInfo.version ?? '',style: TextStyle(fontSize: 18,color: textColor),),
                ],
              ),
            ),
            const SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
              child: Material(
                borderRadius: BorderRadius.circular(10.0),
                color: buttons,
                elevation: 2,
                child: MaterialButton(
                  minWidth: MediaQuery.of(context).size.width,
                  onPressed: () async{
                    await userProvider.signOut().whenComplete(() => Navigator.pop(context));
                    diaryProvider.closeAllStreams();
                  },
                  child: Text('Logout',style: TextStyle(fontSize: 18,color: textColor),),
                ),
              ),
            ),
            const SizedBox(height: 5,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
              child: Material(
                borderRadius: BorderRadius.circular(10.0),
                color: buttons,
                elevation: 2,
                child: MaterialButton(
                  minWidth: MediaQuery.of(context).size.width,
                  onPressed: () async{
                    await showModalBottomSheet(context: context, builder: (context){
                      return Container(
                        height: MediaQuery.of(context).size.height - SizeConfig.screenHeight * 0.7,
                        child: Column(crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child:  Text('Are you sure?\n you want to delete this account!',
                                  style: TextStyle(fontSize: 18,color: textColor),textAlign: TextAlign.center,),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: RaisedButton(
                                  color: buttons,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('Continue',style: TextStyle(
                                        fontSize: 18,
                                        color: textColor
                                    ),),
                                  ),
                                  onPressed: ()async{
                                    await userProvider.deleteUser();
                                    diaryProvider.closeAllStreams();
                                    Utils.showToast('This account has been deleted');
                                    Navigator.pop(context,'done');
                                  }
                              ),
                            ),
                          ],
                        ),
                      );
                    }).then((value)  {
                      if(value == 'done'){
                        Navigator.pop(context,'done');
                      }
                    });
                  },
                  child: Text('Delete Account',style: TextStyle(fontSize: 18,color: textColor),),
                ),
              ),
            ),
            const  SizedBox(height: 10,),
          ],
        ),
      ),
    );
  }
}
