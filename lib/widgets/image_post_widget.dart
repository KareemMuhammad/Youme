import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:umee/repositories/user_provider.dart';
import 'package:umee/utils/constants.dart';
import 'package:umee/utils/shared.dart';

class ImagePostWidget extends StatefulWidget {
  final UserProvider userProvider;

  const ImagePostWidget({Key key, this.userProvider}) : super(key: key);
  @override
  _ImagePostWidgetState createState() => _ImagePostWidgetState();
}

class _ImagePostWidgetState extends State<ImagePostWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      width: MediaQuery.of(context).size.width,
      child: Swiper(
        itemCount: widget.userProvider.getImagePath.length,
        loop: false,
        pagination: new SwiperPagination(
          alignment: Alignment.bottomCenter,
          builder: new DotSwiperPaginationBuilder(
              color: textColor, activeColor: icons),
        ),
        itemBuilder: (BuildContext context,int index){
          return Stack(
              children:[
                CachedNetworkImage(
                  imageUrl: widget.userProvider.getImagePath[index],
                  width: double.maxFinite,
                  height: double.maxFinite,
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      Image.asset('assets/image-not-found.png'),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: InkWell(
                      onTap: ()async{
                        await FirebaseStorage.instance.refFromURL(widget.userProvider.getImagePath[index]).delete();
                        setState(() {
                          widget.userProvider.getImagePath.removeAt(index);
                        });
                        if(widget.userProvider.getImagePath.isEmpty){
                          widget.userProvider.reloadPostChoice(Utils.WORDS);
                        }
                      },
                      child: CircleAvatar(
                          backgroundColor: icons,
                          radius: 17,
                          child: Icon(Icons.close,size: 22,color: textColor,)
                      ),),
                  ),
                ),
              ]
          );
        },
      ),
    );
  }
}
