import 'package:erestro/helper/color.dart';
import 'package:erestro/helper/design.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

 class OrderSimmer extends StatelessWidget {
   final double? width, height;
   const OrderSimmer({Key? key, this.width, this.height}) : super(key: key);

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
                       Padding(
                         padding: EdgeInsets.only(
                           left: width! / 40.0, right: width! / 40.0, top: height! / 99.0, bottom: height! / 99.0),
                         child: Row(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: <Widget>[
                             Container(
                               width: 25.0,
                               height: 25.0,
                               color: Colors.white,
                             ),
                             SizedBox(width: height!/99.0),
                             Expanded(
                               child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: <Widget>[
                                   Container(
                                     width: double.maxFinite,
                                     height: 10.0,
                                     color: Colors.white,
                                   ),
                                   SizedBox(height: height!/99.0),
                                   Container(
                                     width: double.maxFinite,
                                     height: 10.0,
                                     color: Colors.white,
                                   ),
                                 ],
                               ),
                             )
                           ],
                         ),
                       ),
               Padding(
                 padding: EdgeInsets.only(
                     left: width! / 40.0, right: width! / 40.0, top: height! / 99.0, bottom: height! / 99.0),
                 child: Container(
                   width: 5.0,
                   height: height!/15.0,
                   color: Colors.white,
                 )),
                       Padding(
                         padding: EdgeInsets.only(
                             left: width! / 40.0, right: width! / 40.0, top: height! / 99.0, bottom: height! / 99.0),
                         child: Row(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: <Widget>[
                             Container(
                               width: 25.0,
                               height: 25.0,
                               color: Colors.white,
                             ),
                             SizedBox(width: height!/99.0),
                             Expanded(
                               child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: <Widget>[
                                   Container(
                                     width: double.maxFinite,
                                     height: 10.0,
                                     color: Colors.white,
                                   ),
                                   SizedBox(height: height!/99.0),
                                   Container(
                                     width: double.maxFinite,
                                     height: 10.0,
                                     color: Colors.white,
                                   ),
                                 ],
                               ),
                             )
                           ],
                         ),
                       ),
                       Padding(
                           padding: EdgeInsets.only(
                              left: width!/ 40.0, top: height! / 80.0, bottom: height! / 50.0),
                           child: Container(width: width!/4.0, height: 2.0, color: ColorsRes.white,)
                       ),
                       Container(height: height! / 4.5,
                         child: ListView.builder(shrinkWrap: true,
                             padding: EdgeInsets.zero, scrollDirection: Axis.vertical,
                             physics: const NeverScrollableScrollPhysics(),
                             itemCount: 2,
                             itemBuilder: (BuildContext context, i) {
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
                       Padding(
                           padding: EdgeInsets.only(
                              left: width! / 40.0, top: height! / 80.0, bottom: height! / 50.0),
                           child: Container(width: width!/4.0, height: 8.0, color: ColorsRes.white,)
                       ),
                       Padding(
                         padding: EdgeInsets.only(top: height! / 70.0,
                             bottom: height! / 99.0,
                             left: width! / 40.0,
                             right: width! / 40.0),
                         child: Container(width: width!/4.0, height: 8.0, color: ColorsRes.white,),
                       ),Padding(
                         padding: EdgeInsets.only(top: height! / 70.0,
                             bottom: height! / 70.0,
                             left: width! / 40.0,
                             right: width! / 40.0),
                         child: Row(
                             mainAxisAlignment: MainAxisAlignment.end,
                             crossAxisAlignment: CrossAxisAlignment.end,
                             children: [
                               Container(width: width!/3.0, height: 8.0, color: ColorsRes.white,),
                               const Spacer(),
                               Container(width: width!/20.0, height: 8.0, color: ColorsRes.white,)
                             ]
                         ),
                       ),
                       Padding(
                         padding: EdgeInsets.only(top: height! / 70.0,
                             bottom: height! / 70.0,
                             left: width! / 40.0,
                             right: width! / 40.0),
                         child: Row(
                             mainAxisAlignment: MainAxisAlignment.end,
                             crossAxisAlignment: CrossAxisAlignment.end,
                             children: [
                               Container(width: width!/3.0, height: 8.0, color: ColorsRes.white,),
                               const Spacer(),
                               Container(width: width!/20.0, height: 8.0, color: ColorsRes.white,)
                             ]
                         ),
                       ),
                       Container(width: width!/4.0, height: height!/10.0, color: ColorsRes.white,),
                       Padding(
                           padding: EdgeInsets.only(
                               top: height! / 70.0, left: width! / 40.0),
                           child: Container(width: width!/4.0, height: 8.0, color: ColorsRes.white,)
                       ),
                       Padding(
                         padding: EdgeInsets.only(left: width!/40.0, right: width!/40.0,),
                         child: Row(
                           children: [
                             Container(width: width!/4.0, height: 8.0, color: ColorsRes.white,),
                             const Spacer(),
                             Container(width: width!/10.0, height: 8.0, color: ColorsRes.white,)                                  ],
                         ),
                       ),
                       Padding(
                         padding: EdgeInsets.only(
                             top: height! / 70.0, bottom: height! / 70.0),
                         child: Divider(color: ColorsRes.lightFont
                             .withOpacity(0.10), height: 1.0,),
                       ),
                       Padding(
                         padding: EdgeInsets.only(
                             top: height! / 70.0, bottom: height! / 70.0),
                         child: Divider(color: ColorsRes.lightFont
                             .withOpacity(0.10), height: 1.0,),
                       ),
                       Padding(
                         padding: EdgeInsets.only(
                           left: width! / 40.0, right: width! / 40.0,),
                         child: Row(
                           children: [
                             Container(width: width!/4.0, height: 8.0, color: ColorsRes.white,),
                             const Spacer(),
                             Container(width: 15.0, height: 15.0, color: ColorsRes.white,)
                           ],
                         ),
                       ),
                       Padding(
                           padding: EdgeInsets.only(
                              left: width!/ 40.0, top: height! / 70.0, bottom: height! / 70.0),
                           child: Container(width: width!/4.0, height: 2.0, color: ColorsRes.white,)
                       ),
                       Padding(
                           padding: EdgeInsets.only(
                             left: width! / 40.0, right: width! / 40.0,),
                           child: Container(width: width!/4.0, height: 8.0, color: ColorsRes.white,)
                       ),
                       Padding(
                           padding: EdgeInsets.only(
                              left: width! / 40.0, top: height! / 70.0, bottom: height! / 70.0),
                           child: Container(width: width!/4.0, height: 2.0, color: ColorsRes.white,)
                       ),
                       Container(margin: EdgeInsets.only(left: width!/40.0, right: width!/40.0,),
                         padding: EdgeInsets.only(left: width!/20.0, bottom: height!/99.0),width: width!/4.0, height: 8.0, color: ColorsRes.white,),
                       Container(margin: EdgeInsets.only(left: width!/40.0, right: width!/40.0,),
                         padding: EdgeInsets.only(left: width!/20.0, bottom: height!/99.0),width: width!/4.0, height: 8.0, color: ColorsRes.white,),
                       Padding(
                           padding: EdgeInsets.only(
                              left: width! / 40.0, top: height! / 70.0, bottom: height! / 70.0),
                           child: Container(width: width!/4.0, height: 2.0, color: ColorsRes.white,)
                       ),
                       Padding(
                           padding: EdgeInsets.only(
                             left: width! / 40.0, right: width! / 40.0,),
                           child: Container(width: width!/4.0, height: 8.0, color: ColorsRes.white,)
                       ),
                       Padding(
                         padding: EdgeInsets.only(top: 4.5,
                           bottom: 4.5,
                           left: width! / 40.0,
                           right: width! / 40.0,),
                         child: Row(children: [
                           Container(width: width!/3.0, height: 8.0, color: ColorsRes.white,),
                           const Spacer(),
                           Container(width: width!/20.0, height: 8.0, color: ColorsRes.white,)
                         ]),
                       ),
                       Padding(
                         padding: EdgeInsets.only(
                           left: width! / 40.0, right: width! / 40.0,),
                         child: Row(children: [
                           Container(width: width!/3.0, height: 8.0, color: ColorsRes.white,),
                           const Spacer(),
                           Container(width: width!/20.0, height: 8.0, color: ColorsRes.white,)
                         ]),
                       ),
                       Padding(
                           padding: const EdgeInsets.only(
                               top: 4.5, bottom: 4.5),
                           child: Container(width: width!/3.0, height: 8.0, color: ColorsRes.white,)
                       ),
                       Padding(
                         padding: EdgeInsets.only(
                           left: width! / 40.0, right: width! / 40.0,),
                         child: Row(children: [
                           Container(width: width!/3.0, height: 8.0, color: ColorsRes.white,),
                           const Spacer(),
                           Container(width: width!/20.0, height: 8.0, color: ColorsRes.white,)
                         ]),
                       ),
                       Padding(
                           padding: const EdgeInsets.only(
                               top: 4.5, bottom: 4.5),
                           child: Container(width: width!/4.0, height: 8.0, color: ColorsRes.white,)
                       ),
                       Padding(
                         padding: EdgeInsets.only(
                           left: width! / 40.0, right: width! / 40.0,),
                         child: Row(children: [
                           Container(width: width!/3.0, height: 8.0, color: ColorsRes.white,),
                           const Spacer(),
                           Container(width: width!/20.0, height: 8.0, color: ColorsRes.white,)
                         ]),
                       ),
                       Padding(
                         padding: EdgeInsets.only(top: 4.5,
                           bottom: 4.5,
                           left: width! / 40.0,
                           right: width! / 40.0,),
                         child: Row(children: [
                           Container(width: width!/3.0, height: 8.0, color: ColorsRes.white,),
                           const Spacer(),
                           Container(width: width!/20.0, height: 8.0, color: ColorsRes.white,),
                         ]),
                       ),
                       Padding(
                         padding: EdgeInsets.only(
                           left: width! / 40.0, right: width! / 40.0,),
                         child: Row(children: [
                           Container(width: width!/3.0, height: 8.0, color: ColorsRes.white,),
                           const Spacer(),
                           Container(width: width!/20.0, height: 8.0, color: ColorsRes.white,),
                         ]),
                       ),
                       Padding(
                         padding: EdgeInsets.only(top: 4.5,
                           bottom: 4.5,
                           left: width! / 40.0,
                           right: width! / 40.0,),
                         child: Container(width: width!/3.0, height: 2.0, color: ColorsRes.white,),
                       ),
                       Padding(
                         padding: EdgeInsets.only(
                           left: width! / 40.0, right: width! / 40.0,),
                         child: Row(children: [
                           Container(width: width!/3.0, height: 8.0, color: ColorsRes.white,),
                           const Spacer(),
                           Container(width: width!/20.0, height: 8.0, color: ColorsRes.white,),
                         ]),
                       ),
                       Padding(
                         padding: const EdgeInsets.only(
                             top: 4.5, bottom: 4.5),
                         child: Container(width: width!/3.0, height: 2.0, color: ColorsRes.white,),
                       ),
                       Container(margin: EdgeInsets.only(left: width!/40.0, right: width!/40.0, bottom: height!/55.0), width: width, height: height!/20.0, padding: EdgeInsets.only(top: height!/55.0, bottom: height!/55.0, left: width!/20.0, right: width!/20.0), decoration: DesignConfig.boxDecorationContainer(ColorsRes.backgroundDark, 100.0)),
                     ],
                   ),
                 ))
         ))
     );
   }
 }
