import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:umee/models/diaries_model.dart';
import 'package:umee/models/notification_model.dart';
import 'package:umee/models/user_model.dart';
import 'package:umee/repositories/diary_provider.dart';
import 'package:umee/repositories/user_provider.dart';
import 'package:umee/screens/others_profile.dart';
import 'package:umee/screens/post_advices_screen.dart';
import 'package:umee/utils/shared.dart';
import 'package:umee/widgets/slide.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart' as intl;

class Utils {
  static const List<String> categories = [MY_DIARIES,MY_ADVICES,MY_SECRETS,MY_WILL];
  static const List<String> othersCategories = ['Diaries','Advices','Info'];
  static const String MY_DIARIES = "My Diaries";
  static const String MY_ADVICES = "My Advices";
  static const String MY_SECRETS = "My Secrets";
  static const String MY_WILL = "My Will";
  static const String WORDS = "words";
  static const String OTHERS = "others";
  static const String PUBLIC = "Public";
  static const String FOLLOWERS = "My Followers";
  static const String ONLY_DIARIES = "My Diaries Only";
  static const String SECRETS = "Hidden";
  static const String WILL = "Publish When I Die To";
  static const String FCM_URL = 'https://fcm.googleapis.com/fcm/send';
  static const String NOTIFICATIONS_SECTION = "notifications";
  static const String REMINDER_TAGS_SECTION = "reminderTags";
  static const String POST_TAGS_SECTION = "postTags";
  static const String DIARY_TAGS_SECTION = "diaryTags";
  static const String OUT = "out";
  static const String IN = "in";
  static const String WAITING = "waiting";
  static const String UNIQUE_ID = "unique_id";
  static const String SERVICE_USER_ID = "user_id";
  static const String REMINDER_TASK = "reminderTask";
  static const String DIARY_TASK = "diaryTask";
  static const String REGEX_PATTERN = r"^[\u0621-\u064A\u0660-\u0669 ]+$";
  static const String APP_ICON = "https://firebasestorage.googleapis.com/v0/b/youme-6e353.appspot.com/o/splash.png?alt=media&token=6911d743-251f-42a0-84ba-17eebc320fdf";
  static const String SERVER_TOKEN = "Your_Token";
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static const String HOME_PREFS_KEY = 'homeListViewOffset';
  static const String PUBLIC_PREFS_KEY = 'publicListViewOffset';
  static const String PROFILE_PREFS_KEY = 'publicListViewOffset';
  static const String ADVICE_PREFS_KEY = 'publicListViewOffset';

