import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:umee/repositories/diary_provider.dart';
import 'package:umee/repositories/notification_services.dart';
import 'package:umee/repositories/user_provider.dart';
import 'package:umee/screens/authentication/login.dart';
import 'package:umee/screens/home.dart';

class Wrapper extends StatelessWidget {

  final PageController myPage = PageController(initialPage: 0);

  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final DiaryProvider diaryProvider = Provider.of<DiaryProvider>(context);
    final PushNotificationServices fcm = PushNotificationServices(auth: _auth,userProvider: userProvider,
        messaging: FirebaseMessaging.instance,diaryProvider: diaryProvider);
    if (userProvider.getFireUser == null){
      return YouMeLogin();
    } else {
       if(userProvider.myState == HomeState.WAITING){
         userProvider.setLoadState(HomeState.LOADED);
         userProvider.refreshUser();
         userProvider.refreshAllUsers();
         fcm.initiate();
         DateTime currentPhoneDate = DateTime.now();
         String dateFormat = DateFormat('yyyy-MM-dd').format(currentPhoneDate);
         userProvider.updateUserLastActive(dateFormat);
       }
      return MyMainPage(myPage: myPage,userProvider: userProvider,);
    }
  }

}
