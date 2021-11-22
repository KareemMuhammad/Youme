import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:umee/models/diaries_model.dart';
import 'package:umee/models/reminder_model.dart';
import 'package:umee/repositories/user_provider.dart';
import 'package:umee/utils/constants.dart';
import '../utils/shared.dart';

class WhoSearch extends SearchDelegate<String>{
  final List<Admires> list;
  final UserProvider userProvider;
  final bool tag;
  List<Admires> usersOfQuery = [];
  WhoSearch({this.tag, this.userProvider, this.list});

  List<Admires> getUsers(){
    List<Admires>  usersList = [];
    list.forEach((user) {
      if(user.userName.toLowerCase().contains(query) && user.userId != userProvider.getUser.id){
        usersList.add(user);
      }
    });
    return usersList;
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
    usersOfQuery = getUsers();
    return Card(
      elevation: 5,
      color: background,
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(16),
        child: usersOfQuery == null || usersOfQuery.length == 0 ?
        Center(
            child: Text('no results',style: TextStyle(fontSize: 20,color: textColor),)
        )
            :ListView.builder(
             itemCount: usersOfQuery.length ?? 0,
             itemBuilder: (context, index) {
              return usersOfQuery.length == 0?
              Center(
                  child: Text('no results',style: TextStyle(fontSize: 20,color: textColor),)
              )
                  :ListTile(
                    onTap: (){
                      if(tag == true) {
                        ParticipantModel waitingModel = ParticipantModel.add(userStatus: Utils.WAITING,userImage: usersOfQuery[index].userImage,
                            userToken: usersOfQuery[index].userToken, userName: usersOfQuery[index].userName,userId: usersOfQuery[index].userId);
                        userProvider.setParticipate(waitingModel);
                        userProvider.setPerson(usersOfQuery[index]);
                        userProvider.setRegisters(usersOfQuery[index].userToken);
                      }
                      Navigator.pop(context,usersOfQuery[index].userName);
                    },
                    leading: Padding(
                        padding: EdgeInsets.fromLTRB(8,8,0,8),
                        child: usersOfQuery[index].userImage.isNotEmpty ? CachedNetworkImage(
                          imageUrl: usersOfQuery[index].userImage,
                          progressIndicatorBuilder: (context, url, downloadProgress) =>
                              CircularProgressIndicator(value: downloadProgress.progress),
                          errorWidget: (context, url, error) => Icon(Icons.error),
                        ) : Image.asset('assets/pic.jpg')
                    ),
                    title: Text(usersOfQuery[index].userName,style: TextStyle(
                        color: textColor,
                        fontSize: 18
                ),),
              );
            }
        ),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    usersOfQuery = getUsers();
    return ListView.builder(
        itemCount: usersOfQuery.length,
        itemBuilder: (context,index) {
          return Column(
              children: [
                ListTile(
                  onTap: () {
                    if(tag == true) {
                      ParticipantModel waitingModel = ParticipantModel.add(userStatus: Utils.WAITING,userImage: usersOfQuery[index].userImage,
                          userToken: usersOfQuery[index].userToken, userName: usersOfQuery[index].userName,userId: usersOfQuery[index].userId);
                      userProvider.setParticipate(waitingModel);
                      userProvider.setPerson(usersOfQuery[index]);
                      userProvider.setRegisters(usersOfQuery[index].userToken);
                    }
                    Navigator.pop(context,usersOfQuery[index].userName);
                  },
                  title:  Text(usersOfQuery[index].userName,style: TextStyle(fontSize: 20,color: textColor)),
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundColor: textColor,
                    backgroundImage: usersOfQuery[index].userImage.isEmpty ? AssetImage('assets/pic.jpg')
                        : NetworkImage(usersOfQuery[index].userImage),
                  ),
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