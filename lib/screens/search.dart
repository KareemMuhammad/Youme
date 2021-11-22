import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:umee/models/diaries_model.dart';
import 'package:umee/models/user_model.dart';
import 'package:umee/repositories/diary_provider.dart';
import 'package:umee/repositories/user_provider.dart';
import 'package:umee/screens/others_profile.dart';
import 'package:umee/screens/post_advices_screen.dart';
import 'package:umee/widgets/diary_of_search.dart';
import 'package:umee/widgets/slide.dart';
import '../utils/shared.dart';

class DataSearch extends SearchDelegate<String>{
  final List<YouMeUser> list;
  final UserProvider userProvider;
  final DiaryProvider diaryProvider;
  final List<Diaries> diariesList;
   List<YouMeUser> _usersOfQuery = [];
   List<Diaries> _diariesOfQuery = [];
  DataSearch({this.diaryProvider,this.diariesList,this.userProvider, this.list});

  List<YouMeUser> _getUsers(){
    List<YouMeUser>  usersList = [];
    list.forEach((user) {
      if(user.name.toLowerCase().contains(query) && user.id != userProvider.getUser.id && !userProvider.isUserBlocked(user.id,userProvider.getUser)){
        usersList.add(user);
      }
    });
    return usersList;
  }

  List<Diaries> _getDiaries(){
    List<Diaries>  list = [];
    diariesList.forEach((diary) {
      if(diary.content.toLowerCase().contains(query) && diary.userId != userProvider.getUser.id
          && !userProvider.isUserBlocked(diary.userId,userProvider.getUser) && !diaryProvider.isHiddenDiary(diary, userProvider.getUser)){
        list.add(diary);
      }
    });
    return list;
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context);
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(icon: Icon(Icons.clear),
          onPressed: (){
            query = "";
          }),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(icon: AnimatedIcon(
      icon: AnimatedIcons.menu_arrow,
      progress: transitionAnimation,
    )
        , onPressed: (){
          close(context, null);
        }
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    _usersOfQuery = _getUsers();
    _diariesOfQuery = _getDiaries();
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: background,
          bottom: TabBar(
            indicatorColor: textColor,
            tabs: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('People',style: TextStyle(color: textColor,fontSize: 18),),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Diaries',style: TextStyle(color: textColor,fontSize: 18),),
              ),
          ],
          ),
          leading: Container(),
        ),
        body: TabBarView(
          children: [
            Card(
              elevation: 4,
              color: background,
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(16),
                child: _usersOfQuery == null || _usersOfQuery.length == 0 ?
                Center(
                    child: Text('no results',style: TextStyle(fontSize: 20,color: textColor),)
                )
                    :ListView.builder(
                     itemCount: _usersOfQuery.length ?? 0,
                     itemBuilder: (context, index) {
                      return _usersOfQuery.length == 0?
                      Center(
                          child: Text('no results',style: TextStyle(fontSize: 20,color: textColor),)
                      )
                          :ListTile(
                            onTap: ()async{
                              userProvider.setOthersBool(true);
                              Admires admire = Admires.add(
                                  userId: _usersOfQuery[index].id,
                                  userImage: _usersOfQuery[index].image,
                                  userName: _usersOfQuery[index].name,userToken: _usersOfQuery[index].token);
                              dynamic result = Navigator.push(context, MySlide(widgetBuilder: (_) =>
                                  OthersProfile(admire: admire,)));
                              if(result == 'done'){
                                query = '';
                                close(context, null);
                              }
                            },
                            leading: Padding(
                                padding: EdgeInsets.fromLTRB(8,8,0,8),
                                child: _usersOfQuery[index].image.isNotEmpty ? CachedNetworkImage(
                                  imageUrl: _usersOfQuery[index].image,
                                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                                      CircularProgressIndicator(value: downloadProgress.progress),
                                  errorWidget: (context, url, error) => Icon(Icons.error),
                                ) : Image.asset('assets/pic.jpg')
                            ),
                            title: Text(_usersOfQuery[index].name,style: TextStyle(
                                color: textColor,
                                fontSize: 18
                        ),),
                      );
                    }
                ),
              ),
            ),
            DiariesOfSearch(userProvider: userProvider,diaryProvider: diaryProvider,list: _diariesOfQuery,)
          ],
        ),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> listOfNames = [];
    list.forEach((user) {
      if(user.id != userProvider.getUser.id && !userProvider.isUserBlocked(user.id,userProvider.getUser))
        listOfNames.add(user.name);
    });
    diariesList.forEach((dy) {
      if(dy.userId != userProvider.getUser.id
          && !userProvider.isUserBlocked(dy.userId,userProvider.getUser) && !diaryProvider.isHiddenDiary(dy, userProvider.getUser)){
        listOfNames.add(dy.content);
      }
    });
    List<String> suggestionLists = query.isNotEmpty? listOfNames.where((e) => e.toLowerCase().contains(query)).toList():[];
    return ListView.builder(
      itemCount: suggestionLists.length,
      itemBuilder: (context,index) {
        return Column(
            children: [
              ListTile(
                onTap: () {
                  diariesList.forEach((diary) {
                    if(diary.content == suggestionLists[index]){
                      diaryProvider.refreshSingleDiary(diary.id);
                     Navigator.push(context, MaterialPageRoute(builder: (_) => PostAdvicesScreen(diary: diary,)));
                    }
                  });
                  for(YouMeUser user in list){
                    if(user.name == suggestionLists[index]){
                      userProvider.setOthersBool(true);
                      Admires admire = Admires.add(userId: user.id, userImage: user.image,userName: user.name,userToken: user.token);
                      dynamic result = Navigator.push(context, MySlide(widgetBuilder: (_) => OthersProfile(admire: admire,)));
                      if(result == 'done'){
                        query = '';
                        close(context, null);
                      }
                    }
                  }
                },
                title:  Text(suggestionLists[index],style: TextStyle(fontSize: 20,color: textColor)),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 2, horizontal: 25),
                child: Divider(
                  height: 1,
                  color: grey,
                ),
              )
            ]);
      }
    );
  }
}