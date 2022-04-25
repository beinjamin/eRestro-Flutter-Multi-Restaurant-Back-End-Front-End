class TicketModel {
  String? id;
  String? ticketTypeId;
  String? userId;
  String? subject;
  String? email;
  String? description;
  String? status;
  String? lastUpdated;
  String? dateCreated;
  String? name;
  String? ticketType;

  TicketModel(
      {this.id,
        this.ticketTypeId,
        this.userId,
        this.subject,
        this.email,
        this.description,
        this.status,
        this.lastUpdated,
        this.dateCreated,
        this.name,
        this.ticketType});

  TicketModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    ticketTypeId = json['ticket_type_id'];
    userId = json['user_id'];
    subject = json['subject'];
    email = json['email'];
    description = json['description'];
    status = json['status'];
    lastUpdated = json['last_updated'];
    dateCreated = json['date_created'];
    name = json['name'];
    ticketType = json['ticket_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['ticket_type_id'] = this.ticketTypeId;
    data['user_id'] = this.userId;
    data['subject'] = this.subject;
    data['email'] = this.email;
    data['description'] = this.description;
    data['status'] = this.status;
    data['last_updated'] = this.lastUpdated;
    data['date_created'] = this.dateCreated;
    data['name'] = this.name;
    data['ticket_type'] = this.ticketType;
    return data;
  }
}