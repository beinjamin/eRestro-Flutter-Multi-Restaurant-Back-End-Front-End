import 'package:erestro/helper/color.dart';
import 'package:erestro/helper/design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
class RadioItem extends StatelessWidget {
    final RadioModel _item;

   RadioItem(this._item, {Key? key}) : super(key: key);

    double? height;
    double? width;

    @override
    Widget build(BuildContext context) {
        height = MediaQuery.of(context).size.height;
        width = MediaQuery.of(context).size.width;
        return Container(
                decoration: DesignConfig.boxDecorationContainerCardShadow(ColorsRes.textFieldBackground, ColorsRes.shadowTextField, 10, 0, 3, 10, 0),
                margin: EdgeInsets.only(bottom: height!/50.0),
                padding: EdgeInsets.symmetric(vertical: height!/40.0, horizontal: height!/40.0),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                        Row(
                            children: [
                                _item.img != "" ? SvgPicture.asset(DesignConfig.setSvgPath(_item.img!),) : Container(),
                                SizedBox(width: height!/99.0),
                                Text(_item.name!,
                                    style: const TextStyle(fontSize: 14, color: ColorsRes.backgroundDark, fontWeight: FontWeight.w500),
                                )
                            ]),
                        Icon(Icons.radio_button_checked,
                            color: _item.isSelected!
                                ? ColorsRes.red
                                : ColorsRes.lightFont,
                        ),
                    ],
                ),
            );
    }
}

class RadioModel {
    bool? isSelected;
    final String? img;
    final String? name;

    RadioModel({this.isSelected, this.name, this.img});
}
