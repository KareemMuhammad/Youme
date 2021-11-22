import 'package:flutter/material.dart';
import 'package:umee/models/diaries_model.dart';
import 'package:umee/repositories/diary_provider.dart';
import 'package:umee/repositories/user_provider.dart';
import 'package:umee/screens/search.dart';
import 'package:umee/utils/constants.dart';
import 'package:umee/utils/shared.dart';
import 'package:umee/widgets/diary_widget.dart';

class FollowingWidget extends StatefulWidget {
  final DiaryProvider diaryProvider;
  final UserProvider userProvider;
  final String id;
  final ScrollController followScrollController;

  const FollowingWidget({
    @required this.diaryProvider,
    Key key, this.id, this.userProvider, this.followScrollController,
  }) : super(key: key);

  @override
  _FollowingWidgetState createState() => _FollowingWidgetState();
}

class _FollowingWidgetState extends State<FollowingWidget> with AutomaticKeepAliveClientMixin  {

  @override
  void initState() {
    super.initState();
    widget.followScrollController.addListener(scrollListener);
    widget.diaryProvider.fetchNextFollowDiary(widget.id);
  }

  void scrollListener() {
    if (widget.followScrollController.offset >= widget.followScrollController.position.maxScrollExtent
        / 2 && !widget.followScrollController.position.outOfRange) {
      if (widget.diaryProvider.hasNextFollow) {
        widget.diaryProvider.fetchNextFollowDiary(widget.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      backgroundColor: icons,
      onRefresh: () async {
        await Future.delayed(Duration(seconds: 1));
        widget.followScrollController.animateTo(0, duration: Duration(milliseconds: 500), curve: Curves.linear);
        widget.diaryProvider.clearFollowSnap();
        widget.diaryProvider.fetchNextFollowDiary(widget.id);
        },
      child: ListView(
        controller: widget.followScrollController,
        children: [
          StreamBuilder<List<Diaries>>(
              stream: widget.diaryProvider.outFollowingDiariesList,
              builder: (BuildContext context, AsyncSnapshot<List<Diaries>> snapshot) {
                 return snapshot.hasData && widget.diaryProvider.followingSnap.isNotEmpty?
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return DiaryWidget(
                      diary: snapshot.data[index],
                      diaryProvider: widget.diaryProvider,
                      youMeProvider: widget.userProvider,
                    );
                  },
                )
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                       const SizedBox(height: 60,),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('People you follow don\'t have diaries yet!',style: TextStyle(fontSize: 19,color: textColor),),
                      ),
                     Padding(
                      padding: const EdgeInsets.all(10),
                      child: RaisedButton(
                        color: icons,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        elevation: 2,
                        onPressed: () async{
                          await showSearch(context: context, delegate: DataSearch(userProvider: widget.userProvider,
                              list: widget.userProvider.usersList,diariesList: widget.diaryProvider.getPublicDiaries,diaryProvider: widget.diaryProvider));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Go Follow Someone',style: TextStyle(letterSpacing: 1,fontSize: 18,color: textColor),),
                        ),
                      ),
                    ),
                  ],
                );
              }),
          if (widget.diaryProvider.hasNextFollow)
            Center(
              child: GestureDetector(
                onTap: () {
                  widget.diaryProvider.fetchNextFollowDiary(widget.id);
                },
                child: Container(
                  height: 25,
                  width: 25,
                  child: CircularProgressIndicator(backgroundColor: icons,),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}