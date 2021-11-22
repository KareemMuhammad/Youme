import 'package:flutter/material.dart';
import '../utils/shared.dart';

Widget customAppBar(BuildContext context){
  return AppBar(
      iconTheme: IconThemeData(
        color: black, //change your color here
      ),
      backgroundColor: bar,
      elevation: 4,
      centerTitle: true,
    title: Padding(
      padding: EdgeInsets.fromLTRB(2, 2, 6, 2),
      child: Image.asset("assets/splash.png",fit: BoxFit.cover,height: 100,width: 100,),
    ),
  );
}

InputDecoration textInputDecoration(String hintText){
  return InputDecoration(
      hintText: hintText,
    hintStyle: TextStyle(color: textColor,fontSize: 20),
    border: InputBorder.none,
    contentPadding: EdgeInsets.all(8),
  );
}

InputDecoration textInputDecorationSign(String hintText,IconData iconData){
  return InputDecoration(
    hintText: hintText,
    hintStyle: TextStyle(fontSize: 16,color: Colors.grey),
    border: InputBorder.none,
    errorStyle: TextStyle(color: red),
    contentPadding: EdgeInsets.all(8),
    suffixIcon: Icon(iconData,size: 20,),
  );
}

InputDecoration textInputDecorationSignUp(String hintText){
  return InputDecoration(
    hintText: hintText,
    hintStyle: TextStyle(fontSize: 17,color: Colors.white70),
    border: InputBorder.none,
    errorStyle: TextStyle(fontSize: 17,color: Colors.white70),
    contentPadding: EdgeInsets.all(8),
  );
}

InputDecoration textInputDecoration2(String hint) => InputDecoration(
  filled: true,
  contentPadding: EdgeInsets.all(12.0),
  hintText: hint,
  hintStyle: TextStyle(color: textColor,fontSize: 15),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: textColor, width: 2.0),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: textColor, width: 2.0),
  ),
);

TextStyle textStyle(){
  return TextStyle(
      fontSize: 17,
    color: textColor
  );

}


