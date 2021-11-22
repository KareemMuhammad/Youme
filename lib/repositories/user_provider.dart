import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:umee/models/diaries_model.dart';
import 'package:umee/models/reminder_model.dart';
import 'package:umee/models/notification_model.dart';
import 'package:umee/models/user_model.dart';
import 'package:umee/repositories/diary_provider.dart';
import 'package:umee/repositories/user_repository.dart';
import 'package:umee/utils/constants.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:uuid/uuid.dart';

enum Page{DIARIES,ADVICES,SECRETS,WILL}
enum OthersPage{DIARIES,ADVICES,INFO}
enum HomeState{LOADED,WAITING}
enum PostChoice{WORDS,OTHERS}

class UserProvider extends ChangeNotifier{
  final _googleUser = GoogleSignIn();
  final _facebookLogin = FacebookAuth.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  HomeState _currentState = HomeState.WAITING;
  YouMeUser _user;
  final UserRepository _userRepository = UserRepository();
  User _currentUser;
  bool isLoading = false;
  List<YouMeUser> _allUsersList = [];
  Page _currentPage = Page.DIARIES;
  OthersPage _othersPage = OthersPage.DIARIES;
  PostChoice _currentChoice = PostChoice.WORDS;
  int _index = 0;
  YouMeUser _userOfDiary;
  String _videoPath = '';
  List<String> _imagePath = [];
  String _recordPath = '';
  String _postCategory = '';
  String _willCategory = '';
  String _publishIfAwayTime = '6 months';
  int _selectedPublishRadio = 1;
  List<Admires> _taggedPerson = [];
  List<ParticipantModel> _participatePerson = [];
  int _postIndex = 0;
  List<String> _registrationIdsList = [];
  int _bottomBarIndex = 0;
  bool _othersLoaded = true;
  SharedPreferences _prefs;

  UserProvider(User user){
    this._currentUser =  user;
  }

  ////////////////// user /////////////////////

  YouMeUser get getUser => _user;
  YouMeUser get userOfDiary => _userOfDiary;
  User get getFireUser => _currentUser;
  List<YouMeUser> get usersList => _allUsersList;
  Page get page => _currentPage;
  OthersPage get getOthersPage => _othersPage;
  PostChoice get choice => _currentChoice;
  int get currentIndex => _index;
  int get currentPostIndex => _postIndex;
  String get getVideoPath => _videoPath;
  List<String> get getImagePath => _imagePath;
  String get getRecordPath => _recordPath;
  String get getCategoryPath => _postCategory;
  String get getWillCategoryPath => _willCategory;
  String get getDiePublishTime => _publishIfAwayTime;
  List<Admires> get person => _taggedPerson;
  List<ParticipantModel> get participate => _participatePerson;
  HomeState get myState => _currentState;
  List<String> get registers => _registrationIdsList;
  int get getBarIndex => _bottomBarIndex;
  bool get getOthersBool => _othersLoaded;
  SharedPreferences get getPrefs => _prefs;
  int get getSelectedPublish => _selectedPublishRadio;

  void refreshUser() async {
    try{
      if(_currentUser != null){
        List<Admires> followingList = [];
        List<Admires> followersList = [];
        YouMeUser initUser;
        initUser = await  _userRepository.getUserById(_currentUser.uid);
        if(_user != initUser) {
          _user = initUser;
          for (String id in _user.followingIDs) {
            YouMeUser user = await getUserOfDiary(id);
            Admires admire = Admires.add(userId: user.id,
                userImage: user.image,
                userName: user.name,
                userToken: user.token);
            followingList.add(admire);
          }
          for (String id in _user.followersIDs) {
            YouMeUser user = await getUserOfDiary(id);
            Admires admire = Admires.add(userId: user.id,
                userImage: user.image,
                userName: user.name,
                userToken: user.token);
            followersList.add(admire);
          }
          _user.setFollowing(followingList);
          _user.setFollowers(followersList);
          print('user');
        }
      }else{
        return null;
      }
    }catch(e){
      print(e.toString());
      _currentState = HomeState.WAITING;
    }
    notifyListeners();
  }

  void setPublishTime(String time){
    this._publishIfAwayTime = time;
    notifyListeners();
  }

