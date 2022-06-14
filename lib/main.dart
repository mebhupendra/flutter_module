import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      body: Center(child: JSONListView()),
    ));
  }
}

double checkDouble(dynamic value) {
  if (value is String) {
    return double.parse(value);
  } else {
    return value.toDouble();
  }
}

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

class Transaction {
  String description;
  double amount;

  Transaction({required this.description, required this.amount});

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
        description: json['description'], amount: checkDouble(json['amount']));
  }
}

class JSONListView extends StatefulWidget {
  AccountsListView createState() => AccountsListView();
}

class AccountsListView extends State {
  final platform = const MethodChannel("com.flutter.mx/mx");

  Future<List<Account>> fetchAccounts() async {
    var jsonResponse = await getAccounts();
    // const jsonResponse =
    //     """[{"id":2,"created_at":"2022-05-17T17:21:23-06:00","updated_at":"2022-05-17T17:21:23-06:00","account_type":9,"balance":45.70,"guid":"ACT-335b6979-3ba5-41f0-9aca-51cab3dc62da","has_monthly_transfer_limit":false,"institution_guid":"INS-MANUAL-cb5c-1d48-741c-b30f4ddd1730","is_closed":false,"is_hidden":false,"is_manual":true,"is_personal":true,"member_guid":"MBR-3bb58754-629f-4d86-8fa9-c23556f6d44a","member_is_managed_by_user":true,"name":"ABC Bank","revision":4,"user_guid":"USR-8bf3762f-538d-4f74-8d47-a64f087e59fd"},{"id":1,"created_at":"2022-05-17T17:21:23-06:00","updated_at":"2022-05-17T17:21:23-06:00","account_type":8,"balance":10,"guid":"ACT-eb763c5b-dbe7-4d17-ae0d-bcca40988c1e","has_monthly_transfer_limit":false,"institution_guid":"INS-MANUAL-cb5c-1d48-741c-b30f4ddd1730","is_closed":false,"is_hidden":false,"is_manual":true,"is_personal":true,"member_guid":"MBR-3bb58754-629f-4d86-8fa9-c23556f6d44a","member_is_managed_by_user":true,"name":"Test","property_type":0,"revision":1,"user_guid":"USR-8bf3762f-538d-4f74-8d47-a64f087e59fd"}]""";
    if (jsonResponse.isNotEmpty) {
      final jsonItems = json.decode(jsonResponse).cast<Map<String, dynamic>>();
      List<Account> accountList = jsonItems.map<Account>((json) {
        return Account.fromJson(json);
      }).toList();
      return accountList;
    } else {
      throw Exception('Failed to load account data');
    }
  }

  Future<String> getAccounts() async {
    String accountsJson = "";
    try {
      accountsJson = await platform.invokeMethod("getAccounts");
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    if (kDebugMode) {
      print(accountsJson);
    }
    return accountsJson;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => SystemNavigator.pop(),
        ),
        title: const Text('EPIC Bank - Accounts'),
      ),
      body: FutureBuilder<List<Account>>(
        future: fetchAccounts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: snapshot.data!
                .map(
                  (account) => ListTile(
                    title: Text(account.name),
                    subtitle: Text('Balance: ' + account.balance.toString()),
                    leading: CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Text(
                        account.name[0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                    //trailing: Text(account.balance.toString()),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailScreen(account: account),
                        ),
                      );
                    },
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  // In the constructor, require a Todo.
  const DetailScreen({super.key, required this.account});
  // Declare a field that holds the Todo.
  final Account account;
  final platform = const MethodChannel("com.flutter.mx/mx");

  Future<List<Transaction>> fetchTransactions() async {
    var jsonResponse = await getTransactions(account.guid);
    if (jsonResponse.isNotEmpty) {
      final jsonItems = json.decode(jsonResponse).cast<Map<String, dynamic>>();
      List<Transaction> transactionList = jsonItems.map<Transaction>((json) {
        return Transaction.fromJson(json);
      }).toList();
      return transactionList;
    } else {
      throw Exception('Failed to load transaction data');
    }
  }

  Future<String> getTransactions(String guid) async {
    String transactionsJson = "";
    try {
      transactionsJson = await platform
          .invokeMethod("getTransactions", {"account_guid": account.guid});
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    if (kDebugMode) {
      print(transactionsJson);
    }
    return transactionsJson;
  }

  @override
  Widget build(BuildContext context) {
    // Use the Todo to create the UI.
    return Scaffold(
      appBar: AppBar(
        title: Text(account.name),
      ),
      body: FutureBuilder<List<Transaction>>(
        future: fetchTransactions(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: snapshot.data!
                .map(
                  (transaction) => ListTile(
                    title: Text(transaction.description),
                    subtitle: Text('Amount: ' + transaction.amount.toString()),
                    leading: CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Text(
                        //account.name[0],
                        transaction.description[0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}
