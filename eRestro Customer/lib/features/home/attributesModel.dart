class AttributesModel {
  String? ids;
  String? value;
  String? attrName;
  String? name;
  String? swatcheType;
  String? swatcheValue;

  AttributesModel(
      {this.ids,
        this.value,
        this.attrName,
        this.name,
        this.swatcheType,
        this.swatcheValue});

  AttributesModel.fromJson(Map<String, dynamic> json) {
    ids = json['ids'];
    value = json['value'];
    attrName = json['attr_name'];
    name = json['name'];
    swatcheType = json['swatche_type'];
    swatcheValue = json['swatche_value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ids'] = this.ids;
    data['value'] = this.value;
    data['attr_name'] = this.attrName;
    data['name'] = this.name;
    data['swatche_type'] = this.swatcheType;
    data['swatche_value'] = this.swatcheValue;
    return data;
  }
}