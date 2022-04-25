class ChatModel {
  String? id;
  String? userType;
  String? userId;
  String? ticketId;
  String? message;
  String? name;
  List<Attachments>? attachments;
  String? subject;
  String? lastUpdated;
  String? dateCreated;

  ChatModel(
      {this.id,
        this.userType,
        this.userId,
        this.ticketId,
        this.message,
        this.name,
        this.attachments,
        this.subject,
        this.lastUpdated,
        this.dateCreated});

  ChatModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userType = json['user_type'];
    userId = json['user_id'];
    ticketId = json['ticket_id'];
    message = json['message'];
    name = json['name'];
    if (json['attachments'] != null) {
      attachments = <Attachments>[];
      json['attachments'].forEach((v) {
        attachments!.add(new Attachments.fromJson(v));
      });
    }
    subject = json['subject'];
    lastUpdated = json['last_updated'];
    dateCreated = json['date_created'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_type'] = this.userType;
    data['user_id'] = this.userId;
    data['ticket_id'] = this.ticketId;
    data['message'] = this.message;
    data['name'] = this.name;
    if (this.attachments != null) {
      data['attachments'] = this.attachments!.map((v) => v.toJson()).toList();
    }
    data['subject'] = this.subject;
    data['last_updated'] = this.lastUpdated;
    data['date_created'] = this.dateCreated;
    return data;
  }
}

class Attachments {
  String? media;
  String? type;

  Attachments({this.media, this.type});

  Attachments.fromJson(Map<String, dynamic> json) {
    media = json['media'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['media'] = this.media;
    data['type'] = this.type;
    return data;
  }
}