  void setPublishRadio(int radio){
    this._selectedPublishRadio = radio;
    notifyListeners();
  }

  void setPrefs()async{
    _prefs = await UserRepository.shared();
    notifyListeners();
  }

  void setOthersBool(bool follow){
    this._othersLoaded = follow;
  }

  void setPerson(Admires person){
    this._taggedPerson.add(person);
    notifyListeners();
  }

  void setParticipate(ParticipantModel person){
    this._participatePerson.add(person);
    notifyListeners();
  }

  void clearParticipate(int index){
    this._participatePerson.removeAt(index);
    notifyListeners();
  }

  void setRegisters(String token){
    this._registrationIdsList.add(token);
    notifyListeners();
  }

  void setBarIndex(int index){
    this._bottomBarIndex = index;
    notifyListeners();
  }

  void clearPerson(int index){
    this._taggedPerson.removeAt(index);
    notifyListeners();
  }

  void clearRegisters(int index){
    this._registrationIdsList.removeAt(index);
    notifyListeners();
  }

  void setVideoPath(String path){
    this._videoPath = path;
    notifyListeners();
  }

  void setImagePath(dynamic path){
    this._imagePath.add(path);
    notifyListeners();
  }

  void setRecordPath(String path){
    this._recordPath = path;
    notifyListeners();
  }

  void setPostCategory(String path){
    this._postCategory = path;
    notifyListeners();
  }

  void setWillCategory(String path){
    this._willCategory = path;
    notifyListeners();
  }

  void setLoadState(HomeState state){
    this._currentState = state;
  }

  void resetCategoryIndex(){
    _index = 0;
    _currentPage = Page.DIARIES;
    _othersPage = OthersPage.DIARIES;
  }

  reloadProfilePage(String page){
    switch(page){
      case Utils.MY_DIARIES :
        _currentPage = Page.DIARIES;
        _index = 0;
        notifyListeners();
        break;
      case Utils.MY_ADVICES :
        _currentPage = Page.ADVICES;
        _index = 1;
        notifyListeners();
        break;
      case Utils.MY_SECRETS :
        _currentPage = Page.SECRETS;
        _index = 2;
        notifyListeners();
        break;
      case Utils.MY_WILL :
        _currentPage = Page.WILL;
        _index = 3;
        notifyListeners();
        break;
      default : _currentPage = Page.DIARIES;
    }
  }

  reloadOthersProfilePage(String page){
    switch(page){
      case 'Diaries' :
        _othersPage = OthersPage.DIARIES;
        _index = 0;
        notifyListeners();
        break;
      case 'Advices' :
        _othersPage = OthersPage.ADVICES;
        _index = 1;
        notifyListeners();
        break;
      case 'Info' :
        _othersPage = OthersPage.INFO;
        _index = 2;
        notifyListeners();
        break;
      default : _othersPage = OthersPage.DIARIES;
    }
  }

  reloadPostChoice(String choice){
    switch(choice){
      case Utils.WORDS :
        _currentChoice = PostChoice.WORDS;
        _postIndex = 0;
        notifyListeners();
        break;
      case Utils.OTHERS :
        _currentChoice = PostChoice.OTHERS;
        _postIndex = 1;
        notifyListeners();
        break;
      default : _currentChoice = PostChoice.WORDS;
    }
  }

  void updateToken(String token)async{
    await _userRepository.updateUserToken(token, _auth.currentUser.uid);
    refreshUser();
    notifyListeners();
  }

  void updateName(String name,DiaryProvider diaryProvider)async{
    await _userRepository.updateUSerName(name, _auth.currentUser.uid);
    diaryProvider.updateDiariesOfUserName(name);
    diaryProvider.updateAdviceName(getUser.id, name);
    diaryProvider.updateDiariesLikerName(getUser.id, name);
    final ParticipantModel currentInModel = ParticipantModel.add(userId: getUser.id,userName: getUser.name,
        userImage: getUser.image,userToken: getUser.token,userStatus: 'in');
    final ParticipantModel currentWaitModel = ParticipantModel.add(userId: getUser.id,userName: getUser.name,
        userImage: getUser.image,userToken: getUser.token,userStatus: 'waiting');

    final ParticipantModel newInModel = ParticipantModel.add(userId: getUser.id,userName: name,
        userImage: getUser.image,userToken: getUser.token,userStatus: 'in');
    final ParticipantModel newWaitModel = ParticipantModel.add(userId: getUser.id,userName: name,
        userImage: getUser.image,userToken: getUser.token,userStatus: 'waiting');
    await updateRemindersOfUserParticipate(currentInModel,newInModel);
    await updateRemindersOfUserParticipate(currentWaitModel,newWaitModel);
    refreshUser();
    notifyListeners();
  }

