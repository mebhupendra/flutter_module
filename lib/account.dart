import 'util.dart';

class Account {
  String guid;
  String name;
  double balance;

  Account({required this.guid, required this.name, required this.balance});

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
        guid: json['guid'],
        name: json['name'],
        balance: checkDouble(json['balance']));
  }
}
