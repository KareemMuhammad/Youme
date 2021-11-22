import 'package:flutter/material.dart';

class MySlide extends MaterialPageRoute{

  MySlide({WidgetBuilder widgetBuilder,RouteSettings routeSettings})
  :super(builder: widgetBuilder,settings: routeSettings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
   Animation<Offset> custom = Tween<Offset>(begin: Offset(0.0,1),end: Offset(0.0,0.0)).animate(animation);
    return SlideTransition(position: custom,child: child,);
  }
}