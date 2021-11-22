import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:umee/models/reminder_model.dart';
import 'package:umee/repositories/diary_provider.dart';
import 'package:umee/repositories/user_provider.dart';
import 'package:umee/screens/who_search.dart';
import 'package:umee/utils/constants.dart';
import 'package:umee/utils/shared.dart';
import 'package:umee/widgets/widgets.dart';
import 'package:uuid/uuid.dart';
import 'package:workmanager/workmanager.dart';

class AddReminder extends StatefulWidget {
  final DiaryProvider diaryProvider;
  final UserProvider userProvider;

  const AddReminder({Key key, this.diaryProvider, this.userProvider}) : super(key: key);

  @override
  _AddReminderState createState() => _AddReminderState();
}

class _AddReminderState extends State<AddReminder> {
  String dateTime = '';
  bool showTitle = false;
  bool showDesc = false;
  final TextEditingController titleController = new TextEditingController();
  final TextEditingController descController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: bar,
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Create Reminder',style: TextStyle(color: textColor,fontSize: 18),),
        ),
        leading: IconButton(
            onPressed: (){
              Navigator.pop(context);
              widget.userProvider.person.clear();
              widget.userProvider.registers.clear();
              widget.userProvider.participate.clear();
            },
            icon: Icon(Icons.arrow_back,color: textColor,size: 30,)),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: RaisedButton(
              color: icons,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              elevation: 2,
              onPressed: () async{
                if(dateTime.isNotEmpty && titleController.text.isNotEmpty && descController.text.isNotEmpty && !widget.userProvider.isLoading) {
                  widget.userProvider.refreshLoading();
                  String uuid = Uuid().v4();
                  ReminderModel reminderModel = ReminderModel.add(id: uuid,date: dateTime.split(' ')[0], time: dateTime.split(' ')[1],
                      title: titleController.text,desc: descController.text,taggedList: widget.userProvider.participate ?? []
                      ,host: widget.userProvider.getUser.name,hostId: widget.userProvider.getUser.id);
                  widget.userProvider.addNewReminder(reminderModel,uuid);
                  if (widget.userProvider.person.isNotEmpty) {
                   await Utils.sendPostPushMessage('${widget.userProvider.getUser.name} invites you to a reminder','YOUME', Utils.REMINDER_TAGS_SECTION,
                        widget.userProvider.registers,'$dateTime',widget.userProvider.getUser.image,uuid,widget.userProvider.getUser.id);
                    widget.userProvider.registers.clear();
                   widget.userProvider.participate.clear();
                  }
                  Workmanager().registerPeriodicTask(
                    uuid,
                    Utils.REMINDER_TASK,
                    frequency: Duration(minutes: 15),
                    inputData: {
                      Utils.UNIQUE_ID : '$uuid',
                      Utils.SERVICE_USER_ID : '${widget.userProvider.getUser.id}'
                    },
                  );
                //  showNotification(uuid, '${titleController.text}');
                  widget.userProvider.refreshLoading();
                  Navigator.pop(context);
                }else{
                  Utils.showToast('Please add full data');
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Add',style: TextStyle(letterSpacing: 1,fontSize: 18,color: textColor),),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: background,
      body: SingleChildScrollView(
              physics: ScrollPhysics(),
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                    padding: EdgeInsets.all(8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.add_circle_outline,color: textColor,size: 25,),
                          onPressed: ()async{
                            await showSearch(context: context, delegate: WhoSearch(tag: true,userProvider: widget.userProvider,list: widget.userProvider.getUser.followers));
                          },
                        ),
                        Text('Tag People',style: TextStyle(
                            fontSize: 16,
                            color: textColor
                        ),),
                      ],
                    ),
                  ),
                  widget.userProvider.participate.isNotEmpty ?
                 Container(
                   height: 70,
                   child: ListView.builder(
                       scrollDirection: Axis.horizontal,
                       itemCount: widget.userProvider.participate.length,
                       itemBuilder: (context,index){
                        return  Row(
                            children:[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('${widget.userProvider.participate[index].userName}',style: TextStyle(fontSize: 16,color: textColor),),
                              ),
                              InkWell(
                                onTap: (){
                                  setState(() {
                                    widget.userProvider.clearPerson(index);
                                    widget.userProvider.clearParticipate(index);
                                    widget.userProvider.clearRegisters(index);
                                  });
                                },
                                child: CircleAvatar(
                                    backgroundColor: icons,
                                    radius: 10,
                                    child: Icon(Icons.close,size: 15,color: textColor,)
                                ),),
                            ]
                        );
                      }),
                 )
                      : const SizedBox(),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 15,horizontal: 20),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: buttons,
                          borderRadius: BorderRadius.circular(10)
                      ),
                      child: MaterialButton(
                        onPressed: () async{
                          DatePicker.showDateTimePicker(context,
                              theme: DatePickerTheme(backgroundColor: background,itemStyle: TextStyle(color: textColor),doneStyle: TextStyle(color: textColor,fontSize: 17)),
                              showTitleActions: true,
                              minTime: DateTime.now(),
                              maxTime: DateTime(2021, 12, 30),
                              onConfirm: (date) {
                                setState(() {
                                  dateTime = date.toLocal().toString().split('.000')[0];
                                });
                              },
                              currentTime: DateTime.now(),
                              locale: LocaleType.en);
                        },
                        child: Text('Pick up date and time',style: TextStyle(fontSize: 18,color: textColor),),
                      ),
                    ),
                  ),
                  dateTime.isNotEmpty ? Row(mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('$dateTime',style: TextStyle(color: textColor,fontSize: 15),),
                      SizedBox(width: 5,),
                      InkWell(
                        onTap: (){
                          setState(() {
                            dateTime = '';
                          });
                        },
                        child: CircleAvatar(
                            backgroundColor: icons,
                            radius: 9,
                            child: Icon(Icons.close,size: 13,color: textColor,)
                        ),),
                    ],
                  ) : SizedBox(),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 15,horizontal: 20),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: buttons,
                          borderRadius: BorderRadius.circular(10)
                      ),
                      child: MaterialButton(
                        onPressed: () async{
                         setState(() {
                           showTitle = !showTitle;
                         });
                        },
                        child: Text('Add Title',style: TextStyle(fontSize: 18,color: textColor),),
                      ),
                    ),
                  ),
                  showTitle ? Padding(
                    padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                    child: TextField(
                      style: TextStyle(color: textColor,fontSize: 16),
                      decoration: textInputDecoration2('title'),
                      controller: titleController,
                    ),
                  ) : SizedBox(),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 15,horizontal: 20),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: buttons,
                          borderRadius: BorderRadius.circular(10)
                      ),
                      child: MaterialButton(
                        onPressed: () async{
                          setState(() {
                            showDesc = !showDesc;
                          });
                        },
                        child: Text('Add Description',style: TextStyle(fontSize: 18,color: textColor),),
                      ),
                    ),
                  ),
                  showDesc ? Padding(
                    padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                    child: TextField(
                      style: TextStyle(color: textColor,fontSize: 16),
                      decoration: textInputDecoration2('description'),
                      controller: descController,
                    ),
                  ) : SizedBox(),

                  widget.userProvider.isLoading ? Center(
                    child: CircleAvatar(
                        radius: 30,
                        backgroundColor: icons,
                        child: RefreshProgressIndicator()
                    ),
                  ) : Container(),
                ],
              ),
            ),
    );
  }

@override
  void dispose() {
    super.dispose();
    descController.dispose();
    titleController.dispose();
  }
}
