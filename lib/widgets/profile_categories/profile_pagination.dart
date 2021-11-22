import 'package:flutter/material.dart';
import 'package:umee/models/diaries_model.dart';
import 'package:umee/models/user_model.dart';
import 'package:umee/repositories/diary_provider.dart';
import 'package:umee/repositories/user_provider.dart';
import 'package:umee/utils/constants.dart';
import 'package:umee/utils/shared.dart';
import 'package:umee/widgets/diary_widget.dart';
import 'package:umee/widgets/profile_categories/diaries_of_user.dart';

class UserPaginationWidget extends StatefulWidget {
  final DiaryProvider diaryProvider;
  final UserProvider userProvider;
  final YouMeUser user;
  final bool others;

  const UserPaginationWidget({
    @required this.diaryProvider,
    Key key, this.userProvider, this.user, this.others = false,
  }) : super(key: key);

  @override
  _UserPaginationWidgetState createState() => _UserPaginationWidgetState();
}

class _UserPaginationWidgetState extends State<UserPaginationWidget> with AutomaticKeepAliveClientMixin  {
   ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollController.addListener(scrollListener);
    widget.diaryProvider.fetchNextUserDiary(widget.user);
  }

  void scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent /2 && !scrollController.position.outOfRange) {
      if (widget.diaryProvider.hasNextUserDiary) {
        widget.diaryProvider.fetchNextUserDiary(widget.user);
      }
    }
  }

  @override
  Widget build(BuildContext context) =>
   SizedBox(
    height: 500,
     child: RefreshIndicator(
       backgroundColor: icons,
       onRefresh: () async{
         await Future.delayed(Duration(seconds: 1));
         widget.diaryProvider.clearUserSnap();
         widget.diaryProvider.fetchNextUserDiary(widget.user);
       },
       child: ListView(
                key: PageStorageKey<String>(Utils.PROFILE_PREFS_KEY),
                controller: scrollController,
                children: [
                  StreamBuilder<List<Diaries>>(
                          stream: widget.diaryProvider.outUserDiariesList,
                          builder: (BuildContext context,AsyncSnapshot<List<Diaries>> snapshot){
                            return snapshot.hasData && widget.diaryProvider.getUserDiaries.isNotEmpty?
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: snapshot.data.length,
                              itemBuilder: (BuildContext context, int index) {
                                return widget.user.id == widget.userProvider.getUser.id ?
                                ProfileDiariesWidget(diary: snapshot.data[index],diaryProvider: widget.diaryProvider,userProvider: widget.userProvider,):
                                DiaryWidget(diary: snapshot.data[index],diaryProvider: widget.diaryProvider,youMeProvider: widget.userProvider,);
                              },
                            )
                                : Center(child: Text(widget.others ?'${widget.user.name} has no diaries yet' : 'you have no diaries yet',
                              style: TextStyle(color: textColor,fontSize: 18),),);
                          }),
                  if (widget.diaryProvider.hasNextUserDiary)
                    Center(
                      child: GestureDetector(
                        onTap: (){
                          widget.diaryProvider.fetchNextUserDiary(widget.user);
                        } ,
                        child: Container(
                          height: 25,
                          width: 25,
                          child: CircularProgressIndicator(backgroundColor: icons,),
                        ),
                      ),
                    ),
                ],
          ),
     ),
   );

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}