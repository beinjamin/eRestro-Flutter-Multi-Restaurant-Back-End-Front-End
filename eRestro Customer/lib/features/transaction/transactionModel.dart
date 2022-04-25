class TransactionModel {
  String? id;
  String? transactionType;
  String? userId;
  String? orderId;
  String? type;
  String? txnId;
  String? payuTxnId;
  String? amount;
  String? status;
  String? currencyCode;
  String? payerEmail;
  String? message;
  String? transactionDate;
  String? dateCreated;

  TransactionModel(
      {this.id,
        this.transactionType,
        this.userId,
        this.orderId,
        this.type,
        this.txnId,
        this.payuTxnId,
        this.amount,
        this.status,
        this.currencyCode,
        this.payerEmail,
        this.message,
        this.transactionDate,
        this.dateCreated});

  TransactionModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    transactionType = json['transaction_type'];
    userId = json['user_id'];
    orderId = json['order_id'];
    type = json['type'];
    txnId = json['txn_id'];
    payuTxnId = json['payu_txn_id'];
    amount = json['amount'];
    status = json['status'];
    currencyCode = json['currency_code'];
    payerEmail = json['payer_email'];
    message = json['message'];
    transactionDate = json['transaction_date'];
    dateCreated = json['date_created'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['transaction_type'] = this.transactionType;
    data['user_id'] = this.userId;
    data['order_id'] = this.orderId;
    data['type'] = this.type;
    data['txn_id'] = this.txnId;
    data['payu_txn_id'] = this.payuTxnId;
    data['amount'] = this.amount;
    data['status'] = this.status;
    data['currency_code'] = this.currencyCode;
    data['payer_email'] = this.payerEmail;
    data['message'] = this.message;
    data['transaction_date'] = this.transactionDate;
    data['date_created'] = this.dateCreated;
    return data;
  }
}