import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class HeaderAddressSimmer extends StatelessWidget {
  final double? width, height;
  const HeaderAddressSimmer({Key? key, this.width, this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        // enabled: _enabled,
        child: SizedBox(height: height!/20.0,
          child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: width!/10.0,
                  height: 8.0,
                  color: Colors.white,
                ),
                SizedBox(height: height!/99.0),
                Container(
                  width: width!/2.0,
                  height: 8.0,
                  color: Colors.white,
                ),
              ]
          ),
        ),
      ),
    );
  }
}
