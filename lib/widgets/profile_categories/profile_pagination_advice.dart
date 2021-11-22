import 'package:flutter/material.dart';
import 'package:umee/models/diaries_model.dart';
import 'package:umee/models/user_model.dart';
import 'package:umee/repositories/diary_provider.dart';
import 'package:umee/repositories/user_provider.dart';
import 'package:umee/utils/constants.dart';
import 'package:umee/utils/shared.dart';
import 'package:umee/widgets/profile_categories/advice.dart';

class AdvicesPaginationWidget extends StatefulWidget {
  final DiaryProvider diaryProvider;
  final UserProvider userProvider;
  final YouMeUser user;
  final bool others;

  const AdvicesPaginationWidget({
    @required this.diaryProvider,
    Key key, this.userProvider, this.user, this.others = false,
  }) : super(key: key);

  @override
  _AdvicesPaginationWidgetState createState() => _AdvicesPaginationWidgetState();
}

class _AdvicesPaginationWidgetState extends State<AdvicesPaginationWidget> with AutomaticKeepAliveClientMixin {
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollController.addListener(scrollListener);
    widget.diaryProvider.fetchNextUserDiary(widget.user);
  }

  void scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent / 2 && !scrollController.position.outOfRange) {
      if (widget.diaryProvider.hasNextUserDiary) {
        widget.diaryProvider.fetchNextUserDiary(widget.user);
      }
    }
  }

  @override
  Widget build(BuildContext context) =>
      SizedBox(
        height: 500,
        child: ListView(
          key: PageStorageKey<String>(Utils.ADVICE_PREFS_KEY),
          controller: scrollController,
          children: [
            StreamBuilder<List<Diaries>>(
                    stream: widget.diaryProvider.outUserDiariesList,
                    builder: (BuildContext context,AsyncSnapshot<List<Diaries>> snapshot){
                      return snapshot.hasData ?
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ProfileAdviceWidget(adviceList: snapshot.data[index].advices,diaryProvider: widget.diaryProvider,
                            userProvider: widget.userProvider,diaryId: snapshot.data[index].id,) ;
                        }) : Center(child: Text(widget.others ?'${widget.user.name} has no advices yet' : 'you have no advices yet',
                        style: TextStyle(color: textColor,fontSize: 18),),);
                        },
                      ),
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
      );

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}