class HelpAndSupportModel {
  String? id;
  String? title;
  String? dateCreated;

  HelpAndSupportModel({this.id, this.title, this.dateCreated});

  HelpAndSupportModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    dateCreated = json['date_created'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['date_created'] = this.dateCreated;
    return data;
  }
}