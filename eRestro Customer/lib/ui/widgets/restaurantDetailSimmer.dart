import 'package:erestro/helper/color.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

 class RestaurantDetailSimmer extends StatelessWidget {
   final double? width, height;
   const RestaurantDetailSimmer({Key? key, this.width, this.height}) : super(key: key);

   @override
   Widget build(BuildContext context) {
     return Center(child: Shimmer.fromColors(
         baseColor: Colors.grey[300]!,
         highlightColor: Colors.grey[100]!,
         // enabled: _enabled,
         child: Container(margin : EdgeInsets.only(top: height!/30.0), height: height! / 0.9, width: width,
             child: Container(
                 padding: EdgeInsets.only(left: width! / 40.0,
                     right: width! / 40.0,
                     bottom: height! / 99.0),
                 //height: height!/4.7,
                 width: width!,
                 margin: EdgeInsets.only(top: height! / 70.0),
                 child: SingleChildScrollView(
                   child: Column(
                     mainAxisAlignment: MainAxisAlignment.start,
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                     SizedBox(height: height! / 4.6,
                         child: ClipRRect(
                           borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(25.0), bottomRight: Radius.circular(25.0)),
                           child: Container(width: width, height: height!/5.0, color: Colors.white,
                           ),
                         ),
                        ),
                       Padding(
                           padding: EdgeInsets.only(
                              left: width!/ 40.0, top: height! / 80.0, bottom: height! / 50.0),
                       ),
                       SizedBox(height: height!/ 10.0,
                         child: ListView.builder(shrinkWrap: true,
                             padding: EdgeInsets.zero, scrollDirection: Axis.horizontal,
                             physics: const NeverScrollableScrollPhysics(),
                             itemCount: 5,
                             itemBuilder: (BuildContext context, i) {
                               return Container(
                                   padding: EdgeInsets.only(
                                       bottom: height! / 99.0),
                                   //height: height!/4.7,,
                                   margin: EdgeInsets.only(
                                     left: width! / 60.0,
                                     right: width! / 60.0), width: width!/3.5, height: height!/12.0, color: ColorsRes.white,);
                             }
                           ),
                       ),
                       Padding(
                           padding: EdgeInsets.only(
                               left: width!/ 40.0, top: height! / 80.0, bottom: height! / 50.0),
                       ),
                       SizedBox(height: height!/ 40.0,
                         child: ListView.builder(shrinkWrap: true,
                             padding: EdgeInsets.zero, scrollDirection: Axis.horizontal,
                             physics: const NeverScrollableScrollPhysics(),
                             itemCount: 5,
                             itemBuilder: (BuildContext context, i) {
                               return Container(
                                 padding: EdgeInsets.only(
                                     bottom: height! / 99.0),
                                 //height: height!/4.7,,
                                 margin: EdgeInsets.only(
                                     left: width! / 60.0,
                                     right: width! / 60.0), width: width!/6.0, height: height!/40.0, color: ColorsRes.white,);
                             }
                         ),
                       ),
                       Padding(
                         padding: EdgeInsets.only(
                             left: width!/ 40.0, top: height! / 80.0, bottom: height! / 50.0),
                       ),
                       Column(children: List.generate(10 ,(j) {
                               return Container(
                                 margin: const EdgeInsets.only(top: 5),
                                 padding: EdgeInsets.only(bottom: height! / 99.0,
                                     left: width! / 40.0,
                                     right: width! / 40.0),
                                 child: Column(
                                     children: [
                                       Container(width: width!, height: height!/12.0, color: ColorsRes.white,),
                                     ]
                                 ),
                               );
                             }
                         ),
                       ),
                     ],
                   ),
                 ))
         ))
     );
   }
 }
