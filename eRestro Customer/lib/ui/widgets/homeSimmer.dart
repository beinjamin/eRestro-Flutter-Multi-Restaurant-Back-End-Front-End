import 'package:erestro/helper/color.dart';
import 'package:erestro/ui/widgets/cuicineSimmer.dart';
import 'package:erestro/ui/widgets/restaurantNearBySimmer.dart';
import 'package:erestro/ui/widgets/sectionSimmer.dart';
import 'package:erestro/ui/widgets/sliderSimmer.dart';
import 'package:erestro/ui/widgets/topBrandSimmer.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

 class HomeSimmer extends StatelessWidget {
   final double? width, height;
   const HomeSimmer({Key? key, this.width, this.height}) : super(key: key);

   @override
   Widget build(BuildContext context) {
     return Center(child: Shimmer.fromColors(
         baseColor: Colors.grey[300]!,
         highlightColor: Colors.grey[100]!,
         // enabled: _enabled,
         child: SizedBox(height: height,
             child: SingleChildScrollView(padding: EdgeInsets.zero, physics: const NeverScrollableScrollPhysics(),
               child: Column(
                   children:[
                     SliderSimmer(width: width, height: height),
                     Padding(
                       padding: EdgeInsets.only(
                           left: width! / 40.0, right: width! / 40.0, top: height! / 50.0, bottom: height!/20.0),
                       child: Row(children: [
                         Container(width: width!/4.0, height: 8.0, color: ColorsRes.white,),
                         const Spacer(),
                         Container(width: width!/20.0, height: 8.0, color: ColorsRes.white,),
                       ]),
                     ),
                     CuisineSimmer(length: 6, width: width, height: height),
                     SectionSimmer(length: 4, width: width!, height: height!),
                     Padding(
                       padding: EdgeInsets.only(
                           left: width! / 40.0, right: width! / 40.0, top: height! / 50.0, bottom: height!/20.0),
                       child: Row(children: [
                         Container(width: width!/4.0, height: 8.0, color: ColorsRes.white,),
                         const Spacer(),
                         Container(width: width!/20.0, height: 8.0, color: ColorsRes.white,),
                       ]),
                     ),
                     SliderSimmer(width: width, height: height),
                     Padding(
                       padding: EdgeInsets.only(
                           left: width! / 40.0, right: width! / 40.0, top: height! / 50.0, bottom: height!/20.0),
                       child: Row(children: [
                         Container(width: width!/4.0, height: 8.0, color: ColorsRes.white,),
                         const Spacer(),
                         Container(width: width!/20.0, height: 8.0, color: ColorsRes.white,),
                       ]),
                     ),
                     TopBrandSimmer(width: width, height: height),
                     Padding(
                       padding: EdgeInsets.only(
                           left: width! / 40.0, right: width! / 40.0, top: height! / 50.0, bottom: height!/20.0),
                       child: Row(children: [
                         Container(width: width!/4.0, height: 8.0, color: ColorsRes.white,),
                         const Spacer(),
                         Container(width: width!/20.0, height: 8.0, color: ColorsRes.white,),
                       ]),
                     ),
                     RestaurantNearBySimmer(length: 5, width: width!, height: height!),
                     Padding(
                       padding: EdgeInsets.only(
                           left: width! / 40.0, right: width! / 40.0, top: height! / 50.0, bottom: height!/20.0),
                       child: Row(children: [
                         Container(width: width!/4.0, height: 8.0, color: ColorsRes.white,),
                         const Spacer(),
                         Container(width: width!/20.0, height: 8.0, color: ColorsRes.white,),
                       ]),
                     ),
                     RestaurantNearBySimmer(length: 5, width: width!, height: height!),
                     SizedBox(height: height!/20.0),
                   ]
               ),
             )
         ))
     );
   }
 }
