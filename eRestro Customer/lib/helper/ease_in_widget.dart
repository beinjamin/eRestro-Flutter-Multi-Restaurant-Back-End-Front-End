import 'package:flutter/material.dart';

class EaseInWidget extends StatefulWidget {
  final Widget? child;
  final Function onTap;
  const EaseInWidget({Key? key, this.child, required this.onTap})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => _EaseInWidgetState();
}

class _EaseInWidgetState extends State<EaseInWidget>
    with TickerProviderStateMixin<EaseInWidget> {
  late AnimationController controller;
  late Animation<double> easeInAnimation;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        vsync: this,
        duration: const Duration(
          milliseconds: 200,
        ),
        value: 1.0);
    //easeInAnimation = Tween(begin: 1.0, end: 0.95).animate(
    easeInAnimation = Tween(begin: 1.0, end: 0.25).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeIn,
      ),
    );
    controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.onTap == null) {
          return;
        }
        controller.forward().then((val) {
          controller.reverse().then((val) {
            widget.onTap();
          });
        });
      },
      child: ScaleTransition(
        scale: easeInAnimation,
        child: widget.child,
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
