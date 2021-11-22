import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:umee/models/diaries_model.dart';
import 'package:umee/repositories/user_provider.dart';
import 'package:umee/screens/others_profile.dart';
import 'package:umee/utils/shared.dart';
import 'package:umee/widgets/slide.dart';

class ViewAllScreen extends StatelessWidget {
  final String title;
  final List<Admires> list;
  final UserProvider userProvider;

  const ViewAllScreen({Key key, this.title, this.list, this.userProvider}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: background,
      appBar: title.isEmpty ?
      AppBar(elevation: 0,backgroundColor: background,toolbarHeight: 0,)
      :AppBar(
        backgroundColor: bar,
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('$title',style: TextStyle(color: textColor,fontSize: 19),),
        ),
      ),
      body: ListView.builder(
          itemCount: list.length ?? 0,
          itemBuilder: (BuildContext context,int index){
            return list.isEmpty || list == null? Center(
              child: Container(
                child: Text('This diary has no Likes yet',style: TextStyle(color: textColor,fontSize: 17),),
              ),
            )
                : ListTile(
                   contentPadding: EdgeInsets.all(10),
                    onTap: (){
                     userProvider.setOthersBool(true);
                      if(!userProvider.getUser.blocked.contains(list[index].userId) && userProvider.getUser.id != list[index].userId) {
                        Navigator.push(context, MySlide(widgetBuilder: (_) =>
                            OthersProfile(admire: list[index],)));
                      }
                    },
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundColor: textColor,
                    backgroundImage: list[index].userImage.isEmpty ? AssetImage('assets/pic.jpg') : CachedNetworkImageProvider(list[index].userImage),
                  ),
                  title:  Text('${list[index].userName ?? 'Unknown'}',style: TextStyle(color: textColor,fontSize: 17,letterSpacing: 1,fontWeight: FontWeight.bold),),
            );
          }),
    );
  }
}
