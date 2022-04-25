class AddOnsDataModel {
  String? id;
  String? userId;
  String? productId;
  String? productVariantId;
  String? addOnId;
  String? qty;
  String? dateCreated;
  String? title;
  String? description;
  String? price;
  String? calories;
  String? status;

  AddOnsDataModel(
      {this.id,
        this.userId,
        this.productId,
        this.productVariantId,
        this.addOnId,
        this.qty,
        this.dateCreated,
        this.title,
        this.description,
        this.price,
        this.calories,
        this.status});

  AddOnsDataModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    productId = json['product_id'];
    productVariantId = json['product_variant_id'];
    addOnId = json['add_on_id'];
    qty = json['qty'];
    dateCreated = json['date_created'];
    title = json['title'];
    description = json['description'];
    price = json['price'];
    calories = json['calories'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['product_id'] = this.productId;
    data['product_variant_id'] = this.productVariantId;
    data['add_on_id'] = this.addOnId;
    data['qty'] = this.qty;
    data['date_created'] = this.dateCreated;
    data['title'] = this.title;
    data['description'] = this.description;
    data['price'] = this.price;
    data['calories'] = this.calories;
    data['status'] = this.status;
    return data;
  }
}