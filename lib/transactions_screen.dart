import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'account.dart';
import 'transaction.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key, required this.account});

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
