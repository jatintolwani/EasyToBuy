import 'package:cached_network_image/cached_network_image.dart';
import 'package:easytobuy/widgets/cacheImage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

import '../main_config.dart';

class SliderCaro extends StatefulWidget {
  var imgList;
  var controls;
  SliderCaro(this.imgList, [this.controls = false]);
  @override
  _SliderCaroState createState() => _SliderCaroState();
}

class _SliderCaroState extends State<SliderCaro> {
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      height: 250,
      child: Swiper(
        autoplay: true,
        autoplayDelay: 2000,
        itemWidth: 500,
        itemHeight: 250,
        // layout: SwiperLayout.STACK,
        itemBuilder: (BuildContext context, int index) {
          return CacheImage(widget.imgList[index]);
        },
        itemCount: widget.imgList.length,
        control: widget.controls
            ? new SwiperControl(
                color: primaryColor,
                size: 25,
              )
            : null,
      ),
    );
  }
}
