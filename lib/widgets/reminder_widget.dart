import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:umee/models/reminder_model.dart';
import 'package:umee/repositories/user_provider.dart';
import 'package:umee/utils/constants.dart';
import 'package:umee/utils/shared.dart';
import 'package:workmanager/workmanager.dart';

class ReminderWidget extends StatelessWidget {
  final ReminderModel reminderModel;
  final UserProvider userProvider;
  final int index;

  const ReminderWidget({Key key, this.reminderModel, this.userProvider, this.index}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final date = Utils.dateDifference(reminderModel.date, reminderModel.time);
    final List<String> moreList = ['Delete'];
    return Card(
      elevation: 2,
      color: buttons,
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              reminderModel.hostId == userProvider.getUser.id ?
              Stack(
               children: [
                 Align(
                   alignment: Alignment.center,
                   child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('${reminderModel.title}',textAlign: TextAlign.center,
                      style: TextStyle(color: textColor,fontSize: 19,fontWeight: FontWeight.bold),),
                    ),
                 ),
                index == 1 ?
                    SizedBox()
                :Align(
                 alignment: Alignment.centerRight,
                 child: new PopupMenuButton(
                  icon: Icon(Icons.more_horiz,color: textColor,),
                       color: buttons,
                       iconSize: 28,
                       elevation: 3.2,
                       initialValue: moreList[0],
                       tooltip: 'This is tooltip',
                       onSelected: (val)async{
                         if(val == moreList[0]){
                           switch (index){
                             case 0:
                               {
                                 await userProvider.deleteReminder(reminderModel.id);
                                 await Workmanager().cancelByUniqueName(reminderModel.id);
                                 Utils.showToast('This reminder has been deleted');
                               }
                               break;
                             case 3:
                               {
                                 await userProvider.deleteHistory(reminderModel.id);
                                 Utils.showToast('This history has been deleted');
                               }
                               break;
                           }
                         }
                       },
                       itemBuilder: (BuildContext context) {
                         return moreList.map((choice) {
                           return PopupMenuItem(
                             value: choice,
                             child: Text(choice,style: TextStyle(color: textColor),),
                           );
                         }).toList();
                       },
                     ),
               )
             ],
           ) : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('${reminderModel.title}',textAlign: TextAlign.center,
                  style: TextStyle(color: textColor,fontSize: 19,fontWeight: FontWeight.bold),),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: new CountdownTimer(
                    endTime: date,
                    endWidget: Container(
                      padding: EdgeInsets.all(8),
                      child: Text('Your reminder comes to an end!',style: TextStyle(fontSize: 17,color: icons),textAlign: TextAlign.center,),
                    ),
                    textStyle: TextStyle(color: icons,fontSize: 16),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text('Hosted By:',style: TextStyle(color: textColor,fontSize: 17,fontWeight: FontWeight.bold),),
                    SizedBox(width: 5,),
                    Text('${reminderModel.host}',style: TextStyle(color: textColor,fontSize: 16),),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                children: [
                  Text('Description:',style: TextStyle(color: textColor,fontSize: 17,fontWeight: FontWeight.bold),),
                  SizedBox(width: 5,),
                  Text('${reminderModel.desc}',style: TextStyle(color: textColor,fontSize: 16),),
                 ],
                ),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text('Date:',style: TextStyle(color: textColor,fontSize: 17,fontWeight: FontWeight.bold),),
                    SizedBox(width: 5,),
                    Text('${reminderModel.date}',style: TextStyle(color: textColor,fontSize: 16),),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text('Time:',style: TextStyle(color: textColor,fontSize: 17,fontWeight: FontWeight.bold),),
                    SizedBox(width: 5,),
                    Text('${reminderModel.time}',style: TextStyle(color: textColor,fontSize: 16),),
                  ],
                ),
              ),
              ExpansionTile(
                childrenPadding: const EdgeInsets.all(8.0),
                leading: Icon(Icons.person,size: 25,color: textColor,),
                title: Text('Participants',style: TextStyle(color: textColor,fontSize: 17,fontWeight: FontWeight.bold),),
                children: [
                  ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: reminderModel.taggedList.length ?? 0,
                      itemBuilder: (context,index){
                        return reminderModel.taggedList.isEmpty ? SizedBox() :
                        ListTile(
                          contentPadding: EdgeInsets.all(8),
                          title: Text('${reminderModel.taggedList[index].userName}',style: TextStyle(color: textColor,fontSize: 16),),
                          leading: CircleAvatar(
                            radius: 28,
                            backgroundColor: textColor,
                            backgroundImage: reminderModel.taggedList[index].userImage.isEmpty ?
                                  AssetImage('assets/pic.jpg')
                                : CachedNetworkImageProvider(reminderModel.taggedList[index].userImage),
                          ),
                          trailing: Text('${reminderModel.taggedList[index].userStatus}',
                            style: TextStyle(color: reminderModel.taggedList[index].userStatus == Utils.IN ? icons : float ,fontSize: 18),),
                        );
                      }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
