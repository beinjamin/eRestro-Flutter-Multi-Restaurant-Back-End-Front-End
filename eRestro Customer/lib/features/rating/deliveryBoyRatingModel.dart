class RiderRatingModel {
  bool? error;
  String? message;
  String? noOfRating;
  String? total;
  String? star1;
  String? star2;
  String? star3;
  String? star4;
  String? star5;
  String? riderRating;
  List<Data>? data;

  RiderRatingModel(
      {this.error,
        this.message,
        this.noOfRating,
        this.total,
        this.star1,
        this.star2,
        this.star3,
        this.star4,
        this.star5,
        this.riderRating,
        this.data});

  RiderRatingModel.fromJson(Map<String, dynamic> json) {
    error = json['error'];
    message = json['message'];
    noOfRating = json['no_of_rating'];
    total = json['total'];
    star1 = json['star_1'];
    star2 = json['star_2'];
    star3 = json['star_3'];
    star4 = json['star_4'];
    star5 = json['star_5'];
    riderRating = json['rider_rating'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['error'] = this.error;
    data['message'] = this.message;
    data['no_of_rating'] = this.noOfRating;
    data['total'] = this.total;
    data['star_1'] = this.star1;
    data['star_2'] = this.star2;
    data['star_3'] = this.star3;
    data['star_4'] = this.star4;
    data['star_5'] = this.star5;
    data['rider_rating'] = this.riderRating;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? id;
  String? userId;
  String? RiderId;
  String? rating;
  String? comment;
  String? dataAdded;
  String? userName;
  String? userProfile;
  String? RiderRating;

  Data(
      {this.id,
        this.userId,
        this.RiderId,
        this.rating,
        this.comment,
        this.dataAdded,
        this.userName,
        this.userProfile,
        this.RiderRating});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    RiderId = json['rider_id'];
    rating = json['rating'];
    comment = json['comment'];
    dataAdded = json['data_added'];
    userName = json['user_name'];
    userProfile = json['user_profile'];
    RiderRating = json['rider_rating'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['rider_id'] = this.RiderId;
    data['rating'] = this.rating;
    data['comment'] = this.comment;
    data['data_added'] = this.dataAdded;
    data['user_name'] = this.userName;
    data['user_profile'] = this.userProfile;
    data['rider_rating'] = this.RiderRating;
    return data;
  }
}