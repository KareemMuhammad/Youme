import 'package:flutter/material.dart';
import 'package:umee/models/user_model.dart';
import 'package:umee/utils/shared.dart';
import 'package:umee/widgets/widgets.dart';

class SecretsDialog extends StatefulWidget {
  final YouMeUser user;

  const SecretsDialog({Key key, this.user}) : super(key: key);
  @override
  _SecretsDialogState createState() => _SecretsDialogState();
}

class _SecretsDialogState extends State<SecretsDialog> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController textController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      padding: EdgeInsets.all(8),
      alignment: Alignment.center,
      child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: iconStyle(Icons.lock),
            ),
            Flexible(child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Enter ${widget.user.name}\'s secrets password to unlock them',
                style: TextStyle(color: textColor,fontSize: 17,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
            )),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                child: TextFormField(
                  obscureText: true,
                  style: textStyle(),
                  decoration: textInputDecoration2('password'),
                  controller: textController,
                  validator: (val) {
                    return val.isEmpty || val != widget.user.secretsPassword ? 'password not correct!': null;
                  },
                ),
                key: formKey,
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
                    Navigator.pop(context, 'done');
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text('Unlock',style: TextStyle(letterSpacing: 1,fontSize: 16,color: textColor),),
                ),
              ),
            ),
          ],
      ),
    );
  }

  Widget iconStyle(IconData icon){
    return Icon(icon,size: 25,color: textColor,);
  }
}
