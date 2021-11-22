import 'package:flutter/material.dart';
import 'package:umee/models/diaries_model.dart';
import 'package:umee/repositories/user_provider.dart';
import 'package:umee/screens/view_all_advices.dart';
import 'package:umee/screens/view_all_screen.dart';
import 'package:umee/utils/shared.dart';

class LikesAdvices extends StatelessWidget {
  final List<Advice> advicesList;
  final UserProvider userProvider;
  final List<Admires> likesList;

  const LikesAdvices({Key key, this.advicesList, this.userProvider, this.likesList}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          centerTitle: true,
          title: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Diary Interactions',style: TextStyle(color: textColor,fontSize: 19),),
          ),
          backgroundColor: bar,
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: textColor,
            tabs: [
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text('Liked by',style: TextStyle(color: textColor,fontSize: 18),),
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text('Advice by',style: TextStyle(color: textColor,fontSize: 18),),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            likesList.isNotEmpty || likesList != null?
            ViewAllScreen(title: '',list: likesList,userProvider: userProvider,)
                : Center(child: RefreshProgressIndicator(backgroundColor: icons,)),
            advicesList.isNotEmpty || advicesList != null?
            ViewAllAdvices(title: '',list: advicesList,userProvider: userProvider,)
                : Center(child: RefreshProgressIndicator(backgroundColor: icons,)),
          ],
        ),
      ),
    );
  }
}
