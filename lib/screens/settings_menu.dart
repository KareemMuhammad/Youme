import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:umee/repositories/user_provider.dart';
import 'package:umee/utils/shared.dart';
import 'package:umee/widgets/password_sheet.dart';
import 'package:umee/widgets/publish_dialog.dart';

class SettingsMenu extends StatefulWidget {
  final String title;
  final int index;

  const SettingsMenu({Key key, this.title, this.index,}) : super(key: key);

  @override
  _SettingsMenuState createState() => _SettingsMenuState();
}

class _SettingsMenuState extends State<SettingsMenu> {
  bool isSwitched = false;

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: bar,
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('${widget.title}',style: TextStyle(color: textColor,fontSize: 20),),
        ),
      ),
      backgroundColor: background,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ExpansionTile(
                title: Text('Blocked Users',style: TextStyle(color: textColor,fontSize: 18),),
                children: [
                  ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: userProvider.usersList.length ?? 0,
                      itemBuilder: (context,index){
                        return !userProvider.getUser.blocked.contains(userProvider.usersList[index].id) ?
                       const SizedBox() :
                        userProvider.usersList.isEmpty ? const SizedBox() :
                        ListTile(
                          title: Text('${userProvider.usersList[index].name}',style: TextStyle(color: textColor,fontSize: 16),),
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundColor: textColor,
                            backgroundImage: userProvider.usersList[index].image.isEmpty ? AssetImage('assets/pic.jpg')
                                : NetworkImage(userProvider.usersList[index].image),
                          ),
                          trailing: IconButton(
                              icon: Icon(Icons.delete,color: textColor,size: 25,),
                              onPressed: (){
                                userProvider.unBlockUser(userProvider.usersList[index].id);
                              }),
                        );
                      }),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 0,horizontal: 10),
                child: Divider(color: icons,),
              ),
              const SizedBox(height: 10,),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: InkWell(
                  onTap: ()async{
                    await showDialog(context: context, builder: (_){
                      return new BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: PublishDialog(initialRadio: userProvider.getSelectedPublish,userProvider: userProvider,)
                      );
                    });
                  },
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Publish my will if away for',style: TextStyle(color: textColor,fontSize: 18),),
                      Text('${userProvider.getDiePublishTime}',style: TextStyle(color: icons,fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('If you do not come online at least once within this period, your diaries will be published to public',
                        style: TextStyle(color: textColor,fontSize: 15,),),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                child: Divider(color: icons,),
              ),
              Padding(
                  padding: const EdgeInsets.all(10),
                  child: InkWell(
                    onTap: ()async{
                      await showDialog(context: context, builder: (_){
                        return new BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Dialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                              backgroundColor: buttons,
                              child: PasswordSheet(youMeProvider: userProvider,)),
                        );
                      });
                    },
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Change secrets password',style: TextStyle(color: textColor,fontSize: 18),),
                        Text('*****',style: TextStyle(color: icons,fontSize: 18),)
                      ],
                    ),
                  ),
              ),
              const SizedBox(height: 10,),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 0,horizontal: 10),
                child: Divider(color: icons,),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Allow Notifications',style: TextStyle(color: textColor,fontSize: 18),),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Switch(
                        value: isSwitched,
                        onChanged: (value){
                          setState(() {
                            isSwitched = value;
                          });
                        },
                        activeTrackColor: textColor,
                        activeColor: icons,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
