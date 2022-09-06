double checkDouble(dynamic value) {
  if (value is String) {
    return double.parse(value);
  } else {
    return value.toDouble();
  }
}

class Transaction {
  String description;
  double amount;

  Transaction({required this.description, required this.amount});

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
        description: json['description'], amount: checkDouble(json['amount']));
  }
}
