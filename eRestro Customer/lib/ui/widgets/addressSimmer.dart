import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AddressSimmer extends StatelessWidget {
  final double? width, height;
  const AddressSimmer({Key? key, this.width, this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(child: Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      // enabled: _enabled,
      child: ListView.builder(shrinkWrap: true,
        itemBuilder: (_, __) => Container(
          margin: EdgeInsets.only(bottom: height!/99.0),
          padding: EdgeInsets.symmetric(vertical: height!/40.0, horizontal: height!/40.0),
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
                      width: 40.0,
                      height: 10.0,
                      color: Colors.white,
                    ),
                    SizedBox(height: height!/99.0),
                    Container(
                      width: double.maxFinite,
                      height: 10.0,
                      color: Colors.white,
                    ),
                    SizedBox(height: height!/99.0),
                    Row(mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(margin: EdgeInsets.only(right: width!/99.0, top: height!/99.0), width: width!/5.0, padding: EdgeInsets.only(top: height!/99.0, bottom: height!/99.0,),
                          height: 30.0,
                          color: Colors.white,
                        ),
                        SizedBox(width: height!/99.0),
                        Container(margin: EdgeInsets.only(left: width!/15.0, right: width!/99.0, top: height!/99.0), width: width!/5.0, padding: EdgeInsets.only(top: height!/99.0, bottom: height!/99.0,),
                          height: 30.0,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 2.0),
                    ),
                    Container(
                      width: double.maxFinite,
                      height: 2.0,
                      color: Colors.white,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        itemCount: 3,
      ),
    ),
    );
  }
}
