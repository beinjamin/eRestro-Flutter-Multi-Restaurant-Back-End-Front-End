import 'package:erestro/features/bottomNavigationBar/navicationBarCubit.dart';
import 'package:erestro/ui/cart/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'color.dart';

class DesignConfig {
  static RoundedRectangleBorder setRoundedBorderCard(double radius1, double radius2, double radius3, double radius4) {
    return RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(radius1),
            bottomRight: Radius.circular(radius2),
            topLeft: Radius.circular(radius3),
            topRight: Radius.circular(radius4)));
  }

  static RoundedRectangleBorder setRoundedBorder(Color borderColor, double radius, bool isSetSide) {
    return RoundedRectangleBorder(side: BorderSide(color: borderColor, width: isSetSide ? 1.0 : 0), borderRadius: BorderRadius.circular(radius));
  }

  static RoundedRectangleBorder setRounded(double radius) {
    return RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));
  }

  static RoundedRectangleBorder setHalfRoundedBorder(
      Color borderColor, double radius1, double radius2, double radius3, double radius4, bool isSetSide) {
    return RoundedRectangleBorder(
        side: BorderSide(color: borderColor, width: isSetSide ? 1.0 : 0),
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(radius1),
            bottomLeft: Radius.circular(radius2),
            topRight: Radius.circular(radius3),
            bottomRight: Radius.circular(radius4)));
  }

  static BoxDecoration boxDecorationContainerRoundHalf(Color color, double bradius1, double bradius2, double bradius3, double bradius4) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(bradius1),
          bottomLeft: Radius.circular(bradius2),
          topRight: Radius.circular(bradius3),
          bottomRight: Radius.circular(bradius4)),
    );
  }

  static BoxDecoration boxDecorationContainerShadow(Color color, double bradius1, double bradius2, double bradius3, double bradius4) {
    return BoxDecoration(
      color: ColorsRes.white,
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(bradius1),
          bottomLeft: Radius.circular(bradius2),
          topRight: Radius.circular(bradius3),
          bottomRight: Radius.circular(bradius4)),
      boxShadow: [BoxShadow(color: color, offset: const Offset(0.0, 2.0), blurRadius: 6.0, spreadRadius: 0)],
    );
  }

  static BoxDecoration boxDecorationContainer(Color color, double radius) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
    );
  }

  static BoxDecoration boxDecorationContainerHalf(Color color) {
    return BoxDecoration(
      color: color,
      borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(0.0), bottomLeft: Radius.circular(0.0), topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
    );
  }

  static BoxDecoration boxDecorationContainerBorder(Color color, Color colorBackground, double radius) {
    return BoxDecoration(
      color: colorBackground,
      border: Border.all(color: color),
      borderRadius: BorderRadius.circular(radius),
    );
  }

  static BoxDecoration boxDecorationCircle(Color color, Color colorBackground, double radius) {
    return BoxDecoration(
      color: colorBackground,
      border: Border.all(color: color, width: 2.0),
      borderRadius: BorderRadius.circular(radius),
    );
  }

  static setSvgPath(String name) {
    return "assets/images/svg/$name.svg";
  }

  static setPngPath(String name) {
    return "assets/images/image/4.0x/$name.png";
  }

  static BoxDecoration boxCurveShadow() {
    return const BoxDecoration(
        color: ColorsRes.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
        boxShadow: [
          BoxShadow(
            color: ColorsRes.shadow,
            spreadRadius: 0,
            blurRadius: 10,
            offset: Offset(0, -9),
          )
        ]);
  }

  static BoxDecoration boxCurveBottomBarShadow() {
    return const BoxDecoration(
        color: ColorsRes.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
        boxShadow: [
          BoxShadow(
            color: ColorsRes.shadowBottomBar,
            spreadRadius: 0,
            blurRadius: 5,
            offset: Offset(0, -5),
          )
        ]);
  }

  static BoxDecoration boxDecorationContainerCardShadow(Color color, Color shadowColor, double radius, double x, double y, double b, double s) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(color: shadowColor, offset: Offset(x, y), blurRadius: b, spreadRadius: s),
      ],
    );
  }

  static myScroll(ScrollController scrollController, BuildContext context) async {
    scrollController.addListener(() {
      if (scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        if (!context.read<NavigationBarCubit>().animationController.isAnimating) {
          context.read<NavigationBarCubit>().animationController.forward();
        }
      }
      if (scrollController.position.userScrollDirection == ScrollDirection.forward) {
        if (!context.read<NavigationBarCubit>().animationController.isAnimating) {
          context.read<NavigationBarCubit>().animationController.reverse();
        }
      }
    });
  }
}
