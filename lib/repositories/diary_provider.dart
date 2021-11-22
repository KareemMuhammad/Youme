import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:umee/models/diaries_model.dart';
import 'package:umee/models/user_model.dart';
import 'package:umee/repositories/diary_repository.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:umee/utils/constants.dart';

enum FollowingDiariesState{LOADED,WAITING}
enum PublicDiariesState{LOADED,WAITING}
class DiaryProvider extends ChangeNotifier{
  DiaryRepository _diaryRepository = DiaryRepository();
  List<Diaries> _diariesList = [];
  List<Diaries> _diariesOfFollowingList = [];
  List<Diaries> _diariesOfPublicList = [];
  List<Diaries> _diariesOfUserList = [];
  List<Diaries> _diariesOfSecretsList = [];
  List<Diaries> _diariesOfWillList = [];
  Diaries _diaries;
  bool homeBool = false;
  final _publicDiariesSnapshot = <DocumentSnapshot>[];
  final _followingDiariesSnapshot = <DocumentSnapshot>[];
  final _userDiariesSnapshot = <DocumentSnapshot>[];
  String _errorMessage = '';
  int documentLimit = 5;
  int followDocumentLimit = 4;
  bool _hasNextPublic = true;
  bool _isFetchingPublicDiaries = false;
  bool _hasNextFollowing = true;
  bool _isFetchingFollowDiaries = false;
  bool _hasNextUserDiaries = true;
  bool _isFetchingUserDiaries = false;
  StreamController<List<Diaries>> _diariesListController = StreamController.broadcast();
  Stream<List<Diaries>> get outDiariesList => _diariesListController.stream;
  Sink<List<Diaries>> get inDiariesList => _diariesListController.sink;
  StreamController<List<Diaries>> _followingDiariesController = StreamController.broadcast();
  Stream<List<Diaries>> get outFollowingDiariesList => _followingDiariesController.stream;
  Sink<List<Diaries>> get inFollowingDiariesList => _followingDiariesController.sink;
  StreamController<List<Diaries>> _userDiariesController = StreamController.broadcast();
  Stream<List<Diaries>> get outUserDiariesList => _userDiariesController.stream;
  Sink<List<Diaries>> get inUserDiariesList => _userDiariesController.sink;

  DiaryProvider(){
    outDiariesList.listen((data) {
      _diariesOfPublicList = data;
    });
    outFollowingDiariesList.listen((data) {
      _diariesOfFollowingList = data;
    });
    outUserDiariesList.listen((data) {
      _diariesOfUserList = data;
    });
  }

  List<Diaries> get getDiaries  => _diariesList;
  List<Diaries> get getUserDiaries  => _diariesOfUserList;
  List<Diaries> get getWillDiaries  => _diariesOfWillList;
  List<Diaries> get getSecretsDiaries  => _diariesOfSecretsList;
  List<Diaries> get getPublicDiaries  => _diariesOfPublicList;
  List<Diaries> get getFollowingDiaries  => _diariesOfFollowingList;
  Diaries get diary => _diaries;
  bool get homeFeed => homeBool;
  String get errorMessage => _errorMessage;
  bool get hasNext => _hasNextPublic;
  bool get hasNextFollow => _hasNextFollowing;
  bool get hasNextUserDiary => _hasNextUserDiaries;

  void addNewDiary(Diaries diaries,String id) async{
    await _diaryRepository.addNewDiaryToDb(diaries, id);
    notifyListeners();
  }

  void refreshHomeFeed(){
    homeBool = !homeBool;
    notifyListeners();
  }

  Future refreshAllDiaries()async{
    try {
      if(FirebaseAuth.instance.currentUser != null){
        _diariesList = await _diaryRepository.getAllDiaries();
        notifyListeners();
      }else{
        return null;
      }
    }catch(e){
      print(e.toString());
      notifyListeners();
    }
  }

