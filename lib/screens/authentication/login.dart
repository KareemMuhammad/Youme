import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:umee/repositories/user_provider.dart';
import 'package:umee/screens/authentication/setup_profile.dart';
import '../../utils/shared.dart';

class YouMeLogin extends StatelessWidget {
  final googleUser = GoogleSignIn();
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      backgroundColor: bar,
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 30,),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Image.asset('assets/splash.png',height: 200,width: 200,),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('YOUME',style: TextStyle(color: textColor,fontSize: 40,fontWeight: FontWeight.bold),),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('YOUME is a social app lets you share your different memories with your friends',
                style: TextStyle(color: Colors.white70,fontSize: 17,),textAlign: TextAlign.center,),
            ),
            SizedBox(height: 25,),
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
                  onPressed: () {
                    Navigator.pushNamed(context, signInRoute);
                  },
                  child: Text('Sign In',style: TextStyle(fontSize: 18,color: textColor),),
                ),
              ),
            ),
            SizedBox(height: 20,),
            Row(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: ()async{
                    userProvider.refreshLoading();
                    final user = await googleUser.signIn();
                    if(user != null){
                      final auth = await user.authentication;
                      final credential = GoogleAuthProvider.credential(
                          accessToken: auth.accessToken,
                          idToken: auth.idToken
                      );
                      bool newUser = await userProvider.signUpGoogle(credential,user.email,user.displayName);
                      if(newUser){
                        userProvider.refreshLoading();
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SetupProfile(showName: true,)));
                      }else{
                        userProvider.refreshLoading();
                        userProvider.getCurrentUser();
                      }
                    }else{
                      userProvider.refreshLoading();
                    }
                  },
                    child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        elevation: 2,
                        color: bar,
                        child: Image.asset('assets/google.png',height: 50,width: 50,))
                ),
                SizedBox(width: 30,),
                InkWell(
                    onTap: ()async{
                      userProvider.refreshLoading();
                      final LoginResult result = await FacebookAuth.instance.login(permissions: ['email', 'public_profile', 'user_birthday', 'user_gender',],);
                      if(result.status == LoginStatus.success) {
                        final OAuthCredential credential = FacebookAuthProvider.credential(result.accessToken.token);
                        final Map<String,dynamic> userData = await FacebookAuth.i.getUserData(
                          fields: "name,email,birthday,gender",
                        );
                      bool newUser = await userProvider.signUpFacebook(credential,userData);
                        if(newUser){
                          userProvider.refreshLoading();
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SetupProfile(showName: true,)));
                        }else {
                          userProvider.refreshLoading();
                          userProvider.getCurrentUser();
                        }
                      }else{
                        userProvider.refreshLoading();
                      }
                    },
                    child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        elevation: 2,
                        color: bar,
                        child: Image.asset('assets/facebook.png',height: 50,width: 50,))
                ),
              ],
            ),
            SizedBox(height: 20,),
            InkWell(
                onTap: (){
                  Navigator.pushNamed(context, signUpRoute);
                },
                child: Text('Create New Account',style: TextStyle(color: textColor,fontSize: 18,),)
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

}
