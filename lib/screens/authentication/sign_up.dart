import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:umee/repositories/user_provider.dart';
import 'package:umee/screens/authentication/setup_profile.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/shared.dart';
import 'package:umee/widgets/widgets.dart';

class SignUpYOUME extends StatefulWidget {
  @override
  _SignUpYOUMEState createState() => _SignUpYOUMEState();
}

class _SignUpYOUMEState extends State<SignUpYOUME> {
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  TextEditingController confirmPasswordController = new TextEditingController();
  final formKey = GlobalKey<FormState>();
  String userNotFound = '';
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      backgroundColor: bar,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: bar,
        title: Text('Sign Up',style: TextStyle(fontSize: 19,color: textColor),),
      ),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text('Fill in all the fields and proceed'
                ,style: TextStyle(color: textColor,fontSize: 17,),textAlign: TextAlign.center,),
            ),
            SizedBox(height: 40,),
            Form(
                key: formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18,vertical: 10),
                      child: Material(
                        borderRadius: BorderRadius.circular(10.0),
                        color: textColor,
                        elevation: 2,
                        child: MaterialButton(
                            minWidth: MediaQuery.of(context).size.width,
                            onPressed: () {

                            },
                            child: TextFormField(
                              style: TextStyle(color: black,fontSize: 18,),
                              decoration: textInputDecorationSign('Email',Icons.email),
                              controller: emailController,
                              validator: (val){
                                return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(val)
                                    ? null : 'please enter a valid email';
                              },
                            )
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18,vertical: 10),
                      child: Material(
                        borderRadius: BorderRadius.circular(10.0),
                        color: textColor,
                        elevation: 2,
                        child: MaterialButton(
                            minWidth: MediaQuery.of(context).size.width,
                            onPressed: () {

                            },
                            child: TextFormField(
                              style: TextStyle(color: black,fontSize: 18,),
                              decoration: textInputDecorationSign('Password',Icons.lock),
                              controller: passwordController,
                              obscureText: true,
                              validator: (val) {
                                return val.isEmpty || val.length < 6 ? 'weak password' : null;
                              },
                            )
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18,vertical: 10),
                      child: Material(
                        borderRadius: BorderRadius.circular(10.0),
                        color: textColor,
                        elevation: 2,
                        child: MaterialButton(
                            minWidth: MediaQuery.of(context).size.width,
                            onPressed: () {

                            },
                            child: TextFormField(
                              style: TextStyle(color: black,fontSize: 18,),
                              obscureText: true,
                              decoration: textInputDecorationSign('Confirm Password',Icons.lock_open),
                              controller: confirmPasswordController,
                              validator: (val){
                                return val.isEmpty || val != passwordController.text ? 'password didn\'t match' : null;
                              },
                            )
                        ),
                      ),
                    ),
                  ],
                )
            ),
            SizedBox(height: 5,),
            Text(
              userNotFound,
              style: TextStyle(color: Colors.red[700], fontSize: 15.0),
            ),
            SizedBox(height: 20,),
            Row(
              children: [
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RichText(textAlign: TextAlign.center,
                      text: TextSpan(
                          children: [
                            TextSpan(
                                text: 'By creating account you automatically accepting all ',
                                style: TextStyle(color: textColor,fontSize: 18)
                            ),
                            TextSpan(
                                text: 'the terms and conditions ',
                                style: TextStyle(color: icons,fontSize: 18),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () async{
                                    await launch(TERMS_COND);
                                  }),
                            TextSpan(
                                text: 'of YOUME ',
                                style: TextStyle(color: textColor,fontSize: 18)
                            ),
                          ]),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 40,),
            userProvider.isLoading ? buildLoadingUi() : Container(),
            SizedBox(height: 10,),
         Padding(
          padding: EdgeInsets.symmetric(horizontal: 18,vertical: 1),
          child: Material(
            borderRadius: BorderRadius.circular(10.0),
            color: buttons,
            elevation: 2,
            child: MaterialButton(
              minWidth: MediaQuery.of(context).size.width,
              onPressed: () async{
                if(formKey.currentState.validate()) {
                  userProvider.refreshLoading();
                  bool newUser = await userProvider.signUpUserWithEmailPass(
                      emailController.text, passwordController.text);
                  if (newUser == true) {
                    userProvider.refreshLoading();
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SetupProfile(showName: false,)));
                  } else {
                    userProvider.refreshLoading();
                    setState(() {
                      userNotFound = 'this email is already existed!';
                    });
                  }
                }
              },
              child: Text('Proceed',style: TextStyle(fontSize: 18,color: textColor),),
            ),
          ),
         ),
          ],
        ),
      ),
    );
  }

  Widget buildLoadingUi() {
    return Center(
      child: CircularProgressIndicator(backgroundColor: icons,),
    );
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }

}