  void closeAllStreams(){
    this._followingDiariesSnapshot.clear();
    this._diariesOfFollowingList.clear();
    this._publicDiariesSnapshot.clear();
    this._diariesOfPublicList.clear();
    clearUserStreams();
  }

  void clearUserStreams(){
    this._userDiariesSnapshot.clear();
    this._diariesOfUserList.clear();
  }

  void postDiaryToFollowers(YouMeUser user,Diaries diary)async{
    for(String id in user.followersIDs){
      await _diaryRepository.addDiaryToUserCollection(diary.toMap(), id);
    }
  }

  void saveDiariesOfFollow(String id,String myId)async{
  final List<Diaries> list = await _diaryRepository.getAllDiariesOfUserIFollow(id);
    for(Diaries diary in list){
      await _diaryRepository.addDiaryToUserCollection(diary.toMap(), myId);
    }
  }

  void deleteDiariesOfFollow(String id,String myId)async{
    final List<Diaries> list = await _diaryRepository.getAllDiariesOfUserIFollow(id);
    for(Diaries diary in list){
      await _diaryRepository.deleteDiaryOfUnFollow(diary.id, myId);
    }
  }

  void deleteSingleDiaryOfFollow(String diaryId,YouMeUser user)async{
    for(String id in user.followersIDs) {
      await _diaryRepository.deleteDiaryOfUnFollow(diaryId, id);
    }
  }

  List<Diaries> get publicSnap => _publicDiariesSnapshot.map((snap) {
    final diary = snap.data();
    return Diaries.fromJsonObject(diary);
  }).toList();

  Future fetchNextPublicDiary() async {
    if (_isFetchingPublicDiaries ) return;
    _errorMessage = '';
    _isFetchingPublicDiaries = true;
    try {
      final snap = await DiaryRepository.getAllPublicLazyDiaries(documentLimit,
        startAfter: _publicDiariesSnapshot.isNotEmpty ? _publicDiariesSnapshot.last : null,
      );
      _publicDiariesSnapshot.addAll(snap.docs);
       inDiariesList.add(publicSnap);
       print('fetch ${publicSnap.length}');
      if (snap.docs.length < documentLimit) _hasNextPublic = false;
      notifyListeners();
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
    }
    _isFetchingPublicDiaries = false;
  }

  List<Diaries> get followingSnap => _followingDiariesSnapshot.map((snap) {
    final diary = snap.data();
    return Diaries.fromJsonObject(diary);
  }).toList();

  Future fetchNextFollowDiary(String userId) async {
    if (_isFetchingFollowDiaries) return;
    _errorMessage = '';
    _isFetchingFollowDiaries = true;
    try {
        final snap = await DiaryRepository.getAllDiariesOfFollow(userId, followDocumentLimit,
             startAfter: _followingDiariesSnapshot.isNotEmpty? _followingDiariesSnapshot.last : null
        );
        _followingDiariesSnapshot.addAll(snap.docs);
        inFollowingDiariesList.add(followingSnap);
        print(_followingDiariesSnapshot.length);
      if (snap.docs.length < followDocumentLimit ) _hasNextFollowing = false;
      notifyListeners();
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
    }
    _isFetchingFollowDiaries = false;
  }

  List<Diaries> get getUserDiariesSnap => _userDiariesSnapshot.map((snap) {
    final diary = snap.data();
    return Diaries.fromJsonObject(diary);
  }).toList();

  Future fetchNextUserDiary(YouMeUser user) async {
    if (_isFetchingUserDiaries) return;
    _errorMessage = '';
    _isFetchingUserDiaries = true;
    try {
        final snap = await DiaryRepository.getAllDiariesOfUser(
          user.id, documentLimit,
          startAfter: _userDiariesSnapshot.isNotEmpty
              ? _userDiariesSnapshot.last
              : null,);
        _userDiariesSnapshot.addAll(snap.docs);
        _diariesOfUserList = maintainUserList(getUserDiariesSnap);
        _diariesOfUserList.sort((a, b) => b.date.compareTo(a.date));
        inUserDiariesList.add(_diariesOfUserList);
        print('fetch ${snap.docs.length}');
        if (snap.docs.length < documentLimit) _hasNextUserDiaries = false;
        notifyListeners();
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
    }
    _isFetchingUserDiaries = false;
  }

