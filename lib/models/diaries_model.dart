import 'package:cloud_firestore/cloud_firestore.dart';

class Diaries{
  static const String ID = 'id';
  static const String USER_ID = 'userId';
  static const String CONTENT = 'content';
  static const String DATE = 'date';
  static const String FILTER_DATE = 'filterDate';
  static const String ADVICES = 'advices';
  static const String LOCATION = 'location';
  static const String IMAGES = 'images';
  static const String VIDEO_URL = 'videoUrl';
  static const String RECORD_URL = 'recordUrl';
  static const String USER_IMAGE = 'userImage';
  static const String USER_NAME = 'userName';
  static const String DIARY_LIKER = 'diaryLiker';
  static const String SHARES = 'shares';
  static const String CATEGORY = 'category';
  static const String WILL_CATEGORY = 'willCategory';
  static const String TAGGED_PERSON = 'taggedPerson';


  String id;
  String userId;
  String content;
  String date;
  String filterDate;
  String recordUrl;
  String videoUrl;
  String location;
  String userImage;
  String userName;
  String category;
  String willCategory;
  int shares;
  List<dynamic> images;
  List<Admires> diaryLikerList;
  List<Admires> taggedPeople;
  List<Advice> advices;

  Diaries.post({this.id,this.userId,this.date,this.location,this.content,this.recordUrl,
    this.images,this.videoUrl,this.userImage,this.userName,this.category,this.filterDate,this.willCategory,this.taggedPeople,this.advices,this.diaryLikerList});
  Diaries.update({this.id,this.userId,this.date,this.location,this.content,this.recordUrl,
    this.images,this.videoUrl,this.userImage,this.userName,this.category,this.filterDate,this.willCategory,this.taggedPeople,this.diaryLikerList,this.advices,this.shares});
  Diaries();

  Diaries.fromSnapshot(DocumentSnapshot doc){
    id = (doc.data() as Map)[ID] ?? '';
    userId = (doc.data() as Map)[USER_ID] ?? '';
    content = (doc.data() as Map)[CONTENT] ?? '';
    date = (doc.data() as Map)[DATE] ?? '';
    shares = (doc.data() as Map)[SHARES] ?? 0;
    location = (doc.data() as Map)[LOCATION] ?? '';
    videoUrl = (doc.data() as Map)[VIDEO_URL] ?? '';
    images = (doc.data() as Map)[IMAGES] ?? [];
    recordUrl = (doc.data() as Map)[RECORD_URL] ?? '';
    userName = (doc.data() as Map)[USER_NAME] ?? '';
    userImage = (doc.data() as Map)[USER_IMAGE] ?? '';
    diaryLikerList = admiresList((doc.data() as Map)[DIARY_LIKER] ?? []);
    advices = commentsList((doc.data() as Map)[ADVICES] ?? []);
    taggedPeople = admiresList((doc.data() as Map)[TAGGED_PERSON] ?? []);
    category = (doc.data() as Map)[CATEGORY] ?? '';
    filterDate = (doc.data() as Map)[FILTER_DATE] ?? '';
    willCategory = (doc.data() as Map)[WILL_CATEGORY] ?? '';
  }

  Diaries.fromJsonObject(doc){
    id = doc[ID] ?? '';
    userId = doc[USER_ID] ?? '';
    content = doc[CONTENT] ?? '';
    date = doc[DATE] ?? '';
    shares = doc[SHARES] ?? 0;
    location = doc[LOCATION] ?? '';
    videoUrl = doc[VIDEO_URL] ?? '';
    images = doc[IMAGES] ?? [];
    recordUrl = doc[RECORD_URL] ?? '';
    userName = doc[USER_NAME] ?? '';
    userImage = doc[USER_IMAGE] ?? '';
    diaryLikerList = admiresList(doc[DIARY_LIKER] ?? []);
    advices = commentsList(doc[ADVICES] ?? []);
    taggedPeople = admiresList(doc[TAGGED_PERSON] ?? []);
    category = doc[CATEGORY] ?? '';
    filterDate = doc[FILTER_DATE] ?? '';
    willCategory = doc[WILL_CATEGORY] ?? '';
  }

Map<String,dynamic> toMap()=>{
  ID : id ?? '',
  USER_ID : userId ?? '',
  CONTENT : content ?? '',
  DATE : date ?? '',
  SHARES : shares ?? 0,
  ADVICES : advices.map((e) => e.toMap()).toList() ?? [],
  LOCATION : location ?? '',
  VIDEO_URL : videoUrl ?? '',
  IMAGES : images.map((e) => e.toString()).toList() ?? [],
  RECORD_URL : recordUrl ?? '',
  CATEGORY : category ?? '',
  USER_NAME : userName ?? 'Unknown',
  USER_IMAGE : userImage ?? '',
  DIARY_LIKER : diaryLikerList.map((e) => e.toMap()).toList() ?? [],
  FILTER_DATE : filterDate ?? '',
  WILL_CATEGORY : willCategory ?? '',
  TAGGED_PERSON : taggedPeople.map((e) => e.toMap()).toList() ?? [],
};

  List<Advice> commentsList (List<dynamic> comments){
    List<Advice> convertedFollowing = [];
    for(Map cartItem in comments){
      convertedFollowing.add(Advice.fromMap(cartItem));
    }
    return convertedFollowing;
  }

  List<Admires> admiresList (List<dynamic> admires){
    List<Admires> convertedAdmires = [];
    for(Map item in admires){
      convertedAdmires.add(Admires.fromMap(item));
    }
    return convertedAdmires;
  }

}

class Admires {
  static const String USER_NAME = 'userName';
  static const String USER_IMAGE = 'userImage';
  static const String USER_ID = 'userId';
  static const String USER_TOKEN = 'userToken';
  static const String USER_STATUS = 'userStatus';

  Admires.add({this.userImage,this.userName,this.userId, this.userToken,this.userStatus});
  Admires();

  String userId;
  String userName;
  String userImage;
  String userToken;
  String userStatus;

  Admires.fromMap(Map<String,dynamic> map){
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
    USER_STATUS : userStatus ?? ''
  };
}

class Advice{
  static const String USER_ID = 'userId';
  static const String CONTENT = 'content';
  static const String DATE = 'date';
  static const String USER_NAME = 'userName';
  static const String USER_IMAGE = 'userImage';

  Advice.add({this.content,this.date,this.userImage,this.userName,this.userId});

  String userId;
  String content;
  String date;
  String userName;
  String userImage;

  Advice.fromMap(Map<String,dynamic> map){
    userId = map[USER_ID] ?? '';
    content = map[CONTENT] ?? '';
    date = map[DATE] ?? '';
    userName = map[USER_NAME] ?? '';
    userImage = map[USER_IMAGE] ?? '';
  }

  Map<String,dynamic> toMap()=>{
    USER_ID : userId ?? '',
    CONTENT : content ?? '',
    DATE : date ?? '',
    USER_IMAGE : userImage ?? '',
    USER_NAME : userName ?? 'Unknown',
  };
}