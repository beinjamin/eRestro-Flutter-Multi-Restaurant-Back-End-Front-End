import 'package:erestro/helper/color.dart';
import 'package:erestro/helper/design.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class NotificationSimmer extends StatelessWidget {
  final double? width, height;
  const NotificationSimmer({Key? key, this.width, this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height! / 1.28,
      child: Center(
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: ListView.builder(
            itemBuilder: (_, __) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Container(margin: EdgeInsets.only(
                  left: width! / 20.0,
                  right: width! / 20.0,
                  top: height! / 50.0),
                //  decoration: DesignConfig.boxDecorationContainer(
                //      ColorsRes.backgroundDark, 15.0),
                  width: width,
                  child: Padding(
                    padding: EdgeInsets.only(top: width! / 32.0,
                        bottom: width! / 32.0,
                        left: width! / 32.0,
                        right: width! / 32.0),
                    child: Row(
                      children: [
                        Container(height: 39.0,
                            width: 39.0,
                            decoration: DesignConfig
                                .boxDecorationContainer(
                                ColorsRes.white, 10.0),
                            margin: EdgeInsets.only(
                                right: width! / 32.0)),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment
                                .start,
                            crossAxisAlignment: CrossAxisAlignment
                                .start,
                            children: [
                              Container(height: 10.0, width: double.maxFinite, color: ColorsRes.white),
                              const SizedBox(height: 7),
                              Container(height: 10.0, width: double.maxFinite, color: ColorsRes.white),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
            ),
            itemCount: 6,
          ),
        )
      ),
    );
  }
}