  void updateContentOfUserDiary(Diaries diary,String content) {
    final index = _diariesOfUserList.indexOf(_diariesOfUserList.where((bp) => bp.id == diary.id).first);
    _diariesOfUserList[index].content = content;
    inUserDiariesList.add(_diariesOfUserList);
    notifyListeners();
  }

  void removeLikerFromPublicStreamList(Diaries diary,Admires liker) {
    final index = _diariesOfPublicList.indexOf(_diariesOfPublicList.where((bp) => bp.id == diary.id).first);
    _diariesOfPublicList[index].diaryLikerList.removeWhere((adm) => adm.userId == liker.userId);
    inDiariesList.add(_diariesOfPublicList);
    notifyListeners();
  }

  void addLikerToPublicStreamList(Diaries diary,Admires liker) {
    final index = _diariesOfPublicList.indexOf(_diariesOfPublicList.where((bp) => bp.id == diary.id).first);
    _diariesOfPublicList[index].diaryLikerList.add(liker);
    inDiariesList.add(_diariesOfPublicList);
    notifyListeners();
  }

  void removeAdviceFromPublicStreamList(Diaries diary,Advice liker) {
    final index = _diariesOfPublicList.indexOf(_diariesOfPublicList.where((bp) => bp.id == diary.id).first);
    _diariesOfPublicList[index].advices.removeWhere((adm) => adm.userId == liker.userId);
    inDiariesList.add(_diariesOfPublicList);
    notifyListeners();
  }

  void addAdviceToPublicStreamList(Diaries diary,Advice liker) {
    final index = _diariesOfPublicList.indexOf(_diariesOfPublicList.where((bp) => bp.id == diary.id).first);
    _diariesOfPublicList[index].advices.add(liker);
    inDiariesList.add(_diariesOfPublicList);
    notifyListeners();
  }

  void deleteUserDiaryFromList(Diaries diary) {
    final index = _diariesOfUserList.indexOf(_diariesOfUserList.where((bp) => bp.id == diary.id).first);
    _diariesOfUserList.removeAt(index);
    inUserDiariesList.add(_diariesOfUserList);
    notifyListeners();
  }

  void removeLikerFromFollowingStreamList(Diaries diary,Admires liker) {
    final index = _diariesOfFollowingList.indexOf(_diariesOfFollowingList.where((bp) => bp.id == diary.id).first);
    _diariesOfFollowingList[index].diaryLikerList.removeWhere((adm) => adm.userId == liker.userId);
    inFollowingDiariesList.add(_diariesOfFollowingList);
    notifyListeners();
  }

  void addLikerToFollowingStreamList(Diaries diary,Admires liker) {
    final index = _diariesOfFollowingList.indexOf(_diariesOfFollowingList.where((bp) => bp.id == diary.id).first);
    _diariesOfFollowingList[index].diaryLikerList.add(liker);
    inFollowingDiariesList.add(_diariesOfFollowingList);
    notifyListeners();
  }

  void removeAdviceFromFollowingStreamList(Diaries diary,Advice liker) {
    final index = _diariesOfFollowingList.indexOf(_diariesOfFollowingList.where((bp) => bp.id == diary.id).first);
    _diariesOfFollowingList[index].advices.removeWhere((adm) => adm.userId == liker.userId);
    inFollowingDiariesList.add(_diariesOfFollowingList);
    notifyListeners();
  }

