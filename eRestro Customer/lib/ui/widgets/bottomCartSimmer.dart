import 'package:erestro/helper/color.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class BottomCartSimmer extends StatelessWidget {
  final int? length;
  final double? width, height;
  final bool? show;

  const BottomCartSimmer({Key? key, this.length, this.width, this.height, this.show})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(margin: EdgeInsets.only(bottom: show == true?height!/9.9:height!/9.9), width: width, padding: EdgeInsets.only(top: height!/55.0, bottom: height!/55.0, left: width!/20.0, right: width!/20.0), child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Row(mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 40.0, height: 10.0, color: ColorsRes.white,),
                  const Spacer(),
                  Container(
                    width: 40.0, height: 10.0, color: ColorsRes.white,)
                ],
            ),
        ),
        );
  }
}