  void updateGender(String gender)async{
    await _userRepository.updateUSerGender(gender, _auth.currentUser.uid);
    refreshUser();
    notifyListeners();
  }

  void updateBirth(String birth)async{
    await _userRepository.updateUSerBirth(birth, _auth.currentUser.uid);
    refreshUser();
    notifyListeners();
  }

  void updateLocation(String location)async{
    await _userRepository.updateUSerLocation(location, _auth.currentUser.uid);
    refreshUser();
    notifyListeners();
  }

  void updateAbout(String about)async{
    await _userRepository.updateUSerAbout(about, _auth.currentUser.uid);
    refreshUser();
    notifyListeners();
  }

  void saveNotification(NotificationModel notificationModel)async{
    await _userRepository.saveNotificationToUserDb(notificationModel, _auth.currentUser.uid);
    refreshUser();
    notifyListeners();
  }

  void refreshAllUsers() async {
    try{
      if(_auth.currentUser != null){
        _allUsersList = await _userRepository.getAllUsers();
        print('all');
      }else{
        return null;
      }
    }catch(e){
      print(e.toString());
    }
    notifyListeners();
  }

  void refreshUserOfDiary(String id) async {
        _userOfDiary = await  _userRepository.getUserById(id);
        setOthersBool(false);
        print('others');
        notifyListeners();
  }

  void setUserOfDiary() async {
    _userOfDiary = null;
    notifyListeners();
  }

  void uploadImage(String path)async{
    String uuid = Uuid().v4();
    UploadTask task = FirebaseStorage.instance.ref().child(uuid).putFile(File(path));
    TaskSnapshot snapshot = await task.then((snapshot) async{
      String fileUrl = await snapshot.ref.getDownloadURL();
      setImagePath(fileUrl);
      return snapshot;
    });
  }

  void uploadVideo(String path)async{
    String uuid = Uuid().v4();
    UploadTask task = FirebaseStorage.instance.ref().child(uuid).putFile(File(path));
    TaskSnapshot snapshot = await task.then((snapshot) async{
      String fileUrl = await snapshot.ref.getDownloadURL();
      setVideoPath(fileUrl);
      return snapshot;
    });
  }

  void uploadRecord(String path)async{
    String uuid = Uuid().v4();
    UploadTask task = FirebaseStorage.instance.ref().child(
        uuid).putFile(File(path));
    TaskSnapshot snapshot = await task.then((snapshot) async {
      String fileUrl = await snapshot.ref.getDownloadURL();
      setRecordPath(fileUrl);
      return snapshot;
    });
  }

  void uploadProfileCamera(String path,DiaryProvider diaryProvider,String uuid,String name)async{
    UploadTask task = FirebaseStorage.instance.ref().child('$uuid $name').putFile(File(path));
    TaskSnapshot snapshot = await task.then((snapshot) async{
      String fileUrl = await snapshot.ref.getDownloadURL();
      updateUserImage(fileUrl);
      diaryProvider.updateDiariesOfUserImage(fileUrl);
      final ParticipantModel currentInModel = ParticipantModel.add(userId: getUser.id,userName: getUser.name,
          userImage: getUser.image,userToken: getUser.token,userStatus: 'in');
      final ParticipantModel currentWaitModel = ParticipantModel.add(userId: getUser.id,userName: getUser.name,
          userImage: getUser.image,userToken: getUser.token,userStatus: 'waiting');

      final ParticipantModel newInModel = ParticipantModel.add(userId: getUser.id,userName: getUser.name,
          userImage: fileUrl,userToken: getUser.token,userStatus: 'in');
      final ParticipantModel newWaitModel = ParticipantModel.add(userId: getUser.id,userName: getUser.name,
          userImage: fileUrl,userToken: getUser.token,userStatus: 'waiting');
      await updateRemindersOfUserParticipate(currentInModel,newInModel);
      await updateRemindersOfUserParticipate(currentWaitModel,newWaitModel);
      diaryProvider.updateAdviceImage(getUser.id, fileUrl);
      diaryProvider.updateDiariesLikerImage(getUser.id, fileUrl);
      return snapshot;
    });
  }

