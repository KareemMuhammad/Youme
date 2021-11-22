import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:umee/models/notification_model.dart';
import 'package:umee/repositories/diary_provider.dart';
import 'package:umee/repositories/user_provider.dart';
import 'package:umee/screens/notifications_screen.dart';
import 'package:umee/utils/constants.dart';
import 'package:umee/utils/shared.dart';

class PushNotificationServices{
  final FirebaseAuth auth;
  final FirebaseMessaging messaging;
  final UserProvider userProvider;
  final DiaryProvider diaryProvider;

  const PushNotificationServices({this.diaryProvider, this.auth, this.messaging, this.userProvider});

  Future initiate() async{
    if(auth.currentUser != null) {
      if(Platform.isIOS){
        NotificationSettings settings = await messaging.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );

        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          print('User granted permission');
        } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
          print('User granted provisional permission');
        } else {
          print('User declined or has not accepted permission');
        }
      }
         if(userProvider.myState == HomeState.WAITING){
          await FirebaseMessaging.instance.getToken().then((token) {
             userProvider.updateToken(token);
           });
         }

      messaging.getInitialMessage().then((message) {
        if(message != null){
          navigatorKey.currentState.push(MaterialPageRoute(builder: (_)
          => YouMeNotifications(screenWidget: true,userProvider: userProvider,diaryProvider: diaryProvider,)));
        }
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('On message listen!');
        RemoteNotification notification = message.notification;
        if (notification != null) {
          Utils.showNotification(message.data["id"], NotificationModel.fromMap(message.data),diaryProvider,userProvider);
          NotificationModel model = NotificationModel(title: message.data[NotificationModel.TITLE],body: message.data[NotificationModel.BODY],
              icon: message.data[NotificationModel.ICON],time: message.data[NotificationModel.TIME],
              userId: message.data[NotificationModel.USER_ID],route: message.data[NotificationModel.ROUTE],diaryId: message.data[NotificationModel.DIARY_ID]);
          userProvider.saveNotification(model);
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('A new onMessageOpenedApp event was published!');
          navigatorKey.currentState.push(MaterialPageRoute(builder: (_)
          => YouMeNotifications(screenWidget: true,userProvider: userProvider,diaryProvider: diaryProvider,)));
      });
    }
  }

}