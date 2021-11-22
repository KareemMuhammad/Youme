import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:umee/models/diaries_model.dart';
import 'package:umee/utils/constants.dart';
import 'package:umee/utils/shared.dart';

class DiaryRepository{
  static CollectionReference _dairiesCollection = FirebaseFirestore.instance.collection(DIARIES_COLLECTION);
  static CollectionReference _usersCollection = FirebaseFirestore.instance.collection(USERS_COLLECTION);

  Future<List<Diaries>> getDiariesByCategories(String category)async{
    QuerySnapshot snapshot = await _dairiesCollection.where(Diaries.CATEGORY, isEqualTo: category).orderBy(Diaries.DATE,descending: true).get()
        .catchError((e) {
      print(e.toString());
    });
    return snapshot.docs.map((doc) {
      return Diaries.fromSnapshot(doc);
    }).toList();
  }

  Future<List<Diaries>> getAllDiaries()async{
    QuerySnapshot snapshot = await _dairiesCollection.orderBy(Diaries.DATE,descending: true).get()
        .catchError((e) {
      print(e.toString());
    });
    return snapshot.docs.map((doc) {
      return Diaries.fromSnapshot(doc);
    }).toList();
  }

  static Future<QuerySnapshot> getAllPublicLazyDiaries(int limit,{DocumentSnapshot startAfter})async{
    final ref = _dairiesCollection.where(Diaries.CATEGORY, isEqualTo: Utils.PUBLIC).orderBy(Diaries.DATE,descending: true).limit(limit);
    if (startAfter == null) {
      return ref.get();
    } else {
      return ref.startAfterDocument(startAfter).get();
    }
  }

  static Future<QuerySnapshot> getAllDiariesOfUser(String id,int limit,{DocumentSnapshot startAfter})async{
    final ref = _dairiesCollection.where(Diaries.USER_ID, isEqualTo: id).orderBy(Diaries.DATE,descending: true).limit(limit);
    if (startAfter == null) {
      return ref.get();
    } else {
      return ref.startAfterDocument(startAfter).get();
    }
  }

  static Future<QuerySnapshot> test(String id,int limit,{DocumentSnapshot startAfter})async{
    final ref = _dairiesCollection.where(Diaries.USER_ID, isEqualTo: id).where(Diaries.CATEGORY,whereIn: [Utils.PUBLIC,Utils.FOLLOWERS])
        .orderBy(Diaries.DATE,descending: true).limit(limit);
    if (startAfter == null) {
      return ref.get();
    } else {
      return ref.startAfterDocument(startAfter).get();
    }
  }

  static Future<QuerySnapshot> getAllDiariesOfFollow(String id,int limit,{DocumentSnapshot startAfter})async{
    final ref = _usersCollection.doc(id).collection(DIARIES_OF_FOLLOWING_COLLECTION).orderBy(Diaries.DATE,descending: true).limit(limit);
    if (startAfter == null) {
      return ref.get();
    } else {
      return ref.startAfterDocument(startAfter).get();
    }
  }

  Future<List<Diaries>> getAllSecretsOfUser(String id)async{
    QuerySnapshot snapshot = await _dairiesCollection.where(Diaries.USER_ID, isEqualTo: id).where(Diaries.CATEGORY,isEqualTo: Utils.SECRETS)
        .orderBy(Diaries.DATE,descending: true).get()
        .catchError((e) {
      print(e.toString());
    });
    return snapshot.docs.map((doc) {
      return Diaries.fromSnapshot(doc);
    }).toList();
  }

  Future<List<Diaries>> getAllDiariesOfUserIFollow(String id)async{
    QuerySnapshot snapshot = await _dairiesCollection.where(Diaries.USER_ID, isEqualTo: id).where(Diaries.CATEGORY,whereIn: [Utils.PUBLIC,Utils.FOLLOWERS])
        .orderBy(Diaries.DATE,descending: true).get()
        .catchError((e) {
      print(e.toString());
    });
    return snapshot.docs.map((doc) {
      return Diaries.fromSnapshot(doc);
    }).toList();
  }

  Future<List<Diaries>> getDiaryByDate(String date,String id)async{
    QuerySnapshot snapshot = await _dairiesCollection.where(Diaries.USER_ID, isEqualTo: id).where(Diaries.FILTER_DATE,isEqualTo: date)
        .orderBy(Diaries.DATE,descending: true).get()
        .catchError((e) {
      print(e.toString());
    });
    return snapshot.docs.map((doc) {
      return Diaries.fromSnapshot(doc);
    }).toList();
  }

