class OrderLiveTrackingModel {
  String? id;
  String? orderId;
  String? orderStatus;
  String? latitude;
  String? longitude;
  String? dateCreated;

  OrderLiveTrackingModel(
      {this.id,
        this.orderId,
        this.orderStatus,
        this.latitude,
        this.longitude,
        this.dateCreated});

  OrderLiveTrackingModel.fromJson(Map<String, dynamic> json) {
    print(json);
    id = json['id'];
    orderId = json['order_id'];
    orderStatus = json['order_status'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    dateCreated = json['date_created'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['order_id'] = this.orderId;
    data['order_status'] = this.orderStatus;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['date_created'] = this.dateCreated;
    return data;
  }
}