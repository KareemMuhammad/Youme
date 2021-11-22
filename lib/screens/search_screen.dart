import 'package:flutter/material.dart';
import 'package:umee/repositories/diary_provider.dart';
import 'package:umee/repositories/user_provider.dart';
import 'package:umee/screens/search.dart';
import '../utils/shared.dart';

class SearchScreen extends StatelessWidget {
  final UserProvider youMeProvider;
  final DiaryProvider diaryProvider;

  const SearchScreen({Key key, this.youMeProvider, this.diaryProvider}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: Container(
        padding: EdgeInsets.all(16),
        child:  Column(
          children: [
            SizedBox(height: 10,),
            Material(
              borderRadius: BorderRadius.circular(10.0),
              color: buttons,
              elevation: 3,
              child: MaterialButton(
                minWidth: MediaQuery.of(context).size.width,
                onPressed: () async{
                  await showSearch(context: context, delegate: DataSearch(userProvider: youMeProvider,
                      list: youMeProvider.usersList,diariesList: diaryProvider.getPublicDiaries,diaryProvider: diaryProvider));
                },
                child: Row(
                  children: [
                    Icon(Icons.search,color: textColor,size: 30,),
                    SizedBox(width: 10,),
                    Text('Search for..',style: TextStyle(fontSize: 18,color: textColor),),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
