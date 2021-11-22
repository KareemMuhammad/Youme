import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:umee/models/reminder_model.dart';
import 'package:umee/repositories/diary_provider.dart';
import 'package:umee/repositories/user_provider.dart';
import 'package:umee/screens/add_reminder.dart';
import 'package:umee/utils/shared.dart';
import 'package:umee/widgets/reminder_request.dart';
import 'package:umee/widgets/reminder_widget.dart';

class MyReminderScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final DiaryProvider diaryProvider = Provider.of<DiaryProvider>(context);
    final ParticipantModel inModel = ParticipantModel.add(userId: userProvider.getUser.id,userName: userProvider.getUser.name,
        userImage: userProvider.getUser.image,userToken: userProvider.getUser.token,userStatus: 'in');
    final ParticipantModel waitModel = ParticipantModel.add(userId: userProvider.getUser.id,userName: userProvider.getUser.name,
        userImage: userProvider.getUser.image,userToken: userProvider.getUser.token,userStatus: 'waiting');
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: bar,
          centerTitle: true,
          title: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Reminder',style: TextStyle(color: textColor,fontSize: 20),),
          ),
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: textColor,
            tabs: [
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text('My Reminders',style: TextStyle(color: textColor,fontSize: 17),),
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text('Participation',style: TextStyle(color: textColor,fontSize: 17),),
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text('Requests',style: TextStyle(color: textColor,fontSize: 17),),
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text('History',style: TextStyle(color: textColor,fontSize: 17),),
              ),
            ],
          ),
        ),
        backgroundColor: background,
        body: TabBarView(
          children: [
           userProvider.getUser != null ?
           FutureBuilder<List<ReminderModel>>(
              future: userProvider.fetchRemindersOfUser(userProvider.getUser.id),
              builder: (BuildContext context, AsyncSnapshot<List<ReminderModel>> snapshot) {
                return snapshot.data != null && snapshot.data.isNotEmpty ?
                ListView.builder(
                    itemCount: snapshot.data.length ?? 0,
                    itemBuilder: (context,index){
                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ReminderWidget(reminderModel: snapshot.data[index],userProvider: userProvider,index: 0,),
                      );
                    }) : Center(child: Text('you have no reminders yet',style: TextStyle(color: textColor,fontSize: 17),),);
              },
            ) : Center(child: CircularProgressIndicator(),),

           userProvider.getUser != null && inModel != null ?
           FutureBuilder<List<ReminderModel>>(
              future: userProvider.fetchRemindersOfUserParticipate(inModel),
              builder: (BuildContext context, AsyncSnapshot<List<ReminderModel>> snapshot) {
                return snapshot.data != null && snapshot.data.isNotEmpty ?
                ListView.builder(
                    itemCount: snapshot.data.length ?? 0,
                    itemBuilder: (context,index){
                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ReminderWidget(reminderModel: snapshot.data[index],userProvider: userProvider,index: 1,),
                      );
                    }) : Center(child: Text('you did\'nt participate in any reminder yet',style: TextStyle(color: textColor,fontSize: 17),),);
              },
            ): Center(child: CircularProgressIndicator(),),

            userProvider.getUser != null && waitModel != null ?
            FutureBuilder<List<ReminderModel>>(
              future: userProvider.fetchRemindersOfUserParticipate(waitModel),
              builder: (BuildContext context, AsyncSnapshot<List<ReminderModel>> snapshot) {
                return snapshot.data != null && snapshot.data.isNotEmpty ?
                ListView.builder(
                    itemCount: snapshot.data.length ?? 0,
                    itemBuilder: (context,index){
                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ReminderRequest(reminderModel: snapshot.data[index],userProvider: userProvider,),
                      );
                    }) : Center(child: Text('you did\'nt have any requests yet',style: TextStyle(color: textColor,fontSize: 17),),);
              },
            ): Center(child: CircularProgressIndicator(),),

            userProvider.getUser != null ?
            FutureBuilder<List<ReminderModel>>(
              future: userProvider.fetchHistoryOfUser(userProvider.getUser.id),
              builder: (BuildContext context, AsyncSnapshot<List<ReminderModel>> snapshot) {
                return snapshot.data != null && snapshot.data.isNotEmpty ?
                ListView.builder(
                    itemCount: snapshot.data.length ?? 0,
                    itemBuilder: (context,index){
                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ReminderWidget(reminderModel: snapshot.data[index],userProvider: userProvider,index: 3,),
                      );
                    }) : Center(child: Text('Your history is empty',style: TextStyle(color: textColor,fontSize: 17),));
              },
            ): Center(child: CircularProgressIndicator(),),
          ],
        ),
        floatingActionButton: FloatingActionButton(
            backgroundColor: float,
            heroTag: Text('remind'),
            elevation: 4,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => AddReminder(userProvider: userProvider,diaryProvider: diaryProvider,)));
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.all_inclusive,size: 28,color: textColor,),
            )
        ),
      ),
    );
  }
}
