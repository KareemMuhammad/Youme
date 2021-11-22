import 'package:flutter/material.dart';
import 'package:umee/repositories/user_provider.dart';
import 'package:umee/utils/shared.dart';

class PublishDialog extends StatefulWidget {
  final int initialRadio;
  final UserProvider userProvider;

  const PublishDialog({Key key, this.initialRadio, this.userProvider}) : super(key: key);
  @override
  _PublishDialogState createState() => _PublishDialogState();
}

class _PublishDialogState extends State<PublishDialog> {
  int selectedRadio;
  String currentGroup = '';
  @override
  void initState() {
    super.initState();
    selectedRadio = widget.initialRadio;
  }

  final List<String> groupList = ['6 months','5 months','4 months','3 months','2 months','1 month'];
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      backgroundColor: background,
      child: Container(
        height: 400,
        child: Column(
          children: [
            radioWidget(1,groupList[0]),
            radioWidget(2,groupList[1]),
            radioWidget(3,groupList[2]),
            radioWidget(4,groupList[3]),
            radioWidget(5,groupList[4]),
            radioWidget(6,groupList[5]),
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FlatButton(onPressed: () {
                    widget.userProvider.setPublishTime(currentGroup);
                    widget.userProvider.setPublishRadio(selectedRadio);
                    Navigator.pop(context);
                  },
                    child: Text('Done',style: TextStyle(color: icons,fontSize: 18),),
                  ),
                  FlatButton(onPressed: () {
                    Navigator.pop(context);
                  },
                    child: Text('Cancel',style: TextStyle(color: icons,fontSize: 18),),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget radioWidget(int index,String group){
    return RadioListTile(
        value: index,
        groupValue: selectedRadio,
        title: Text(group,style: TextStyle(
          fontSize: 18,
          color: textColor,
        ),),
        activeColor: icons,
        onChanged: (value){
          print(value);
          setState(() {
            selectedRadio = value;
            currentGroup = group;
          });
        });
  }
}
