import 'package:flutter/material.dart';
import 'package:umee/screens/authentication/reset_password.dart';
import 'package:umee/screens/authentication/setup_profile.dart';
import 'package:umee/screens/authentication/sign_in.dart';
import 'package:umee/screens/authentication/sign_up.dart';
import 'package:umee/screens/edit_profile.dart';
import 'package:umee/screens/post.dart';
import 'package:umee/screens/post_advices_screen.dart';
import 'package:umee/screens/profile.dart';
import 'package:umee/screens/recording.dart';
import 'package:umee/screens/reminder.dart';
import 'package:umee/screens/settings.dart';
import 'package:umee/screens/splash.dart';
import 'package:umee/wrapper.dart';
import 'utils/shared.dart';
import 'screens/diary_options.dart';

class MyRouter{
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case signUpRoute:
        return MaterialPageRoute(builder: (_) => SignUpYOUME());
        break;
      case signInRoute:
        return MaterialPageRoute(builder: (_) => SignInYOUME());
        break;
      case setupProfileRoute:
        return MaterialPageRoute(builder: (_) => SetupProfile());
        break;
      case forgetPasswordRoute:
        return MaterialPageRoute(builder: (_) => PasswordReset());
        break;
      case splashRoute:
        return MaterialPageRoute(builder: (_) => SplashScreen());
        break;
      case profileRoute:
        return MaterialPageRoute(builder: (_) => UserProfile());
        break;
      case adviceRoute:
        return MaterialPageRoute(builder: (_) => PostAdvicesScreen());
        break;
      case writeRoute:
        return MaterialPageRoute(builder: (_) => PostNewMemory());
        break;
      case recordRoute:
        return MaterialPageRoute(builder: (_) => RecordMemory());
        break;
      case editProfileRoute:
        return MaterialPageRoute(builder: (_) => EditYouProfile());
        break;
      case memoryOptionsRoute:
        return MaterialPageRoute(builder: (_) => DiaryOptions());
        break;
      case wrapper:
        return MaterialPageRoute(builder: (_) => Wrapper());
        break;
      case settingsRoute:
        return MaterialPageRoute(builder: (_) => MySettings());
        break;
      case reminderRoute:
        return MaterialPageRoute(builder: (_) => MyReminderScreen());
        break;
      default: return MaterialPageRoute(builder: (_) => SplashScreen());
    }
  }
}
