import 'package:erestro/helper/color.dart';
import 'package:erestro/helper/design.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class RestaurantNearBySimmer extends StatelessWidget {
  final int? length;
  final double? width, height;
  const RestaurantNearBySimmer({Key? key, this.length, this.width, this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(child: Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(shrinkWrap: true, padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: length!,
          itemBuilder: (BuildContext context, index) {
            return Container(
                padding: EdgeInsets.only(left: width!/40.0, top: height!/99.0, right: width!/40.0, bottom: height!/99.0),
                width:width!,
                margin: EdgeInsets.only(top: height!/52.0, left: width!/24.0, right: width!/24.0),
                child: Row(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: ClipRRect(borderRadius: const BorderRadius.all(Radius.circular(15.0)),child:Container(color: ColorsRes.white, width: width!/5.0, height: height!/8.2))),
                      Expanded(flex: 5,
                          child: Padding(
                              padding: EdgeInsets.only(left: width!/60.0),
                              child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children:[
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(width: 40.0, height: 10.0, color: ColorsRes.white,),
                                        SizedBox(width: width!/50.0),
                                        Container(color: ColorsRes.white, width: 15, height: 15),
                                      ],
                                    ),
                                    Align(alignment: Alignment.topRight, child: Container(color: ColorsRes.white, width: 15.0, height: 12.8)),
                                  ],
                                ),
                                SizedBox(height: height!/99.0),
                                Container(height: 10.0, width: 30.0, color: ColorsRes.white),
                                SizedBox(height: height!/99.0),
                                Row(mainAxisAlignment:MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Container(height: 15.5, width: 15.5, color: ColorsRes.white),
                                        SizedBox(width: width!/99.0),
                                        Container(height: 10.0, width: 40.0, color: ColorsRes.white),
                                      ],
                                    ),
                                    SizedBox(width: width!/60.0),
                                    Row(mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Container(height: 15.5, width: 15.5, color: ColorsRes.white),
                                        SizedBox(width: width!/99.0),
                                        Container(height: 10.0, width: 40.0, color: ColorsRes.white),
                                      ],
                                    ),
                                  ],
                                ),
                                Container(height: 10.0, width: double.maxFinite, margin: EdgeInsets.only(top: height!/99.0),
                                    padding: const EdgeInsets.only(top: 2, bottom: 2, left: 3.8, right: 3.8),
                                    decoration: DesignConfig.boxDecorationContainer(ColorsRes.white, 5)),

                              ])))]));}),
    ));
  }
}
