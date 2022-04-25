class VariantAttributesModel {
  String? ids;
  String? values;
  String? swatcheType;
  String? swatcheValue;
  String? attrName;

  VariantAttributesModel(
      {this.ids,
        this.values,
        this.swatcheType,
        this.swatcheValue,
        this.attrName});

  VariantAttributesModel.fromJson(Map<String, dynamic> json) {
    ids = json['ids'];
    values = json['values'];
    swatcheType = json['swatche_type'];
    swatcheValue = json['swatche_value'];
    attrName = json['attr_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ids'] = this.ids;
    data['values'] = this.values;
    data['swatche_type'] = this.swatcheType;
    data['swatche_value'] = this.swatcheValue;
    data['attr_name'] = this.attrName;
    return data;
  }
}