import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:umee/utils/shared.dart';

class LargeScreenImage extends StatelessWidget {
  final String image;

  const LargeScreenImage({Key key, this.image}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, void Function(void Function())setState)
      {
        return WillPopScope(
          onWillPop: () {
            return Future.value(true);
          },
          child: Material(
            child: InkWell(
              onTap: (){
                Navigator.pop(context);
              },
              child: Container(
                color: background,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child:  PhotoView(
                  backgroundDecoration: BoxDecoration(
                    color: background,
                  ),
                  imageProvider: CachedNetworkImageProvider(image),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
