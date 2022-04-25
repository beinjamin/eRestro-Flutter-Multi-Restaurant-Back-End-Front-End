class RestaurantWorkingTimeModel {
  String? id;
  String? restaurantId;
  String? day;
  String? openingTime;
  String? closingTime;
  String? isOpen;
  String? dateCreated;

  RestaurantWorkingTimeModel(
      {this.id,
        this.restaurantId,
        this.day,
        this.openingTime,
        this.closingTime,
        this.isOpen,
        this.dateCreated});

  RestaurantWorkingTimeModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    restaurantId = json['partner_id'];
    day = json['day'];
    openingTime = json['opening_time'];
    closingTime = json['closing_time'];
    isOpen = json['is_open'];
    dateCreated = json['date_created'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['partner_id'] = this.restaurantId;
    data['day'] = this.day;
    data['opening_time'] = this.openingTime;
    data['closing_time'] = this.closingTime;
    data['is_open'] = this.isOpen;
    data['date_created'] = this.dateCreated;
    return data;
  }
}