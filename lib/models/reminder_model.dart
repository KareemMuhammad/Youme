import 'package:cloud_firestore/cloud_firestore.dart';

class ReminderModel{
  static const String ID = 'id';
  static const String HOST_ID = 'hostId';
  static const String TITLE = 'title';
  static const String DESC = 'description';
  static const String DATE = 'date';
  static const String TIME = 'time';
  static const String TAGGED_PEOPLE = 'taggedPeople';
  static const String HOST = 'host';

  String id;
  String title;
  String desc;
  String date;
  String time;
  String host;
  String hostId;
  List<ParticipantModel> taggedList;

  ReminderModel();
  ReminderModel.add({this.desc,this.title,this.date,this.id,this.time,this.taggedList,this.host,this.hostId});

  ReminderModel.fromSnapshot(DocumentSnapshot doc){
    id = (doc.data() as Map)[ID] ?? '';
    date = (doc.data() as Map)[DATE] ?? '';
    time = (doc.data() as Map)[TIME] ?? '';
    title = (doc.data() as Map)[TITLE] ?? '';
    desc = (doc.data() as Map)[DESC] ?? '';
    host = (doc.data() as Map)[HOST] ?? '';
    hostId = (doc.data() as Map)[HOST_ID] ?? '';
    taggedList = admiresList((doc.data() as Map)[TAGGED_PEOPLE] ?? []);
  }

  Map<String,dynamic> toMap() => {
    ID : id ?? '',
    DATE : date ?? '',
    TIME : time ?? '',
    TITLE : title ?? '',
    DESC : desc ?? '',
    HOST : host ?? '',
    HOST_ID : hostId ?? '',
    TAGGED_PEOPLE : taggedList.map((e) => e.toMap()).toList() ?? [],
  };

  List<ParticipantModel> admiresList (List<dynamic> admires){
    List<ParticipantModel> convertedAdmires = [];
    for(Map item in admires){
      convertedAdmires.add(ParticipantModel.fromMap(item));
    }
    return convertedAdmires;
  }
}

class ParticipantModel {
  static const String USER_NAME = 'userName';
  static const String USER_IMAGE = 'userImage';
  static const String USER_ID = 'userId';
  static const String USER_TOKEN = 'userToken';
  static const String USER_STATUS = 'userStatus';

  ParticipantModel.add({this.userImage,this.userName,this.userId, this.userToken,this.userStatus});
  ParticipantModel();

  String userId;
  String userName;
  String userImage;
  String userToken;
  String userStatus;

  ParticipantModel.fromMap(Map<String,dynamic> map){
    userId = map[USER_ID] ?? '';
    userName = map[USER_NAME] ?? '';
    userImage = map[USER_IMAGE] ?? '';
    userToken = map[USER_TOKEN] ?? '';
    userStatus = map[USER_STATUS] ?? '';
  }

  Map<String,dynamic> toMap()=>{
    USER_ID : userId ?? '',
    USER_IMAGE : userImage ?? '',
    USER_NAME : userName ?? 'Unknown',
    USER_TOKEN : userToken ?? '',
    USER_STATUS : userStatus ?? '',
  };
}