  Future<Diaries> getDiaryById(String id){
    return _dairiesCollection.doc(id).get().then((doc){
      return Diaries.fromSnapshot(doc);
    });
  }

  Future<List<Diaries>> getUserWill(String id)async{
    QuerySnapshot snapshot = await _dairiesCollection.where(Diaries.USER_ID, isEqualTo: id).where(Diaries.CATEGORY,isEqualTo: Utils.WILL)
        .orderBy(Diaries.DATE,descending: true).get()
        .catchError((e) {
      print(e.toString());
    });
    return snapshot.docs.map((doc) {
      return Diaries.fromSnapshot(doc);
    }).toList();
  }

  Future addNewDiaryToDb(Diaries diaries,String id)async{
    await _dairiesCollection.doc(id).set(diaries.toMap());
  }

  Future addDiaryToUserCollection(Map<String,dynamic> map,String userId)async{
    await _usersCollection.doc(userId).collection(DIARIES_OF_FOLLOWING_COLLECTION).doc(map[Diaries.ID]).set(map);
  }

  Future addAdviceToDiary(Map<String,dynamic> map,String id)async{
    await _dairiesCollection.doc(id).update({Diaries.ADVICES: FieldValue.arrayUnion([map])});
  }

  Future addAdviceToFollowingDiary(Map<String,dynamic> map,String id,String userId)async{
    await _usersCollection.doc(userId).collection(DIARIES_OF_FOLLOWING_COLLECTION).doc(id).update({Diaries.ADVICES: FieldValue.arrayUnion([map])});
  }

  Future deleteAdviceFromDiary(Map<String,dynamic> map,String id)async{
    await _dairiesCollection.doc(id).update({Diaries.ADVICES: FieldValue.arrayRemove([map])});
  }

  Future deleteAdviceFromFollowingDiary(Map<String,dynamic> map,String id,String userId)async{
    await _usersCollection.doc(userId).collection(DIARIES_OF_FOLLOWING_COLLECTION).doc(id).update({Diaries.ADVICES: FieldValue.arrayRemove([map])});
  }

  Future updateDiaryContentOfFollow(String content,String diaryId,String userId)async{
    await _usersCollection.doc(userId).collection(DIARIES_OF_FOLLOWING_COLLECTION).doc(diaryId).update({Diaries.CONTENT: content});
  }

  Future updateDiaryContent(String content,String id)async{
    await _dairiesCollection.doc(id).update({Diaries.CONTENT: content});
  }

 Future updateDiaryUserImage(String image,String id)async{
    await _dairiesCollection.doc(id).update({Diaries.USER_IMAGE: image});
  }

  Future updateDiaryUserName(String name,String id)async{
    await _dairiesCollection.doc(id).update({Diaries.USER_NAME: name});
  }

  Future addLikerToDiary(Map<String,dynamic> map,String id)async{
    await _dairiesCollection.doc(id).update({Diaries.DIARY_LIKER: FieldValue.arrayUnion([map])});
  }

  Future addLikerToFollowingDiary(Map<String,dynamic> map,String id,String userId)async{
    await _usersCollection.doc(userId).collection(DIARIES_OF_FOLLOWING_COLLECTION).doc(id).update({Diaries.DIARY_LIKER: FieldValue.arrayUnion([map])});
  }

  Future removeLikerFromDiary(Map<String,dynamic> map,String id)async{
    await _dairiesCollection.doc(id).update({Diaries.DIARY_LIKER: FieldValue.arrayRemove([map])});
  }

  Future removeLikerFromFollowing(Map<String,dynamic> map,String id,String userId)async{
    await _usersCollection.doc(userId).collection(DIARIES_OF_FOLLOWING_COLLECTION).doc(id).update({Diaries.DIARY_LIKER: FieldValue.arrayRemove([map])});
  }

  Future incrementDiaryShares(String id)async{
    await _dairiesCollection.doc(id).update({Diaries.SHARES: FieldValue.increment(1) });
  }

  Future deleteDiary(String id)async{
    await _dairiesCollection.doc(id).delete();
  }

  Future deleteDiaryOfUnFollow(String diaryId,String userId)async{
    await _usersCollection.doc(userId).collection(DIARIES_OF_FOLLOWING_COLLECTION).doc(diaryId).delete();
  }

}