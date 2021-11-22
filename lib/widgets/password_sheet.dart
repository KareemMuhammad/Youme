import 'package:flutter/material.dart';
import 'package:umee/repositories/user_provider.dart';
import 'package:umee/widgets/widgets.dart';
import '../utils/shared.dart';


class PasswordSheet extends StatefulWidget{
  final UserProvider youMeProvider;

  const PasswordSheet({Key key, this.youMeProvider}) : super(key: key);

  @override
  _PasswordSheetState createState() => _PasswordSheetState();
}

class _PasswordSheetState extends State<PasswordSheet> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController textController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      color: background,
      padding: EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height - SizeConfig.screenHeight * 0.6,
      child: Column(crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Set a password to your diaries',style: TextStyle(color: textColor,fontSize: 17,),),
                SizedBox(width: 5,),
                iconStyle(Icons.lock),
              ],
            ),
          ),
          Form(
            child: TextFormField(
              obscureText: true,
              style: textStyle(),
              decoration: textInputDecoration2('password'),
              controller: textController,
              validator: (val) {
                return val.isEmpty ? 'password can\'t be empty ': null;
              },
            ),
            key: formKey,
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('By set a password to a diary no one will be able to view it unless they have it\'s password',
                style: TextStyle(color: textColor,fontSize: 16,),),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: RaisedButton(
              color: buttons,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              elevation: 2,
              onPressed: () {
                if(formKey.currentState.validate()) {
                  widget.youMeProvider.updateUserSecretsPass(textController.text);
                  Navigator.pop(context, 'done');
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text('Set',style: TextStyle(letterSpacing: 1,fontSize: 16,color: textColor),),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget iconStyle(IconData icon){
    return Icon(icon,size: 23,color: textColor,);
  }
}