  void addAdviceToFollowingStreamList(Diaries diary,Advice liker) {
    final index = _diariesOfFollowingList.indexOf(_diariesOfFollowingList.where((bp) => bp.id == diary.id).first);
    _diariesOfFollowingList[index].advices.add(liker);
    inFollowingDiariesList.add(_diariesOfFollowingList);
    notifyListeners();
  }

  void removeLikerFromUserList(Diaries diary,Admires liker) {
    final index = _diariesOfUserList.indexOf(_diariesOfUserList.where((bp) => bp.id == diary.id).first);
    _diariesOfUserList[index].diaryLikerList.removeWhere((adm) => adm.userId == liker.userId);
    inUserDiariesList.add(_diariesOfUserList);
    notifyListeners();
  }

  void addLikerToUserList(Diaries diary,Admires liker) {
    final index = _diariesOfUserList.indexOf(_diariesOfUserList.where((bp) => bp.id == diary.id).first);
    _diariesOfUserList[index].diaryLikerList.add(liker);
    inUserDiariesList.add(_diariesOfUserList);
    notifyListeners();
  }

  void removeAdviceFromUserList(Diaries diary,Advice liker) {
    final index = _diariesOfUserList.indexOf(_diariesOfUserList.where((bp) => bp.id == diary.id).first);
    _diariesOfUserList[index].advices.removeWhere((adm) => adm.userId == liker.userId);
    inUserDiariesList.add(_diariesOfUserList);
    notifyListeners();
  }

  void addAdviceToUserList(Diaries diary,Advice liker) {
    final index = _diariesOfUserList.indexOf(_diariesOfUserList.where((bp) => bp.id == diary.id).first);
    _diariesOfUserList[index].advices.add(liker);
    inUserDiariesList.add(_diariesOfUserList);
    notifyListeners();
  }

  void clearPublicSnap()async{
    this._publicDiariesSnapshot.clear();
    this._diariesOfPublicList.clear();
    inDiariesList.add(publicSnap);
    _hasNextPublic = true;
    notifyListeners();
  }

  void clearFollowSnap()async{
    this._followingDiariesSnapshot.clear();
    this._diariesOfFollowingList.clear();
    inFollowingDiariesList.add(followingSnap);
    _hasNextFollowing = true;
    notifyListeners();
  }

  void clearUserSnap(){
    this._userDiariesSnapshot.clear();
    this._diariesOfUserList.clear();
    inUserDiariesList.add(_diariesOfUserList);
    _hasNextUserDiaries = true;
    notifyListeners();
  }

  void updateAdviceName(String id,String name)async{
    await refreshAllDiaries();
    for(Diaries diary in getDiaries){
      for(Advice advice in diary.advices){
        if(advice.userId == id){
          final Advice currentAdvice = Advice.add(content: advice.content,date: advice.date,userId: advice.userId,userImage: advice.userImage,userName: advice.userName);
          final Advice newAdvice = Advice.add(content: advice.content,date: advice.date,userId: advice.userId,userImage: advice.userImage,userName: name);
          await _diaryRepository.deleteAdviceFromDiary(currentAdvice.toMap(), diary.id);
          await _diaryRepository.addAdviceToDiary(newAdvice.toMap(), diary.id);
        }
      }
    }
    notifyListeners();
  }

  void updateAdviceImage(String id,String image)async{
    await refreshAllDiaries();
    for(Diaries diary in getDiaries){
      for(Advice advice in diary.advices){
        if(advice.userId == id){
          final Advice currentAdvice = Advice.add(content: advice.content,date: advice.date,userId: advice.userId,userImage: advice.userImage,userName: advice.userName);
          final Advice newAdvice = Advice.add(content: advice.content,date: advice.date,userId: advice.userId,userImage: image,userName: advice.userName);
          await _diaryRepository.deleteAdviceFromDiary(currentAdvice.toMap(), diary.id);
          await _diaryRepository.addAdviceToDiary(newAdvice.toMap(), diary.id);
        }
      }
    }
    notifyListeners();
  }

