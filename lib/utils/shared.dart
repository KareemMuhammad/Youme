import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SizeConfig {
  static MediaQueryData _mediaQueryData;
  static double screenWidth;
  static double screenHeight;
  static double blockSizeHorizontal;
  static double blockSizeVertical;
  static double _safeAreaHorizontal;
  static double _safeAreaVertical;
  static double safeBlockHorizontal;
  static double safeBlockVertical;

  void init(BuildContext context){
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth/100;
    blockSizeVertical = screenHeight/100;
    _safeAreaHorizontal = _mediaQueryData.padding.left +
        _mediaQueryData.padding.right;
    _safeAreaVertical = _mediaQueryData.padding.top +
        _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - _safeAreaHorizontal)/100;
    safeBlockVertical = (screenHeight - _safeAreaVertical)/100;
  }
}
const Color textColor = Colors.white;
const Color black = Colors.black;
const  red = Colors.red;
Color grey = Colors.grey;
Color background = HexColor('#212121');
Color bar = HexColor('#212121');
Color icons = HexColor('#559FCA');
Color buttons = HexColor('#000000');
Color float = HexColor('#559FCA');

final GlobalKey<NavigatorState> navigatorKey = GlobalKey(debugLabel: "Main Navigator");

const String USERS_COLLECTION = "Users";
const String DIARIES_COLLECTION = "Diaries";
const String REMINDER_COLLECTION = "Reminders";
const String DIARIES_OF_FOLLOWING_COLLECTION = "Diaries Of Following";
const String REMINDER_HISTORY_COLLECTION = "Reminders History";

const String wrapper = '/wrapper';
const String signUpRoute = '/signUp';
const String signInRoute = '/signIn';
const String setupProfileRoute = '/setupProfile';
const String splashRoute = '/';
const String profileRoute = '/profile';
const String adviceRoute = '/advice';
const String recordRoute = '/recordMemory';
const String writeRoute = '/writeMemory';
const String forgetPasswordRoute = '/forgetPassword';
const String editProfileRoute = '/editProfile';
const String memoryOptionsRoute = '/memoryOptions';
const String settingsRoute = '/settings';
const String reminderRoute = '/reminder';

const String PRIVACY_POLICY = 'https://youme.flycricket.io/privacy.html';
const String TERMS_COND = 'https://youme-0.flycricket.io/terms.html';

PackageInfo packageInfo;
var connectivityResult;

