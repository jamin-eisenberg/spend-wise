import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'expense.dart';

class Month extends StatelessWidget {
  final DateTime month;
  final List<Expense> expenses;
  final num? allAccountsTotal;

  const Month({super.key, required this.month, required this.expenses, this.allAccountsTotal});

  static final CollectionReference<Map<String, dynamic>> dbCollection =
  FirebaseFirestore.instance
      .collection('users/${FirebaseAuth.instance.currentUser!.uid}/months');

  static String format(DateTime month) {
    return "${month.month.toString().padLeft(2, "0")}/${month.year}";
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        children: [
          Text(format(month)),
          // SizedBox.fromSize(size: const Size(10, 0)),
          // Text(bucketName),
          // const Spacer(),
          // Text(Expense.formattedCost(amountCents)),
        ],
      ),
    );
  }
}
