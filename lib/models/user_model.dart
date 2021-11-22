import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:umee/models/diaries_model.dart';
import 'package:umee/models/notification_model.dart';

class YouMeUser{

static const String ID = "id";
static const String IMAGE = "image";
static const String FULL_NAME = "name";
static const String EMAIL = "email";
static const String PASSWORD = "password";
static const String BIRTHDAY = "birthday";
static const String GENDER = "gender";
static const String LOCATION = "location";
static const String ABOUT = "about";
static const String FOLLOWERS = "followers";
static const String FOLLOWING = "following";
static const String LIKED_DIARIES = "likedDiariesIDs";
static const String DIARIES_NO = "diariesNo";
static const String HIDDEN_DIARIES = "hiddenDiariesIDs";
static const String BLOCKED = "blocked";
static const String TOKEN = "token";
static const String NOTIFICATIONS = "notifications";
static const String FOLLOWING_IDS = 'follow_ids';
static const String FOLLOWERS_IDS = 'followers_ids';
static const String LAST_ACTIVE = 'lastActiveDate';
static const String SECRETS_PASSWORD = 'secretsPassword';

String id;
String image;
String name;
String email;
String password;
String birthday;
String gender;
String location;
String about;
String token;
String lastActiveDate;
String secretsPassword;
int diariesNo;
List<Admires> followers;
List<Admires> following;
List<NotificationModel> notifications;
List<dynamic> likedDiariesIDs;
List<dynamic> hiddenDiariesIDs;
List<dynamic> blocked;
List<dynamic> followingIDs;
List<dynamic> followersIDs;

YouMeUser.create({this.id,this.email,this.password,this.name,this.birthday,this.location,
  this.gender,this.about,this.following,this.followers,this.image,this.likedDiariesIDs,
  this.diariesNo,this.token,this.blocked,this.hiddenDiariesIDs,this.followingIDs,this.notifications,this.lastActiveDate,this.secretsPassword,this.followersIDs});
YouMeUser.setUp({this.name,this.birthday,this.location,this.gender,this.about});
YouMeUser.initial({this.id,this.email,this.password});
YouMeUser();

void setFollowing(List<Admires> admires){
  this.following = admires;
}

void setFollowers(List<Admires> admires){
  this.followers = admires;
}

  YouMeUser.fromSnapshot(DocumentSnapshot doc){
   id = (doc.data() as Map)[ID] ?? '';
   image = (doc.data() as Map)[IMAGE] ?? '';
   name = (doc.data() as Map)[FULL_NAME] ?? '';
   email = (doc.data() as Map)[EMAIL] ?? '';
   password = (doc.data() as Map)[PASSWORD] ?? '';
   birthday = (doc.data() as Map)[BIRTHDAY] ?? '';
   gender = (doc.data() as Map)[GENDER] ?? '';
   location = (doc.data() as Map)[LOCATION] ?? '';
   about = (doc.data() as Map)[ABOUT] ?? '';
   token = (doc.data() as Map)[TOKEN] ?? '';
   lastActiveDate = (doc.data() as Map)[LAST_ACTIVE] ?? '';
   diariesNo = (doc.data() as Map)[DIARIES_NO] ?? 0;
   followers = followersList((doc.data() as Map)[FOLLOWERS] ?? []);
   following = followersList((doc.data() as Map)[FOLLOWING] ?? []);
   notifications = notificationsList((doc.data() as Map)[NOTIFICATIONS] ?? []);
   likedDiariesIDs = (doc.data() as Map)[LIKED_DIARIES] ?? [];
   hiddenDiariesIDs = (doc.data() as Map)[HIDDEN_DIARIES] ?? [];
   blocked = (doc.data() as Map)[BLOCKED] ?? [];
   followingIDs = (doc.data() as Map)[FOLLOWING_IDS] ?? [];
   followersIDs = (doc.data() as Map)[FOLLOWERS_IDS] ?? [];
   secretsPassword = (doc.data() as Map)[SECRETS_PASSWORD] ?? '';
  }

YouMeUser.fromMap(Map<String,dynamic> map){
  id = map[ID] ?? '';
  image = map[IMAGE] ?? '';
  name = map[FULL_NAME] ?? '';
  email = map[EMAIL] ?? '';
  password = map[PASSWORD] ?? '';
  birthday = map[BIRTHDAY] ?? '';
  gender = map[GENDER] ?? '';
  location = map[LOCATION] ?? '';
  about = map[ABOUT] ?? '';
  token = map[TOKEN] ?? '';
  lastActiveDate = map[LAST_ACTIVE] ?? '';
  diariesNo = map[DIARIES_NO] ?? 0;
  followers = map[FOLLOWERS] ?? [];
  following = map[FOLLOWING] ?? [];
  notifications = map[NOTIFICATIONS] ?? [];
  likedDiariesIDs = map[LIKED_DIARIES] ?? [];
  hiddenDiariesIDs = map[HIDDEN_DIARIES] ?? [];
  blocked = map[BLOCKED] ?? [];
  followingIDs = map[FOLLOWING_IDS] ?? [];
  followersIDs = map[FOLLOWERS_IDS] ?? [];
  secretsPassword = map[SECRETS_PASSWORD] ?? '';
}

  Map<String,dynamic> toMap()=>{
    ID : id ??'',
    IMAGE : image ??'',
    FULL_NAME : name ??'',
    EMAIL : email ??'',
    PASSWORD : password ??'',
    BIRTHDAY : birthday ??'',
    GENDER : gender ??'',
    LOCATION : location ??'',
    ABOUT : about ?? '',
    TOKEN : token ?? '',
    LAST_ACTIVE : lastActiveDate ?? '',
    DIARIES_NO : diariesNo ?? 0,
    FOLLOWERS : followers.map((e) => e.toMap()).toList() ?? [],
    FOLLOWING : following.map((e) => e.toMap()).toList() ?? [],
    LIKED_DIARIES : likedDiariesIDs ?? [],
    HIDDEN_DIARIES : hiddenDiariesIDs ?? [],
    BLOCKED : blocked ?? [],
    FOLLOWING_IDS : followingIDs ?? [],
    FOLLOWERS_IDS : followersIDs ?? [],
    NOTIFICATIONS : notifications.map((e) => e.toMap()).toList() ?? [],
    SECRETS_PASSWORD : secretsPassword ?? '',
  };

List<Admires> followersList (List<dynamic> admires){
  List<Admires> convertedAdmires = [];
  for(Map item in admires){
    convertedAdmires.add(Admires.fromMap(item));
  }
  return convertedAdmires;
}

List<NotificationModel> notificationsList (List<dynamic> notification){
  List<NotificationModel> convertedAdmires = [];
  for(Map item in notification){
    convertedAdmires.add(NotificationModel.fromMap(item));
  }
  return convertedAdmires;
}
}