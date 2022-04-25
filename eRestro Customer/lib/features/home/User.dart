import 'package:intl/intl.dart';

class User {
  String? username,
  userProfile,
      email,
      mobile,
      address,
      dob,
      city,
      area,
      street,
      password,
      pincode,
      fcmId,
      latitude,
      longitude,
      userId,
      name,
      deliveryCharge,
      freeAmt;

  List<String>? imgList;
  String? id, date, comment, rating;

  String? type, altMob, landmark, areaId, cityId, isDefault, state, country;

  User(
      {this.id,
      this.username,
        this.userProfile,
      this.date,
      this.rating,
      this.comment,
      this.email,
      this.mobile,
      this.address,
      this.dob,
      this.city,
      this.area,
      this.street,
      this.password,
      this.pincode,
      this.fcmId,
      this.latitude,
      this.longitude,
      this.userId,
      this.name,
      this.type,
      this.altMob,
      this.landmark,
      this.areaId,
      this.cityId,
      this.imgList,
      this.isDefault,
      this.state,
      this.deliveryCharge,
      this.freeAmt,
      this.country});

  factory User.forReview(Map<String, dynamic> parsedJson) {
    String date = parsedJson['data_added'];
    var allSttus = parsedJson['images'];
    List<String> item = [];

    for (String i in allSttus) item.add(i);

    date = DateFormat('dd-MM-yyyy').format(DateTime.parse(date));

    return User(
      id: parsedJson['id'],
      date: date,
      rating: parsedJson['rating'],
      comment: parsedJson['comment'],
      imgList: item,
      username: parsedJson['user_name'],
      userProfile: parsedJson["user_profile"],
    );
  }



  factory User.fromJson(Map<String, dynamic> parsedJson) {
    return User(
      id: parsedJson['id'],
      username: parsedJson['user_name'],
      email: parsedJson['email'],
      mobile: parsedJson['mobile'],
      address: parsedJson['address'],
     
      city: parsedJson['city'],
      area: parsedJson['area'],
    
    
      pincode: parsedJson['pincode'],
      fcmId: parsedJson['fcm_id'],
      latitude: parsedJson['latitude'],
      longitude: parsedJson['longitude'],
      userId: parsedJson['user_id'],
      name: parsedJson['name'],
    );
  }

  factory User.fromAddress(Map<String, dynamic> parsedJson) {
    return User(
        id: parsedJson['id'],
        mobile: parsedJson['mobile'],
        address: parsedJson['address'],
        altMob: parsedJson['alternate_mobile'],
        cityId: parsedJson['city_id'],
        areaId: parsedJson['area_id'],
        area: parsedJson['area'],
        city: parsedJson['city'],
        landmark: parsedJson['landmark'],
        state: parsedJson['state'],
        pincode: parsedJson['pincode'],
        country: parsedJson['country'],
        latitude: parsedJson['latitude'],
        longitude: parsedJson['longitude'],
        userId: parsedJson['user_id'],
        name: parsedJson['name'],
        type: parsedJson['type'],
        deliveryCharge: parsedJson['delivery_charges'],
        freeAmt: parsedJson['minimum_free_delivery_order_amount'],
        isDefault: parsedJson['is_default']);
  }
}

class imgModel{
  int? index;
  String? img;

  imgModel({this.index,this.img});
  factory imgModel.fromJson(int i,String image) {
    return imgModel(
      index: i,
      img:image
    );
  }

}
