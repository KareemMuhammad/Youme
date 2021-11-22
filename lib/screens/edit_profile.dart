import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:umee/repositories/user_provider.dart';
import 'package:umee/screens/edit_info.dart';
import 'package:umee/widgets/slide.dart';
import '../../utils/shared.dart';


class EditYouProfile extends StatefulWidget {
  @override
  _EditYouProfileState createState() => _EditYouProfileState();
}

class _EditYouProfileState extends State<EditYouProfile> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: bar,
        title: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text('Edit Profile',style: TextStyle(
              fontSize: 20,
              color: textColor
          ),),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 40,),
            customWidget('Name', userProvider.getUser.name,0),
            customWidget('Email', userProvider.getUser.email,1),
            customWidget('Bio', userProvider.getUser.about,2),
            customWidget('Address', userProvider.getUser.location,3),
            customWidget('Gender', userProvider.getUser.gender,4),
            customWidget('Birthday', userProvider.getUser.birthday,5),
          ],
        ),
      ),
    );
  }

  Widget customWidget(String title,String info,int load){
   return Container(
      margin: const EdgeInsets.all(13.0),
      padding: const EdgeInsets.all(13.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: buttons
      ),
      child: InkWell(
        onTap: (){
          Navigator.push(context, MySlide(widgetBuilder: (_) => EditInfoScreen(load: load,title: title,)));
        },
        child: Row(
          children: [
            Text(title,style: TextStyle(color: textColor,fontSize: 17),),
            Spacer(),
            Text(info,style: TextStyle(color: textColor,fontSize: 17),),
            SizedBox(width: 10,),
            Icon(Icons.arrow_forward_ios,color: textColor,size: 20,)
          ],
        ),
      ),
    );
  }

}
