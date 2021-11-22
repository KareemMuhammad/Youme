import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:umee/models/diaries_model.dart';
import 'package:umee/models/reminder_model.dart';
import 'package:umee/models/notification_model.dart';
import 'package:umee/models/user_model.dart';
import 'package:umee/utils/shared.dart';

class UserRepository {
  final CollectionReference _usersCollection = FirebaseFirestore.instance
      .collection(USERS_COLLECTION);
  final CollectionReference _reminderCollection = FirebaseFirestore.instance
      .collection(REMINDER_COLLECTION);
  final CollectionReference _reminderHistoryCollection = FirebaseFirestore.instance
      .collection(REMINDER_HISTORY_COLLECTION);

  static Future<SharedPreferences> shared()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs;
  }

  Future<YouMeUser> getUserById(String id){
    return _usersCollection.doc(id).get().then((doc){
      return YouMeUser.fromSnapshot(doc);
    });
  }

  Future saveReminderToDb(Map<String,dynamic> userMap,String id)async{
    await _reminderCollection.doc(id).set(userMap);
  }
  Future saveReminderToHistory(Map<String,dynamic> userMap,String id)async{
    await _reminderHistoryCollection.doc(id).set(userMap);
  }

  Future updateUserToken(String token,String id)async{
    await  _usersCollection.doc(id).update(
        {YouMeUser.TOKEN : token });
  }

  Future saveNotificationToUserDb(NotificationModel notificationModel,String id)async{
    await  _usersCollection.doc(id).update(
        {YouMeUser.NOTIFICATIONS : FieldValue.arrayUnion([notificationModel.toMap()]) });
  }

  Future<List<ReminderModel>> getReminderById(String id)async{
    QuerySnapshot snapshot = await _reminderCollection.where(ReminderModel.HOST_ID, isEqualTo: id).orderBy(ReminderModel.DATE,descending: true).get()
        .catchError((e) {
      print(e.toString());
    });
    return snapshot.docs.map((doc) {
      return ReminderModel.fromSnapshot(doc);
    }).toList();
  }

  Future<List<ReminderModel>> getAllReminders()async{
    QuerySnapshot snapshot = await _reminderCollection.orderBy(ReminderModel.DATE,descending: true).get()
        .catchError((e) {
      print(e.toString());
    });
    return snapshot.docs.map((doc) {
      return ReminderModel.fromSnapshot(doc);
    }).toList();
  }

  Future<List<ReminderModel>> getReminderHistoryById(String id)async{
    QuerySnapshot snapshot = await _reminderHistoryCollection.where(ReminderModel.HOST_ID, isEqualTo: id).orderBy(Diaries.DATE,descending: true).get()
        .catchError((e) {
      print(e.toString());
    });
    return snapshot.docs.map((doc) {
      return ReminderModel.fromSnapshot(doc);
    }).toList();
  }

  Future<List<ReminderModel>> getReminderByParticipant(ParticipantModel admires)async{
    QuerySnapshot snapshot = await _reminderCollection.where(ReminderModel.TAGGED_PEOPLE, arrayContains: admires.toMap()).orderBy(Diaries.DATE,descending: true).get()
        .catchError((e) {
      print(e.toString());
    });
    return snapshot.docs.map((doc) {
      return ReminderModel.fromSnapshot(doc);
    }).toList();
  }

  Future updateParticipantStatus(Map<String,dynamic> map,String id)async{
    await _reminderCollection.doc(id).update({ReminderModel.TAGGED_PEOPLE: FieldValue.arrayUnion([map])});
  }

  Future cancelParticipantStatus(Map<String,dynamic> map,String id)async{
    await _reminderCollection.doc(id).update({ReminderModel.TAGGED_PEOPLE: FieldValue.arrayRemove([map])});
  }

  Future updateParticipantImage(Map<String,dynamic> map,String id)async{
    await _reminderCollection.doc(id).update({ReminderModel.TAGGED_PEOPLE: FieldValue.arrayUnion([map])});
  }

  Future cancelParticipantImage(Map<String,dynamic> map,String id)async{
    await _reminderCollection.doc(id).update({ReminderModel.TAGGED_PEOPLE: FieldValue.arrayRemove([map])});
  }

  Future<List<YouMeUser>> getAllUsers()async{
    QuerySnapshot snapshot = await _usersCollection.get();
    return snapshot.docs.map((doc) {
      return YouMeUser.fromSnapshot(doc);
    }).toList();
  }

  Future<bool> authenticateUser(User user) async {
    QuerySnapshot result = await _usersCollection
        .where(YouMeUser.EMAIL, isEqualTo: user.email)
        .get();
    final List<DocumentSnapshot> docs = result.docs;
    print(docs.length);
    return docs.length == 0 || docs.isEmpty ? true : false;
  }

  Future<bool> authenticateFacebookAndGoogle(User user) async {
    QuerySnapshot result = await _usersCollection
        .where(YouMeUser.ID, isEqualTo: user.uid)
        .get();
    final List<DocumentSnapshot> docs = result.docs;
    print(docs.length);
    return docs.length == 0 ? true : false;
  }

  Future saveUserToDb(Map<String,dynamic> userMap,String id)async{
    await _usersCollection.doc(id).set(userMap);
  }

  Future deleteUserFromDb(String id)async{
    await _usersCollection.doc(id).delete();
  }

  Future deleteReminderFromDb(String id)async{
    await _reminderCollection.doc(id).delete();
  }

  Future deleteHistoryFromDb(String id)async{
    await _reminderHistoryCollection.doc(id).delete();
  }

  Future updateUSerProfile(Map<String,dynamic> map,String id)async{
    await _usersCollection.doc(id).update({YouMeUser.FULL_NAME:map[YouMeUser.FULL_NAME], YouMeUser.BIRTHDAY:map[YouMeUser.BIRTHDAY]
      ,YouMeUser.GENDER:map[YouMeUser.GENDER],YouMeUser.LOCATION:map[YouMeUser.LOCATION],YouMeUser.ABOUT:map[YouMeUser.ABOUT]});
  }

  Future updateAllUSerFollowers(Map<String,dynamic> map,String id)async{
    await _usersCollection.doc(id).update({YouMeUser.FOLLOWERS: map});
  }

  Future updateAllUSerFollowing(Map<String,dynamic> map,String id)async{
    await _usersCollection.doc(id).update({YouMeUser.FOLLOWING: map});
  }

  Future updateUSerImage(String image,String id)async{
    await _usersCollection.doc(id).update({YouMeUser.IMAGE: image});
  }

  Future updateUSerEmail(String email,String id)async{
    await _usersCollection.doc(id).update({YouMeUser.EMAIL: email});
  }

  Future updateUSerName(String name,String id)async{
    await _usersCollection.doc(id).update({YouMeUser.FULL_NAME: name});
  }

  Future updateUSerGender(String gender,String id)async{
    await _usersCollection.doc(id).update({YouMeUser.GENDER: gender});
  }

  Future updateUSerBirth(String birth,String id)async{
    await _usersCollection.doc(id).update({YouMeUser.BIRTHDAY: birth});
  }

  Future updateUSerLastActiveDate(String date,String id)async{
    await _usersCollection.doc(id).update({YouMeUser.LAST_ACTIVE: date});
  }

  Future updateUSerLocation(String location,String id)async{
    await _usersCollection.doc(id).update({YouMeUser.LOCATION: location});
  }

  Future updateUSerAbout(String about,String id)async{
    await _usersCollection.doc(id).update({YouMeUser.ABOUT: about});
  }

  Future updateUSerSecretsPassword(String pass,String id)async{
    await _usersCollection.doc(id).update({YouMeUser.SECRETS_PASSWORD: pass});
  }

  Future blockUser(String id,String userId)async{
    await _usersCollection.doc(id).update({YouMeUser.BLOCKED : FieldValue.arrayUnion([userId])});
  }

  Future unBlockUser(String id,String userId)async{
    await _usersCollection.doc(id).update({YouMeUser.BLOCKED : FieldValue.arrayRemove([userId])});
  }

  Future updateUserLikedDiaries(String diaryID,String id)async{
    await _usersCollection.doc(id).update({YouMeUser.LIKED_DIARIES: FieldValue.arrayUnion([diaryID])});
  }

  Future removeUserLikedDiaries(String diaryID,String id)async{
    await _usersCollection.doc(id).update({YouMeUser.LIKED_DIARIES: FieldValue.arrayRemove([diaryID])});
  }

  Future followUser(Map<String,dynamic> map,String id,Admires admires)async{
    await _usersCollection.doc(id).update({YouMeUser.FOLLOWING: FieldValue.arrayUnion([map])});
    await _usersCollection.doc(map[Admires.USER_ID]).update({YouMeUser.FOLLOWERS: FieldValue.arrayUnion([admires.toMap()])});
  }

  Future unFollowUser(Map<String,dynamic> map,String id,Admires admires)async{
    await _usersCollection.doc(id).update({YouMeUser.FOLLOWING: FieldValue.arrayRemove([map])});
    await _usersCollection.doc(map[Admires.USER_ID]).update({YouMeUser.FOLLOWERS: FieldValue.arrayRemove([admires.toMap()])});
  }

  Future updateUserFeedHiddenDiaries(String diaryID,String id)async{
    await _usersCollection.doc(id).update({YouMeUser.HIDDEN_DIARIES: FieldValue.arrayUnion([diaryID])});
  }

  Future removeUserFeedHiddenDiaries(String diaryID,String id)async{
    await _usersCollection.doc(id).update({YouMeUser.HIDDEN_DIARIES: FieldValue.arrayRemove([diaryID])});
  }

  Future updateFollowingIds(String followID,String id)async{
    await _usersCollection.doc(id).update({YouMeUser.FOLLOWING_IDS: FieldValue.arrayUnion([followID])});
  }

  Future updateFollowersIds(String followID,String id)async{
    await _usersCollection.doc(followID).update({YouMeUser.FOLLOWERS_IDS: FieldValue.arrayUnion([id])});
  }

  Future deleteFollowersIds(String followID,String id)async{
    await _usersCollection.doc(followID).update({YouMeUser.FOLLOWERS_IDS: FieldValue.arrayRemove([id])});
    await _usersCollection.doc(id).update({YouMeUser.FOLLOWERS_IDS: FieldValue.arrayRemove([followID])});
  }

  Future deleteFollowingIds(String followID,String id)async{
    await _usersCollection.doc(id).update({YouMeUser.FOLLOWING_IDS: FieldValue.arrayRemove([followID])});
    await _usersCollection.doc(followID).update({YouMeUser.FOLLOWING_IDS: FieldValue.arrayRemove([id])});
  }

  Future updateUSerDiaryNumber(String id)async{
    await _usersCollection.doc(id).update({YouMeUser.DIARIES_NO: FieldValue.increment(1)});
  }

  Future decrementUSerDiaryNumber(String id)async{
    await _usersCollection.doc(id).update({YouMeUser.DIARIES_NO: FieldValue.increment(-1)});
  }
}