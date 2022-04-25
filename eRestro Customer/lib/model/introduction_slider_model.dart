import 'package:erestro/helper/string.dart';

class IntroductionSliderModel {
  int? id;
  String? title;
  String? subTitle;
  String? image;


  IntroductionSliderModel(
      {this.id,
        this.title,
        this.subTitle,
        this.image,});
}

List<IntroductionSliderModel> introductionSliderList = [
  IntroductionSliderModel(
    id: 1,
    title: StringsRes.introTitle1,
    subTitle: StringsRes.introSubTitle1,
    image: "intro_1",
  ),
  IntroductionSliderModel(
    id: 2,
    title: StringsRes.introTitle2,
    subTitle: StringsRes.introSubTitle2,
    image: "intro_2",
  ),
  IntroductionSliderModel(
    id: 1,
    title: StringsRes.introTitle3,
    subTitle: StringsRes.introSubTitle3,
    image: "intro_3",
  ),
];
