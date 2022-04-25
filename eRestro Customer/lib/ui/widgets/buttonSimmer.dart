import 'package:erestro/helper/color.dart';
import 'package:erestro/helper/design.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ButtonSimmer extends StatelessWidget {
  final int? length;
  final double? width, height;
  const ButtonSimmer({Key? key, this.length, this.width, this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(height: height!/6.8,width: width, padding: EdgeInsets.only(top: height!/55.0, bottom: height!/55.0, left: width!/20.0, right: width!/20.0), child: Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: TextButton(
    style: TextButton.styleFrom(
    splashFactory: NoSplash.splashFactory,
    ),onPressed:(){
    },child: Container(height: height!/6.8,margin: EdgeInsets.only(left: width!/20.0, right: width!/20.0, bottom: height!/55.0), width: width, padding: EdgeInsets.only(top: height!/55.0, bottom: height!/55.0, left: width!/20.0, right: width!/20.0), decoration: DesignConfig.boxDecorationContainer(ColorsRes.white, 100.0)))),
    );
  }
}