  static Future<String> getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final coordinates = new Coordinates(position.latitude, position.longitude);
      var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
      var first = addresses.first;
      print('${first.addressLine}');
      return '${first.addressLine}';
    }catch(e){
      print(e.toString());
      return '';
    }
  }

  static String currentDate(){
    DateTime currentPhoneDate = DateTime.now();
    String dateFormat = DateFormat('yyyy-MM-dd').format(currentPhoneDate);
    String timeFormat = DateFormat('kk:mm:ss').format(currentPhoneDate);
    String format = '$dateFormat $timeFormat';
    return format;
  }

  static showNotification(String id,NotificationModel notificationModel,DiaryProvider diaryProvider,UserProvider userProvider) async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    final IOSInitializationSettings initializationSettingsIOS =
    IOSInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        onDidReceiveLocalNotification: (
            int id,
            String title,
            String body,
            String payload,
            ) async {

        });
    const MacOSInitializationSettings initializationSettingsMacOS =
    MacOSInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMacOS,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String payload) async {
          if (payload != null) {
            switch(notificationModel.route){
              case REMINDER_TAGS_SECTION:
                navigatorKey.currentState.pushNamed(reminderRoute);
                break;
              case DIARY_TAGS_SECTION:
                await diaryProvider.refreshSingleDiary(notificationModel.diaryId);
                navigatorKey.currentState.push(MaterialPageRoute(builder: (_) => PostAdvicesScreen(diary: diaryProvider.diary,)));
                break;
              case POST_TAGS_SECTION:
                await diaryProvider.refreshSingleDiary(notificationModel.diaryId);
                navigatorKey.currentState.push(MaterialPageRoute(builder: (_) => PostAdvicesScreen(diary: diaryProvider.diary,)));
                break;
              case Utils.NOTIFICATIONS_SECTION:
                if(notificationModel.userId == userProvider.getUser.id){
                  navigatorKey.currentState.pushNamed(profileRoute);
                }else{
                  YouMeUser user = await userProvider.getUserOfDiary(notificationModel.userId);
                  Admires admire = Admires.add(userId: user.id,userImage: user.image,
                      userName: user.name,userToken: user.token);
                  navigatorKey.currentState.push(MySlide(widgetBuilder: (_) => OthersProfile(admire: admire,)));
                }
                break;
            }
          }
        });
    var android = AndroidNotificationDetails('$id', notificationModel.route, '${notificationModel.title}',playSound: true,priority: Priority.high);
    var iOS = IOSNotificationDetails(presentSound: true,subtitle: 'YOUME');
    var platform = NotificationDetails(iOS: iOS,android: android);
    var scheduledNotificationDateTime = new DateTime.now().add(Duration(seconds: 1));
    await flutterLocalNotificationsPlugin.schedule(Random().nextInt(1000), '${notificationModel.title}', 'YOUME', scheduledNotificationDateTime, platform);
  }

  static showToast(String text){
    Fluttertoast.showToast(
      msg: "$text",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: icons,
      textColor: textColor,
      fontSize: 16.0,
    );
  }

  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day,from.hour,from.minute,from.second);
    to = DateTime(to.year, to.month, to.day,to.hour,to.minute,to.second);
    return (to.difference(from).inSeconds).round();
  }

  static int dateDifference(String date,String time){
   return DateTime(int.parse(date.split('-')[0]),int.parse(date.split('-')[1],)
        ,int.parse(date.split('-')[2]),int.parse(time.split(':')[0]),
        int.parse(time.split(':')[1]),int.parse(time.split(':')[2])).millisecondsSinceEpoch;
  }

  static bool isDirectionRTL(BuildContext context){
    return intl.Bidi.isRtlLanguage(Localizations.localeOf(context).languageCode);
  }

 static Future<void> sendPushMessage(String token,String title,String body,String route,String userId,String time,String icon,String diaryId) async {
   print('$icon $token $userId');
    if (token == null) {
      print('Unable to send FCM message, no token exists.');
      return;
    }
    try {
      String uuid = Uuid().v4();
      await http.post(
        Uri.parse(FCM_URL),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$SERVER_TOKEN',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              NotificationModel.BODY: '$body',
              NotificationModel.TITLE: '$title',
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              NotificationModel.BODY: '$body',
              NotificationModel.TITLE: '$title',
              'id': '$uuid',
              'status': 'done',
              NotificationModel.ROUTE : '$route',
              NotificationModel.ICON : '$icon',
              NotificationModel.TIME : '$time',
              NotificationModel.USER_ID : '$userId',
              NotificationModel.DIARY_ID : '$diaryId'
            },
            'to': token,
          },
        ),
      );
      print('FCM request for device sent!');
    } catch (e) {
      print(e.toString());
    }
  }

  static Future<void> sendPostPushMessage(String title,String body,String route,List<String> tokens,String time,String icon,String diaryId,String userId) async {
    print('$icon $route $userId');
    if (tokens == null) {
      print('Unable to send FCM message, no token exists.');
      return;
    }
    try {
      String uuid = Uuid().v4();
      await http.post(
        Uri.parse(FCM_URL),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$SERVER_TOKEN',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              NotificationModel.BODY: '$body',
              NotificationModel.TITLE: '$title',
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '$uuid',
              'status': 'done',
              NotificationModel.BODY: '$body',
              NotificationModel.TITLE: '$title',
              NotificationModel.ROUTE : '$route',
              NotificationModel.ICON : '$icon',
              NotificationModel.TIME : '$time',
              NotificationModel.USER_ID : '$userId',
              NotificationModel.DIARY_ID : '$diaryId'
            },
            'registration_ids': tokens,
          },
        ),
      );
      print('FCM request for device sent!');
    } catch (e) {
      print(e.toString());
    }
  }

}