  void updateDiariesLikerImage(String id,String image)async{
    await refreshAllDiaries();
    for(Diaries diary in getDiaries){
      for(Admires admire in diary.diaryLikerList){
        if(admire.userId == id){
          final Admires currentAdvice = Admires.add(userId: admire.userId,userImage: admire.userImage,userName: admire.userName,userToken: admire.userToken);
          final Admires newAdvice = Admires.add(userId: admire.userId,userImage: image,userName: admire.userName,userToken: admire.userToken);
          await _diaryRepository.removeLikerFromDiary(currentAdvice.toMap(), diary.id);
          await _diaryRepository.addLikerToDiary(newAdvice.toMap(), diary.id);
        }
      }
    }
    notifyListeners();
  }

  void updateDiariesLikerName(String id,String name)async{
    await refreshAllDiaries();
    for(Diaries diary in getDiaries){
      for(Admires admire in diary.diaryLikerList){
        if(admire.userId == id){
          final Admires currentAdvice = Admires.add(userId: admire.userId,userImage: admire.userImage,userName: admire.userName,userToken: admire.userToken);
          final Admires newAdvice = Admires.add(userId: admire.userId,userImage: admire.userImage,userName: name,userToken: admire.userToken);
          await _diaryRepository.removeLikerFromDiary(currentAdvice.toMap(), diary.id);
          await _diaryRepository.addLikerToDiary(newAdvice.toMap(), diary.id);
        }
      }
    }
    notifyListeners();
  }

  List<Diaries> maintainList(List<Diaries> list,YouMeUser youMeUser){
    List<Diaries> convertedList = [];
    for(Diaries diary in list){
      if(isHiddenDiary(diary, youMeUser))
      convertedList.add(diary);
    }
    return convertedList;
  }

  bool isDiaryLiked(YouMeUser youMeUser, String id){
    bool isLiked = false;
    youMeUser.likedDiariesIDs.forEach((element) {
      if(element == id){
        isLiked = true;
      }
    });
    return isLiked;
  }

  bool isHiddenDiary(Diaries diaries,YouMeUser youMeUser){
    return youMeUser.hiddenDiariesIDs.contains(diaries.id) ? true : false;
  }

  void updateDiariesOfUserImage(String image)async{
    for(Diaries diary in _diariesOfUserList){
      await _diaryRepository.updateDiaryUserImage(image, diary.id);
    }
    notifyListeners();
  }

  void updateDiariesOfUserName(String name)async{
    for(Diaries diary in _diariesOfUserList){
      await _diaryRepository.updateDiaryUserName(name, diary.id);
    }
    notifyListeners();
  }

  Future<List<Diaries>> fetchSecretsOfUser(String userID)async{
    try {
      if(FirebaseAuth.instance.currentUser != null){
        print('secrets');
        _diariesOfSecretsList = await _diaryRepository.getAllSecretsOfUser(userID);
        return _diariesOfSecretsList;
      }else{
        return [];
      }
    }catch(e){
      print(e.toString());
      return [];
    }
  }

  Future<List<Diaries>> fetchWillOfUser(String userID)async{
    try {
      if(FirebaseAuth.instance.currentUser != null){
        print('will');
        _diariesOfWillList = await _diaryRepository.getUserWill(userID);
        return _diariesOfWillList;
      }else{
        return [];
      }
    }catch(e){
      print(e.toString());
      return [];
    }
  }

  Future<List<Diaries>> fetchDiariesByDateOfUser(String userID,String date)async{
    try {
      if(FirebaseAuth.instance.currentUser != null){
        List<Diaries> list;
        List<Diaries> filteredList = [];
        list = await _diaryRepository.getDiaryByDate(date,userID);
        filteredList = maintainUserList(list);
        filteredList.sort((a, b) => b.date.compareTo(a.date));
        return filteredList;
      }else{
        return [];
      }
    }catch(e){
      print(e.toString());
      return [];
    }
  }

