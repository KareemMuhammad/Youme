import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/shared.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    new Future.delayed(
        const Duration(seconds: 2),
            () =>  Navigator.pushReplacementNamed(context, wrapper)
    );
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Center(
      child: Container(
        color: background,
        alignment: Alignment.center,
        child: Column(mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset("assets/splash.png",height: size.height * 0.7,width: size.width * 0.7,),
          ],
        ),
      ),
    );
  }
}