 Future<List<Admires>> getUserAdmires(List<dynamic> admiresId)async{
    List<Admires> convertedAdmires = [];
    for(String id in admiresId){
      YouMeUser user = await getUserOfDiary(id);
      Admires admire = Admires.add(userId: user.id,
          userImage: user.image,
          userName: user.name,
          userToken: user.token);
      convertedAdmires.add(admire);
    }
    return convertedAdmires;
  }

  Future<YouMeUser> getUserOfDiary(String id) async {
    YouMeUser user;
    user = await  _userRepository.getUserById(id);
    return user;
  }

  // sign up with email
  Future<bool> signUpUserWithEmailPass(String email, String pass) async {
    try {
      var authResult = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: pass,
      );
      print("REPO : ${authResult.user.email}");
      bool newUser = await _userRepository.authenticateUser(authResult.user);
      if(newUser == true){
        YouMeUser youMeUser = YouMeUser.create(id: authResult.user.uid,email: email,password: pass,name: '',birthday: ''
            ,location: '',gender: '',about: '',followers: [],following: [],image: '',likedDiariesIDs: [],diariesNo: 0);
       await _userRepository.saveUserToDb(youMeUser.toMap(), authResult.user.uid);
        refreshAllUsers();
        refreshUser();
        notifyListeners();
        return true;
      } else {
    notifyListeners();
    return false;
      }
    }  catch (e) {
      String authError = e.toString();
      print(authError);
      notifyListeners();
      return false;
    }
  }

  // sign in with email and password
  Future<bool> signInEmailAndPassword(String email, String password) async {
    try {
      var authresult = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      bool newUser = await _userRepository.authenticateUser(authresult.user);
      print(newUser);
      refreshUser();
      refreshAllUsers();
      notifyListeners();
      return newUser;
    } catch (e) {
      String authError = e.toString();
      print(authError);
      notifyListeners();
      return true;
    }
  }

  Future<bool> signUpFacebook(AuthCredential email,Map<String,dynamic> data) async{
    try {
      final result = await _auth.signInWithCredential(email);
      User user = result.user;
      bool newUser = await _userRepository.authenticateFacebookAndGoogle(user);
      print(newUser);
      if(newUser == true){
        YouMeUser youMeUser = YouMeUser.create(id: user.uid,email: data[YouMeUser.EMAIL] ?? '',password: '',
            name: data[YouMeUser.FULL_NAME] ?? '',birthday: data[YouMeUser.BIRTHDAY] ?? ''
            ,location: '',gender: data[YouMeUser.GENDER] ?? '',about: '',followers: [],
            following: [],image: '',likedDiariesIDs: [],diariesNo: 0);
        await _userRepository.saveUserToDb(youMeUser.toMap(), user.uid);
        refreshUser();
        refreshAllUsers();
        notifyListeners();
        return true;
      }else{
        refreshUser();
        refreshAllUsers();
        notifyListeners();
        return false;
      }
    }catch(e){
      print(e.toString());
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUpGoogle(AuthCredential credential,String email,String name) async {
    try {
      final result = await _auth.signInWithCredential(credential);
      User user = result.user;
      bool newUser = await _userRepository.authenticateFacebookAndGoogle(user);
      print(newUser);
      if(newUser == true){
        YouMeUser youMeUser = YouMeUser.create(id: user.uid,email: email ?? '',password: '',name: name ?? '',birthday: ''
            ,location: '',gender: '',about: '',followers: [],following: [],image: '',likedDiariesIDs: [],diariesNo: 0);
       await _userRepository.saveUserToDb(youMeUser.toMap(), user.uid);
        refreshUser();
        refreshAllUsers();
        notifyListeners();
        return true;
      }else{
        refreshUser();
        refreshAllUsers();
        notifyListeners();
        return false;
      }
    }catch(e){
      print(e.toString());
      notifyListeners();
      return false;
    }
  }

  Future resetPassword(String email)async{
    try{
      await _auth.sendPasswordResetEmail(email: email);
      refreshUser();
      notifyListeners();
    }catch(e){
      print(e.toString());
      notifyListeners();
    }
  }

  Future signOut()async{
    try{
      if(_googleUser.currentUser != null) {
        await _googleUser.signOut();
      }
      if (_facebookLogin.accessToken != null) {
        _facebookLogin.logOut();
      }
      if(_auth.currentUser != null) {
        await _auth.signOut();
      }
      notifyListeners();
      getCurrentUser();
    }catch(e){
      print(e.toString());
      notifyListeners();
    }
  }

  refreshLoading(){
    isLoading = !isLoading;
    notifyListeners();
  }

 Future getCurrentUser() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    notifyListeners();
  }

  Future deleteUser() async {
    try {
    await _userRepository.deleteUserFromDb(_auth.currentUser.uid);
    await getFireUser.delete();
    signOut();
    notifyListeners();
    }on PlatformException catch (e){
      print(e.message);
    }
  }

  Future deleteReminder(String id) async {
    await _userRepository.deleteReminderFromDb(id);
    notifyListeners();
  }

  Future deleteHistory(String id) async {
    await _userRepository.deleteHistoryFromDb(id);
    notifyListeners();
  }

  void updateUserProfile(YouMeUser youMeUser)async{
    await _userRepository.updateUSerProfile(youMeUser.toMap(), _auth.currentUser.uid);
    refreshUser();
    notifyListeners();
  }

  void updateUserImage(String image)async{
    await _userRepository.updateUSerImage(image, _auth.currentUser.uid);
    refreshUser();
    notifyListeners();
  }

  void updateUserEmail(String email)async{
    try {
      var credential = EmailAuthProvider.credential(email: getFireUser.email, password: getUser.password);
      await getFireUser.reauthenticateWithCredential(credential);
      await _auth.currentUser.updateEmail(email);
      await _userRepository.updateUSerEmail(email, _auth.currentUser.uid);
      refreshUser();
      notifyListeners();
    }on PlatformException catch (e){
      print(e.message);
    }
  }

  void updateUserSecretsPass(String pass)async{
    await _userRepository.updateUSerSecretsPassword(pass, _auth.currentUser.uid);
    refreshUser();
    notifyListeners();
  }

  void updateUserDiaryNumber()async{
    await _userRepository.updateUSerDiaryNumber(_auth.currentUser.uid);
    refreshUser();
    notifyListeners();
  }

  void updateUserLastActive(String date)async{
    await _userRepository.updateUSerLastActiveDate(date,_auth.currentUser.uid);
    print('last active');
    notifyListeners();
  }

  void decrementUserDiaryNumber()async{
    await _userRepository.decrementUSerDiaryNumber(_auth.currentUser.uid);
    refreshUser();
    notifyListeners();
  }

  void updateUserLikedDiary(String diaries)async{
    await _userRepository.updateUserLikedDiaries(diaries, _auth.currentUser.uid);
    refreshUser();
    notifyListeners();
  }

  void removeUserLikedDiary(String diaries)async{
    await _userRepository.removeUserLikedDiaries(diaries, _auth.currentUser.uid);
    refreshUser();
    notifyListeners();
  }
  
////////////////////////////////////Reminder///////////////////////////////////////////
  
  Future<List<ReminderModel>> fetchRemindersOfUser(String userID)async{
    try {
      if(FirebaseAuth.instance.currentUser != null){
        print('user reminder');
        List<ReminderModel> list;
        list = await _userRepository.getReminderById(userID);
        return list;
      }else{
        return [];
      }
    }catch(e){
      print(e.toString());
      return [];
    }
  }

  Future<List<ReminderModel>> fetchHistoryOfUser(String userID)async{
    try {
      if(FirebaseAuth.instance.currentUser != null){
        print('user history');
        List<ReminderModel> list;
        list = await _userRepository.getReminderHistoryById(userID);
        return list;
      }else{
        return [];
      }
    }catch(e){
      print(e.toString());
      return [];
    }
  }


  Future<List<ReminderModel>> fetchRemindersOfUserParticipate(ParticipantModel admire)async{
    try {
      if(FirebaseAuth.instance.currentUser != null){
        print('user part');
        List<ReminderModel> list;
        list = await _userRepository.getReminderByParticipant(admire);
        return list;
      }else{
        return [];
      }
    }catch(e){
      print(e.toString());
      return [];
    }
  }

 Future updateRemindersOfUserParticipate(ParticipantModel current,ParticipantModel newPart)async{
    try {
      if(FirebaseAuth.instance.currentUser != null){
        print('user part update');
        List<ReminderModel> list;
        list = await _userRepository.getReminderByParticipant(current);
        for(ReminderModel model in list){
          for(ParticipantModel part in model.taggedList){
            if(part.userId == getUser.id){
              await _userRepository.cancelParticipantImage(current.toMap(), model.id);
              await _userRepository.updateParticipantImage(newPart.toMap(), model.id);
            }
          }
        }
      }
    }catch(e){
      print(e.toString());
    }
  }

  void addNewReminder(ReminderModel reminderModel,String id)async{
     await _userRepository.saveReminderToDb(reminderModel.toMap(),id);
    notifyListeners();
  }

  Future addNewHistory(ReminderModel reminderModel,String id)async{
    await _userRepository.saveReminderToHistory(reminderModel.toMap(),id);
    notifyListeners();
  }
  
  Future updatePartStat(ParticipantModel admires,String id)async{
    await _userRepository.updateParticipantStatus(admires.toMap(), id);
    notifyListeners();
  }

  Future cancelPartStat(ParticipantModel admires,String id)async{
    await _userRepository.cancelParticipantStatus(admires.toMap(), id);
    notifyListeners();
  }
  
///////////////////////////////////////////////////////////////////////////////
  
 void updateUserFeedHiddenDiaries(String diaryID,String id)async{
    await _userRepository.updateUserFeedHiddenDiaries(diaryID, id);
    refreshUser();
    notifyListeners();
  }

  void cancelUserFeedHiddenDiaries(String diaryID,String id)async{
    await _userRepository.removeUserFeedHiddenDiaries(diaryID, id);
    refreshUser();
    notifyListeners();
  }

   updateFollowId(String userId)async{
    await _userRepository.updateFollowingIds(userId, _auth.currentUser.uid);
    refreshUser();
    notifyListeners();
  }
   updateFollowersId(String userId)async{
    await _userRepository.updateFollowersIds(userId, _auth.currentUser.uid);
    notifyListeners();
  }

  Future removeFollowersId(String userId)async{
    await _userRepository.deleteFollowersIds(userId, _auth.currentUser.uid);
    notifyListeners();
  }

  Future removeFollowId(String userId)async{
    await _userRepository.deleteFollowingIds(userId, _auth.currentUser.uid);
    refreshUser();
    notifyListeners();
  }

  void addFollower(Admires admire)async{
    Admires me = Admires.add(userImage: getUser.image,userName: getUser.name,userId: getUser.id,userToken: getUser.token);
    await _userRepository.followUser(admire.toMap(), _auth.currentUser.uid,me);
    refreshUserOfDiary(admire.userId);
    notifyListeners();
  }

  void removeFollower(Admires admire)async{
    Admires me = Admires.add(userImage: getUser.image,userName: getUser.name,userId: getUser.id,userToken: getUser.token);
    await _userRepository.unFollowUser(admire.toMap(), _auth.currentUser.uid,me);
    refreshUserOfDiary(admire.userId);
    notifyListeners();
  }

  void blockUser(String userId,Admires admire)async{
    await _userRepository.blockUser(_auth.currentUser.uid, userId);
      removeFollowId(userId);
      removeFollower(admire);
      removeFollowersId(userId);
    refreshUser();
    notifyListeners();
  }

  void unBlockUser(String userId)async{
    await _userRepository.unBlockUser(_auth.currentUser.uid, userId);
    refreshUser();
    notifyListeners();
  }

  bool followingCheck(String id,YouMeUser user){
    return user.followingIDs.contains(id) ? true : false;
  }

  bool isUserBlocked(String id,YouMeUser user){
    return user.blocked.contains(id) ? true : false;
  }

  String getNotificationTime(String date){
    DateTime time = DateTime.parse(date);
    String timeAgo = timeago.format(time);
    return timeAgo;
  }

}