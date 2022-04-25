import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class NavigationBarState {
  final AnimationController? animationController;

  NavigationBarState(this.animationController);
}

class NavigationBarCubit extends Cubit<NavigationBarState> {
  NavigationBarCubit() : super(NavigationBarState(null));

  void setAnimationController(AnimationController animationController) {
    emit(NavigationBarState(animationController));
  }
  AnimationController get animationController => state.animationController!;
  AnimationController? getAnimationController() {
    return state.animationController;
  }

}