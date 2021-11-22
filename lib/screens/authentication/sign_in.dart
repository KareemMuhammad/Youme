import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:umee/repositories/user_provider.dart';
import '../../utils/shared.dart';
import 'package:umee/widgets/widgets.dart';

class SignInYOUME extends StatefulWidget {
  @override
  _SignInYOUMEState createState() => _SignInYOUMEState();
}

class _SignInYOUMEState extends State<SignInYOUME> {
   TextEditingController emailController = new TextEditingController();

   TextEditingController passwordController = new TextEditingController();

  final formKey = GlobalKey<FormState>();

  String userNotFound = '';

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    return  Scaffold(
        backgroundColor: bar,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: bar,
          title: Text('Sign In',style: TextStyle(fontSize: 19,color: textColor),),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20,),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text('Type in your email and password you chose for Youme and go to feed'
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
                                return val.isEmpty || val.length < 6 ? 'wrong password' : null;
                              },
                            )
                        ),
                      ),
                    ),
                  ],
                )
              ),
              SizedBox(height: 5,),
              Text(userNotFound, style: TextStyle(color: Colors.red[700], fontSize: 17.0),),
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
                        bool newUser = await userProvider.signInEmailAndPassword(emailController.text, passwordController.text);
                        if(newUser){
                          userProvider.refreshLoading();
                          setState(() {
                            userNotFound = 'either password or email is not correct!';
                          });
                        }else{
                          userProvider.refreshLoading();
                          await userProvider.getCurrentUser();
                          Navigator.pushReplacementNamed(context, wrapper);
                          FirebaseMessaging.instance.getToken().then((token) {
                            userProvider.updateToken(token);
                          });
                        }
                      }
                    },
                    child: Text('Go To Feed',style: TextStyle(fontSize: 18,color: textColor),),
                  ),
                ),
              ),
              SizedBox(height: 15,),
              GestureDetector(
                onTap: (){
                  Navigator.pushNamed(context, forgetPasswordRoute);
                },
                  child: Text('Can\'t Sign In? Reset Password',style: TextStyle(color: textColor,fontSize: 17,),)
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
  }

}
