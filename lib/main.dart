import 'package:camera/camera.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:umee/models/reminder_model.dart';
import 'package:umee/models/notification_model.dart';
import 'package:umee/models/user_model.dart';
import 'package:umee/repositories/diary_provider.dart';
import 'package:umee/repositories/user_provider.dart';
import 'package:umee/repositories/user_repository.dart';
import 'package:umee/screens/splash.dart';
import 'package:umee/utils/constants.dart';
import 'package:uuid/uuid.dart';
import 'package:workmanager/workmanager.dart';
import 'utils/shared.dart';
import 'package:umee/you_routes.dart';

List<CameraDescription> cameras = [];
final _auth = FirebaseAuth.instance;
 UserRepository _userRepository = UserRepository();

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async{
    await Firebase.initializeApp();
    switch(task){
      case Utils.DIARY_TASK:
        {
          print(task);
          await Workmanager().cancelByUniqueName(inputData[Utils.UNIQUE_ID]);
        }
        break;
      case Utils.REMINDER_TASK:
        {
          print(task);
          List<ReminderModel> list = await _userRepository.getAllReminders();
          List<String> registers = [];
          for(ReminderModel model in list) {
            String notifyDate = Utils.currentDate();
            DateTime from = DateTime.parse('${model.date} ${model.time}');
            DateTime to = DateTime.now();
            int difference = Utils.daysBetween(from, to);
            if (inputData[Utils.SERVICE_USER_ID] == model.hostId){
              if (difference >= 0) {
                await _userRepository.saveReminderToHistory(model.toMap(), model.id);
                YouMeUser host = await _userRepository.getUserById(model.hostId);
                registers.add(host.token);
                model.taggedList.forEach((tag) {
                  registers.add(tag.userToken);
                });
                String uuid = Uuid().v4();
                await Utils.sendPostPushMessage(
                    'Your ${model.title} reminder is happening now!',
                    'YOUME',
                    Utils.REMINDER_TAGS_SECTION,
                    registers,
                    '$notifyDate',
                    Utils.APP_ICON,
                    uuid,
                    model.hostId);
                await _userRepository.deleteReminderFromDb(model.id);
                registers.clear();
                await Workmanager().cancelByUniqueName(inputData[Utils.UNIQUE_ID]);
              }
            }
          }
        }
        break;
      default: print(task);
    }
    return Future.value(true);
  });
}

Future firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if(_auth.currentUser != null) {
    User user = _auth.currentUser;
    NotificationModel model = NotificationModel(title: message.data[NotificationModel.TITLE],body: message.data[NotificationModel.BODY],
        icon: message.data[NotificationModel.ICON],time: message.data[NotificationModel.TIME],
        userId: message.data[NotificationModel.USER_ID],route: message.data[NotificationModel.ROUTE],diaryId: message.data[NotificationModel.DIARY_ID]);
   await _userRepository.saveNotificationToUserDb(model,user.uid);
    print("Handling a background message: ${message.messageId}");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  connectivityResult = await (Connectivity().checkConnectivity());
  packageInfo = await PackageInfo.fromPlatform();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false
  );

  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
        ChangeNotifierProvider(create: (_) => UserProvider(FirebaseAuth.instance.currentUser)),
        ChangeNotifierProvider(create: (_) => DiaryProvider()),
    ],
    child: MaterialApp(
      navigatorKey: navigatorKey,
      onGenerateRoute: MyRouter.generateRoute,
      initialRoute: splashRoute,
      supportedLocales: [
        const Locale('en', ''),
        const Locale('ar', ''),
      ],
      localizationsDelegates: [
        CustomLocalizationDelegate(),
      ],
      theme: ThemeData(
          hintColor: textColor,
          errorColor: textColor,
          primaryColor: bar,
          accentColor: background,
          canvasColor: background,
          backgroundColor: background,
          appBarTheme: AppBarTheme(
            color: bar,
          ),
          splashColor: background,
          textTheme: TextTheme(
            headline6: TextStyle(color: textColor),
            overline: TextStyle(color: textColor),
            caption: TextStyle(color: textColor),
          ),
          colorScheme: ColorScheme.light(primary: textColor),
          buttonTheme: ButtonThemeData(
            buttonColor: buttons,
            textTheme: ButtonTextTheme.primary,
          )
      ),
      home: SplashScreen(),
    ),
    );
  }
}


class CustomLocalizationDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  const CustomLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'en';

  @override
  Future<MaterialLocalizations> load(Locale locale) => SynchronousFuture<MaterialLocalizations>(const CustomLocalization());

  @override
  bool shouldReload(CustomLocalizationDelegate old) => false;

  @override
  String toString() => 'CustomLocalization.delegate(en_US)';
}

class CustomLocalization extends DefaultMaterialLocalizations {
  const CustomLocalization();

  @override
  String get searchFieldLabel => "Search for..";
}

class FirstDisabledFocusNode extends FocusNode {
  @override
  bool consumeKeyboardToken() {
    return false;
  }
}


