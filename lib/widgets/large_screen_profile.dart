import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:umee/utils/shared.dart';

class LargeScreenProfile extends StatelessWidget {
  final String image;

  const LargeScreenProfile({Key key, this.image}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, void Function(void Function()) setState) {
        return WillPopScope(
          onWillPop: () {
            return Future.value(true);
          },
          child: Material(
            child: InkWell(
              onTap: (){
                Navigator.pop(context);
              },
              child: CircleAvatar(
                radius: 100,
                backgroundColor: textColor,
                backgroundImage: image.isEmpty ? AssetImage('assets/pic.jpg')
                    : CachedNetworkImageProvider(image),
              ),
            ),
          ),
        );
      },
    );
  }
}
