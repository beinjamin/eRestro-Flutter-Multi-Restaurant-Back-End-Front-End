import 'package:erestro/utils/apiBodyParameterLabels.dart';

class NotificationModel {
  final String? id, title, message, type, typeId, image, dateSent;

  NotificationModel({this.id, this.title, this.message, this.type, this.typeId, this.image, this.dateSent});
  static NotificationModel fromJson(Map<String, dynamic> jsonData) {
    return NotificationModel(id: jsonData["id"], title: jsonData["title"], message: jsonData["message"], type: jsonData[typeKey], typeId: jsonData["type_id"], image: jsonData["image"], dateSent: jsonData["date_sent"]);
  }
}
