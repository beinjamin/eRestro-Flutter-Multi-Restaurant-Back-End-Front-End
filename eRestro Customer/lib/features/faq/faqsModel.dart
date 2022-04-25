class FaqsModel {
  String? id;
  String? question;
  String? answer;
  String? status;

  FaqsModel({this.id, this.question, this.answer, this.status});

  FaqsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    question = json['question'];
    answer = json['answer'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['question'] = this.question;
    data['answer'] = this.answer;
    data['status'] = this.status;
    return data;
  }
}