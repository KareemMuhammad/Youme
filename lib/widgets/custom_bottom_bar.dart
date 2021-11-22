import 'package:flutter/material.dart';
import 'package:umee/repositories/diary_provider.dart';
import 'package:umee/repositories/user_provider.dart';
import '../utils/shared.dart';

class CustomBottomBar extends StatelessWidget {
  final PageController myPage;
  final UserProvider userProvider;
  final DiaryProvider diaryProvider;

  CustomBottomBar({Key key, this.myPage, this.userProvider, this.diaryProvider}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
        color: bar,
        shape: CircularNotchedRectangle(),
          elevation: 22,
          child: Container(
            padding: EdgeInsets.fromLTRB(2, 2, 6, 2),
            height: 50,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Container(
                  child: IconButton(
                    color: userProvider.getBarIndex == 0 ? icons : textColor,
                    iconSize: 30.0,
                    alignment: Alignment.center,
                    icon: Icon(Icons.home),
                    onPressed: () {
                        myPage.jumpToPage(0);
                        userProvider.setBarIndex(0);
                    },
                  ),
                ),
                Container(
                  child: IconButton(
                    color: userProvider.getBarIndex == 1? icons : textColor,
                    iconSize: 30.0,
                    icon: Icon(Icons.search),
                    onPressed: () {
                      myPage.jumpToPage(1);
                      userProvider.setBarIndex(1);
                    },
                  ),
                ),
                Container(
                  child: IconButton(
                    color: userProvider.getBarIndex == 2? icons : textColor,
                    iconSize: 30.0,
                    icon: Icon(Icons.notifications),
                    onPressed: () {
                      myPage.jumpToPage(2);
                      userProvider.setBarIndex(2);
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

}