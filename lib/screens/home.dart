import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:umee/repositories/diary_provider.dart';
import 'package:umee/repositories/user_provider.dart';
import 'package:umee/screens/notifications_screen.dart';
import 'package:umee/screens/search_screen.dart';
import 'package:umee/widgets/pagination_following.dart';
import 'package:umee/widgets/pagination_public.dart';
import '../utils/shared.dart';
import 'package:umee/widgets/custom_bottom_bar.dart';

class MyMainPage extends StatefulWidget {
  final PageController myPage ;
  final UserProvider userProvider;

  const MyMainPage({Key key, this.myPage, this.userProvider}) : super(key: key);

  @override
  _MyMainPageState createState() => _MyMainPageState();
}

class _MyMainPageState extends State<MyMainPage> {
   ScrollController followScrollController = ScrollController();
   ScrollController publicScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final DiaryProvider diaryProvider = Provider.of<DiaryProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: bar,
        elevation: 4,
        centerTitle: true,
        title: Padding(
          padding: EdgeInsets.all(8),
          child: InkWell(
                 onTap: (){
                   if(widget.myPage.page == 0) {
                     if (diaryProvider.homeFeed) {
                       publicScrollController.animateTo(0, duration: Duration(seconds: 1), curve: Curves.linear);
                     } else {
                       followScrollController.animateTo(0, duration: Duration(seconds: 1), curve: Curves.linear);
                     }
                   }
             },
             child: Image.asset("assets/splash.png",height: 60,width: 60,)),
       ),
        leading: Builder(builder: (context) =>
            IconButton(
              icon: Icon(
                Icons.menu,
                size: 30,
                color: textColor,
              ), onPressed: () {
                  Scaffold.of(context).openDrawer();
             },
        ),
        ),
        actions: [
         InkWell(
           onTap: (){
            diaryProvider.refreshHomeFeed();
           },
           child: Padding(
               padding: const EdgeInsets.fromLTRB(0,15,10,10),
             child: diaryProvider.homeFeed ?
             Text('Home',style: TextStyle(color: textColor,fontSize: 17,letterSpacing: 1),) :
             Text('Public',style: TextStyle(color: textColor,fontSize: 17,letterSpacing: 1),)
           ),
         )
        ],
      ),
      drawer: SafeArea(
        child: Drawer(
          elevation: 2,
          child: Container(
            color: background,
            child: Column(
                children: [
                  widget.userProvider.getUser == null ?
                Container()
                : Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6,horizontal: 1),
                    child: ListTile(
                      title: Text(widget.userProvider.getUser.name,style: TextStyle(color: textColor,fontSize: 18,letterSpacing: 1),),
                      subtitle: Text(widget.userProvider.getUser.email,style: TextStyle(color: Colors.white70,fontSize: 15,letterSpacing: 1),),
                      leading: Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: textColor,
                          backgroundImage: widget.userProvider.getUser.image.isEmpty ? AssetImage('assets/pic.jpg')
                              : CachedNetworkImageProvider(widget.userProvider.getUser.image),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5,),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Divider(height: 3,color: icons,),
                  ),
                  ListTile(
                    leading: Icon(Icons.all_inclusive,size: 25,color: textColor,),
                    title: Text('Reminder', style: TextStyle(
                        fontSize: 18,
                        color: textColor
                    ),),
                    onTap: (){
                      Navigator.pop(context);
                      Navigator.pushNamed(context, reminderRoute);
                    },
                  ),
                  new Divider(color: black,height: 10,),
                  ListTile(
                    leading: Icon(Icons.person,size: 25,color: textColor,),
                    title: Text('My Profile',style: TextStyle(
                        fontSize: 18,
                        color: textColor
                    ),),
                    onTap: (){
                      diaryProvider.clearUserStreams();
                      Navigator.pop(context);
                      Navigator.pushNamed(context, profileRoute);
                    },
                  ),
                  new Divider(color: black,height: 10,),
                  ListTile(
                    leading: Icon(Icons.settings,size: 25,color: textColor,),
                    title: Text('Settings and Privacy',style: TextStyle(
                        fontSize: 18,
                        color: textColor
                    ),),
                    onTap: (){
                      Navigator.pop(context);
                      Navigator.pushNamed(context, settingsRoute);
                    },
                  ),
                ]
            ),
          ),
        ),
      ),
      backgroundColor: bar,
      body: PageView(
        onPageChanged: (int index){
          widget.userProvider.setBarIndex(index);
        },
        controller: widget.myPage,
        children: [
          widget.userProvider.getUser == null || widget.userProvider.getFireUser.uid != widget.userProvider.getUser.id?
        Center(
            child: RefreshProgressIndicator(backgroundColor: icons,)
         ) :
         !diaryProvider.homeFeed ?
            FollowingWidget(diaryProvider: diaryProvider,id: widget.userProvider.getFireUser.uid,
              userProvider: widget.userProvider,followScrollController: followScrollController,) :
          PublicWidget(diaryProvider: diaryProvider,userProvider: widget.userProvider,publicScrollController: publicScrollController,),
          SearchScreen(diaryProvider: diaryProvider,youMeProvider: widget.userProvider),
          YouMeNotifications(userProvider: widget.userProvider,diaryProvider: diaryProvider,),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(myPage: widget.myPage,userProvider: widget.userProvider,diaryProvider: diaryProvider,),
      floatingActionButton: FloatingActionButton(
       backgroundColor: float,
       elevation: 4,
       onPressed: () {
         Navigator.pushNamed(context, writeRoute);
       },
       child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset('assets/think_pencil.png',cacheHeight: 40,cacheWidth: 22,),
      )
     ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    followScrollController.dispose();
    publicScrollController.dispose();
  }
}