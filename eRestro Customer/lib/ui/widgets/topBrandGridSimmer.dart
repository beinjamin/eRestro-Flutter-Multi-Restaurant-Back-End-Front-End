import 'package:erestro/helper/design.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class TopBrandGridSimmer extends StatelessWidget {
  final double? width, height;
  final int? length;
  const TopBrandGridSimmer({Key? key, this.width, this.height, this.length}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        // enabled: _enabled,
        child: SizedBox(height: height! / 1.2,
            child: GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,childAspectRatio: 0.98,
              children: List.generate(length!, (index) {
                return Padding(
                  padding: EdgeInsets.only(top: height!/88.0),
                  child: Container(decoration: DesignConfig.boxDecorationContainer(Colors.white, 15.0), width: width!/3.0, height: height!/9.0,
                    padding: const EdgeInsets.only(top: 14.0, bottom: 14.0),
                    margin: EdgeInsets.only(top: height!/20.0, right: width!/20.0),
                    child: Padding(
                        padding: EdgeInsets.only(top: height!/30.0),
                        child: Container(height: 8.0, width: 40.0, color: Colors.white)),
                  ),
                );
              }),
            )
        ))
    );
  }
}
