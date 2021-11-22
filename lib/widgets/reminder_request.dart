import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:umee/models/reminder_model.dart';
import 'package:umee/repositories/user_provider.dart';
import 'package:umee/utils/constants.dart';
import 'package:umee/utils/shared.dart';

class ReminderRequest extends StatelessWidget {
  final ReminderModel reminderModel;
  final UserProvider userProvider;

  const ReminderRequest({Key key, this.reminderModel, this.userProvider}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final date = DateTime(int.parse(reminderModel.date.split('-')[0]),int.parse(reminderModel.date.split('-')[1],)
        ,int.parse(reminderModel.date.split('-')[2]),int.parse(reminderModel.time.split(':')[0]),
        int.parse(reminderModel.time.split(':')[1]),int.parse(reminderModel.time.split(':')[2])).millisecondsSinceEpoch;
    return Card(
      elevation: 2,
      color: buttons,
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('${reminderModel.title}',textAlign: TextAlign.center,
                  style: TextStyle(color: textColor,fontSize: 19,fontWeight: FontWeight.bold),),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: CountdownTimer(
                    endTime: date,
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
              Container(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: ()async{
                        ParticipantModel inModel = ParticipantModel.add(userStatus: Utils.IN,userImage: userProvider.getUser.image,
                            userToken: userProvider.getUser.token, userName: userProvider.getUser.name,userId: userProvider.getUser.id);
                        ParticipantModel currentModel = ParticipantModel.add(userStatus: Utils.WAITING,
                            userImage: userProvider.getUser.image,userToken: userProvider.getUser.token,
                            userName: userProvider.getUser.name,userId: userProvider.getUser.id);
                        await userProvider.cancelPartStat(currentModel, reminderModel.id);
                        await userProvider.updatePartStat(inModel, reminderModel.id);
                      },
                      child: CircleAvatar(
                        backgroundColor: icons,
                        radius: 22,
                        child: Icon(Icons.check,size: 25,color: textColor,),
                      ),),
                    SizedBox(width: 15,),
                    InkWell(
                      onTap: ()async{
                        ParticipantModel outModel = ParticipantModel.add(userStatus: Utils.OUT,userImage: userProvider.getUser.image,userToken: userProvider.getUser.token,
                            userName: userProvider.getUser.name,userId: userProvider.getUser.id);
                        ParticipantModel currentModel = ParticipantModel.add(userStatus: Utils.WAITING,userImage: userProvider.getUser.image,
                            userToken: userProvider.getUser.token, userName: userProvider.getUser.name,userId: userProvider.getUser.id);
                        await userProvider.cancelPartStat(currentModel, reminderModel.id);
                        await userProvider.updatePartStat(outModel, reminderModel.id);
                      },
                      child: CircleAvatar(
                        backgroundColor: icons,
                        radius: 22,
                        child: Icon(Icons.clear,size: 25,color: textColor,),
                      ),),
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
