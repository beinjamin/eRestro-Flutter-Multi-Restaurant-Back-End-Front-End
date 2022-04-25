import 'package:erestro/helper/color.dart';
import 'package:erestro/helper/design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';

class SectionSimmer extends StatelessWidget {
  final int? length;
  final double? width, height;
  const SectionSimmer({Key? key, this.length, this.width, this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        // enabled: _enabled,
        child: ListView.builder(shrinkWrap: true, padding: EdgeInsets.zero,
            // scrollDirection: Axis.vertical,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            itemBuilder: (BuildContext buildContext, index) {
              return Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.end, crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: width!/20.0, top: height!/60.0),
                          child:
                          Container(color: ColorsRes.white, height: 10.0, width: width!/1.5),
                        ),
                        const Spacer(),
                      ]
                  ),
                  SizedBox(height: height! / 2.7,
                    child: ListView.builder(shrinkWrap: true, padding: EdgeInsets.zero,
                        scrollDirection: Axis.horizontal,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: 3,
                        itemBuilder: (BuildContext buildContext, i) {
                          return Container(margin: EdgeInsets.only(
                              left: width! / 20.0, top: height! / 80.0),
                            child: Stack(
                              children: [
                                ClipRRect(borderRadius: const BorderRadius.all(
                                    Radius.circular(25.0)),
                                    child: Container(color: ColorsRes.white, width: width! / 2.32,
                                      height: height! / 5.0,
                                    )),
                                Container(height: height! / 27,
                                    width: width! / 14,
                                    alignment: Alignment.center,
                                    decoration: DesignConfig
                                        .boxDecorationContainerRoundHalf(
                                        ColorsRes.white, 25.0, 0.0,
                                        0.0, 5.0),
                                    child: Container(
                                        color: ColorsRes.white,
                                        width: 14.0,
                                        height: 12.0)),
                                Positioned(right: 0.0,
                                  child: Container(height: height! / 24.0,
                                    width: width! / 8.9,
                                    alignment: Alignment.centerLeft,
                                    padding: EdgeInsets.only(left: width! / 90.0,),
                                    decoration: DesignConfig
                                        .boxDecorationContainerRoundHalf(ColorsRes
                                        .white, 0.0, 5.0, 25.0, 0.0),
                                  ),
                                ),
                                Container(
                                    padding: EdgeInsets.only(left: width! / 40.0,
                                        top: height! / 60.0,
                                        right: width! / 40.0,
                                        bottom: height! / 60.0),
                                    height: height! / 4.7,
                                    width: width! / 2.5,
                                    margin: EdgeInsets.only(top: height! / 7.5,
                                        left: width! / 60.0,
                                        right: width! / 60.0),
                                    decoration: DesignConfig
                                        .boxDecorationContainerCardShadow(
                                        ColorsRes.white,
                                        ColorsRes.shadowContainer,
                                        25.0,
                                        0.0,
                                        10.0,
                                        16.0,
                                        0.0),
                                    child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(width: 20.0, height: 8.0,
                                            color: ColorsRes.white,),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: height! / 99.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .start,
                                              crossAxisAlignment: CrossAxisAlignment
                                                  .end,
                                              children: [
                                                Expanded(
                                                  child: Container(width: 20.0,
                                                    color: ColorsRes
                                                        .white,
                                                  ),
                                                ),
                                                SizedBox(width: width! / 50.0),
                                                Container(color: ColorsRes.white,
                                                    width: 15, height: 15),
                                              ],
                                            ),
                                          ),
                                          Container(margin: EdgeInsets.only(
                                              top: height! / 80.0,
                                              bottom: height! / 80.0),
                                              padding: const EdgeInsets.only(top: 2,
                                                  bottom: 2,
                                                  left: 8.9,
                                                  right: 8.9),
                                              decoration: DesignConfig
                                                  .boxDecorationContainer(
                                                  ColorsRes.white, 5),
                                              child: Container(width: 20.0, height: 10.0,
                                                  color: ColorsRes.white)),
                                          Row(mainAxisAlignment: MainAxisAlignment
                                              .start,
                                            children: [
                                              SvgPicture.asset(DesignConfig.setSvgPath("restaurant_rating"), fit: BoxFit.scaleDown, width: 7.0, height: 12.3),
                                              const SizedBox(width: 5.0),
                                              Container(width: 40.0, height: 10.0,
                                                color: ColorsRes.white,
                                              ),
                                              SizedBox(width: width! / 60.0),
                                              Container(height: 15.5, width: 15.5,
                                                color: ColorsRes.white,),
                                              Container(width: 40.0, height: 10.0,
                                                color: ColorsRes.white,),
                                            ],
                                          ),
                                          Container(margin: EdgeInsets.only(
                                              top: height! / 80.0),
                                            padding: const EdgeInsets.all(2.0),
                                            decoration: DesignConfig
                                                .boxDecorationContainer(
                                                ColorsRes.white, 39.0),
                                          ),
                                        ])),
                              ],
                            ),
                          );
                        }
                    ),
                  ),
                ],
              );
            }
        ))
    );
  }
}
