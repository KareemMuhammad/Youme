import 'package:flutter/material.dart';
import 'package:umee/models/diaries_model.dart';
import 'package:umee/repositories/diary_provider.dart';
import 'package:umee/repositories/user_provider.dart';
import 'package:umee/utils/constants.dart';
import 'package:umee/utils/shared.dart';
import 'package:umee/widgets/diary_widget.dart';

class PublicWidget extends StatefulWidget {
  final DiaryProvider diaryProvider;
  final UserProvider userProvider;
  final ScrollController publicScrollController;
  const PublicWidget({
    @required this.diaryProvider,
    Key key, this.userProvider, this.publicScrollController,
  }) : super(key: key);

  @override
  _PublicWidgetState createState() => _PublicWidgetState();
}

class _PublicWidgetState extends State<PublicWidget> with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    widget.publicScrollController.addListener(scrollListener);
    widget.diaryProvider.fetchNextPublicDiary();
  }

  void scrollListener() {
    if (widget.publicScrollController.offset >= widget.publicScrollController.position.maxScrollExtent
        / 2 && !widget.publicScrollController.position.outOfRange) {
      if (widget.diaryProvider.hasNext) {
        widget.diaryProvider.fetchNextPublicDiary();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
      return RefreshIndicator(
        backgroundColor: icons,
        onRefresh: ()async{
          await Future.delayed(Duration(seconds: 1));
          widget.publicScrollController.animateTo(0, duration: Duration(milliseconds: 500), curve: Curves.linear);
          widget.diaryProvider.clearPublicSnap();
          widget.diaryProvider.fetchNextPublicDiary();
        },
        child: ListView(
          key: PageStorageKey<String>(Utils.PUBLIC_PREFS_KEY),
          controller: widget.publicScrollController,
          children: [
          StreamBuilder<List<Diaries>>(
             stream: widget.diaryProvider.outDiariesList,
             builder: (BuildContext context,AsyncSnapshot<List<Diaries>> snapshot){
              return snapshot.hasData ?
              ListView.builder(
                 shrinkWrap: true,
                 physics: NeverScrollableScrollPhysics(),
                 itemCount: snapshot.data.length,
                 itemBuilder: (BuildContext context, int index) {
                return DiaryWidget(diary: snapshot.data[index],diaryProvider: widget.diaryProvider,youMeProvider: widget.userProvider,);
              },
              )
               : const SizedBox();
        }),
        if (widget.diaryProvider.hasNext)
          Center(
            child: GestureDetector(
              onTap: (){
                widget.diaryProvider.fetchNextPublicDiary();
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
  }

  @override
  bool get wantKeepAlive => true;
}