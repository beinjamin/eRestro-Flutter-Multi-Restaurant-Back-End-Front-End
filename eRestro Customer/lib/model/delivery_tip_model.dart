class DeliveryTipModel {
  String? id;
  String? price;
  String? like;

  DeliveryTipModel({
    this.id,
    this.price,
    this.like,
  });
}

List<DeliveryTipModel> deliveryTipList = [
  DeliveryTipModel(id: "1", price: "10", like: "0"),
  DeliveryTipModel(id: "2", price: "20", like: "0"),
  DeliveryTipModel(id: "3", price: "30", like: "0"),
  DeliveryTipModel(id: "4", price: "40", like: "0"),
  DeliveryTipModel(id: "5", price: "50", like: "0"),
];