  List<Diaries> maintainUserList(List<Diaries> list){
    List<Diaries> convertedList = [];
    for(Diaries diary in list){
      if(diary.category == Utils.PUBLIC || diary.category == Utils.FOLLOWERS || diary.category == Utils.ONLY_DIARIES)
        convertedList.add(diary);
    }
    return convertedList;
  }

  Future refreshSingleDiary(String id)async{
      try{
        _diaries = await _diaryRepository.getDiaryById(id);
        notifyListeners();
      }catch(e){
        print(e.toString());
        notifyListeners();
      }
  }

  String getDiaryTime(String date){
    DateTime time = DateTime.parse(date);
    String timeAgo = timeago.format(time);
    return timeAgo;
  }

  String getAdviceTime(String date){
    DateTime time = DateTime.parse(date);
    String timeAgo = timeago.format(time,locale: 'en_short');
    return timeAgo;
  }

  void deleteDiary(String id)async{
    await _diaryRepository.deleteDiary(id);
    notifyListeners();
  }

  void addNewAdviceToDiary(Advice advice,String id,YouMeUser user)async{
    await _diaryRepository.addAdviceToDiary(advice.toMap(), id);
    refreshSingleDiary(id);
    notifyListeners();
  }

  void addNewAdviceToDiaryOfFollowing(Advice advice,String id,YouMeUser user)async{
    await _diaryRepository.addAdviceToFollowingDiary(advice.toMap(), id,user.id);
    refreshSingleDiary(id);
    notifyListeners();
  }

  Future removeAdviceFromDiary(Advice advice,String id,YouMeUser user)async{
    await _diaryRepository.deleteAdviceFromDiary(advice.toMap(), id);
    refreshSingleDiary(id);
    notifyListeners();
  }

  Future removeAdviceFromFollowingDiary(Advice advice,String id,YouMeUser user)async{
    await _diaryRepository.deleteAdviceFromFollowingDiary(advice.toMap(), id,user.id);
    refreshSingleDiary(id);
    notifyListeners();
  }

  void incrementShares(String id)async{
    await _diaryRepository.incrementDiaryShares(id);
    refreshSingleDiary(id);
    notifyListeners();
  }

  void addLiker(Admires admires,String id,YouMeUser user)async{
    await _diaryRepository.addLikerToDiary(admires.toMap(), id);
    refreshSingleDiary(id);
    notifyListeners();
  }

  void addLikerToFollowing(Admires admires,String id,YouMeUser user)async{
    await _diaryRepository.addLikerToFollowingDiary(admires.toMap(), id,user.id);
    refreshSingleDiary(id);
    notifyListeners();
  }

  void updateDiary(String content,String id,YouMeUser user)async{
    await _diaryRepository.updateDiaryContent(content, id);
    refreshSingleDiary(id);
    notifyListeners();
  }

  void updateDiaryOfFollow(String content,String diaryId,YouMeUser user)async{
    for(String id in user.followersIDs) {
      await _diaryRepository.updateDiaryContentOfFollow(content, diaryId,id);
    }
    refreshSingleDiary(diaryId);
    notifyListeners();
  }

  void removeLiker(Admires admires,String id,YouMeUser user)async{
    await _diaryRepository.removeLikerFromDiary(admires.toMap(), id);
    refreshSingleDiary(id);
    notifyListeners();
  }

  void removeLikerFromFollowing(Admires admires,String id,YouMeUser user)async{
    await _diaryRepository.removeLikerFromFollowing(admires.toMap(), id,user.id);
    refreshSingleDiary(id);
    notifyListeners();
  }

  calculateLastActive(DateTime diaryDate) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - diaryDate.year;
    int month1 = currentDate.month;
    int month2 = diaryDate.month;
    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      int day1 = currentDate.day;
      int day2 = diaryDate.day;
      if (day2 > day1) {
        age--;
      }
    }
    return age;
  }

}