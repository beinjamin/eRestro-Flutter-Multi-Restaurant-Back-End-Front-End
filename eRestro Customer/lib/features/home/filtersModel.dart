class FiltersModel {
  String? attributeValues;
  String? attributeValuesId;
  String? name;
  String? swatcheType;
  String? swatcheValue;

  FiltersModel(
      {this.attributeValues,
        this.attributeValuesId,
        this.name,
        this.swatcheType,
        this.swatcheValue});

  FiltersModel.fromJson(Map<String, dynamic> json) {
    attributeValues = json['attribute_values'];
    attributeValuesId = json['attribute_values_id'];
    name = json['name'];
    swatcheType = json['swatche_type'];
    swatcheValue = json['swatche_value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['attribute_values'] = this.attributeValues;
    data['attribute_values_id'] = this.attributeValuesId;
    data['name'] = this.name;
    data['swatche_type'] = this.swatcheType;
    data['swatche_value'] = this.swatcheValue;
    return data;
  }
}