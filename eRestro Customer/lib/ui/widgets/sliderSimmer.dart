import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SliderSimmer extends StatelessWidget {
  final double? width, height;
  const SliderSimmer({Key? key, this.width, this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        // enabled: _enabled,
        child: SizedBox(height: height! / 4.6,
          child: Container(
            margin: EdgeInsets.only(left: width!/20.0, right: width!/20.0, top: height!/40.0),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(25.0)),
              child: Container(width: width, height: height!/5.0, color: Colors.white,
              ),
            ),
          ),
        ))
    );
  }
}
