import 'package:erestro/helper/color.dart';
import 'package:erestro/helper/design.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class TopBrandSimmer extends StatelessWidget {
  final double? width, height;
  const TopBrandSimmer({Key? key, this.width, this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        // enabled: _enabled,
        child: SizedBox(height: height! / 6.6,
            child: ListView.builder(shrinkWrap: true,
                  padding: EdgeInsets.zero, scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 5,
                  itemBuilder: (BuildContext context, i) {
                    return Container(decoration: DesignConfig.boxDecorationContainer(ColorsRes.white, 15.0),
                      padding: EdgeInsets.only(
                          bottom: height! / 99.0),
                      //height: height!/4.7,,
                      margin: EdgeInsets.only(
                          left: width! / 60.0,
                          right: width! / 60.0), width: width!/4.0, height: height!/12.0);
                  }
              ),
        ))
    );
  }
}
