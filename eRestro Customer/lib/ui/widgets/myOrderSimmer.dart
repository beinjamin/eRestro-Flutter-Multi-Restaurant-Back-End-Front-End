import 'package:erestro/helper/color.dart';
import 'package:erestro/helper/design.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class MyOrderSimmer extends StatelessWidget {
  final int? length;
  final double? width, height;

  const MyOrderSimmer({Key? key, this.length, this.width, this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(child: Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: length!,
          itemBuilder: (BuildContext context, index) {
            return Container(
              decoration: DesignConfig.boxDecorationContainer(
                  ColorsRes.white, 10.0),
              padding: EdgeInsets.only(left: width! / 40.0,
                  top: height! / 99.0,
                  right: width! / 40.0,
                  bottom: height! / 99.0),
              width: width!,
              margin: EdgeInsets.only(top: height! / 52.0,
                  left: width! / 24.0,
                  right: width! / 24.0),
              child: Container(
                width: 40.0, height: height! / 4.0, color: ColorsRes.white,),);
          }),
    ));
  }
}