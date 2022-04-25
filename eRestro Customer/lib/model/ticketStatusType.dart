class TicketStatusModel {
  String? id;
  String? title;


  TicketStatusModel(
      {this.id,
        this.title,});
}

List<TicketStatusModel> ticketStatusList = [
  TicketStatusModel(
    id: "1",
    title: "pending",
  ),
  TicketStatusModel(
    id: "2",
    title: "opened",
  ),
  TicketStatusModel(
    id: "3",
    title: "resolved",
  ),
  TicketStatusModel(
    id: "4",
    title: "closed",
  ),
  TicketStatusModel(
    id: "5",
    title: "reopened",
  ),
];