import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:umee/repositories/user_provider.dart';
import '../../utils/shared.dart';
import 'package:umee/widgets/widgets.dart';

class PasswordReset extends StatefulWidget {
  @override
  _PasswordResetState createState() => _PasswordResetState();
}

class _PasswordResetState extends State<PasswordReset> {
  TextEditingController emailController = new TextEditingController();
  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: bar,
        title: Text('Password Reset',style: TextStyle(fontSize: 19,color: textColor),),
      ),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Text('No problem! just give in your email and we will send you a link to reset your password'
                ,style: TextStyle(color: textColor,fontSize: 17,),textAlign: TextAlign.center,),
            ),
            SizedBox(height: 40,),
            Form(
                key: formKey,
                child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18,vertical: 1),
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
            ),
            SizedBox(height: 40,),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18,vertical: 1),
              child: Material(
                borderRadius: BorderRadius.circular(10.0),
                color: buttons,
                elevation: 2,
                child: MaterialButton(
                  minWidth: MediaQuery.of(context).size.width,
                  onPressed: () {
                    if(formKey.currentState.validate()) {
                      userProvider.resetPassword(emailController.text);
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Send Link',style: TextStyle(fontSize: 18,color: textColor),),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
