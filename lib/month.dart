import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:spend_wise/month_details_page.dart';

import 'expense.dart';

class Month extends StatelessWidget {
  final DateTime month;
  final List<Expense> expenses;
  final num? allAccountsTotal;

  const Month({
    super.key,
    required this.month,
    required this.expenses,
    this.allAccountsTotal,
  });

  static final CollectionReference<Map<String, dynamic>> dbCollection =
      FirebaseFirestore.instance
          .collection('users/${FirebaseAuth.instance.currentUser!.uid}/months');

  static String format(DateTime month) {
    return "${month.month.toString().padLeft(2, "0")}/${month.year}";
  }

  static Future<String> update(Month month) async {
    final id = Month.format(month.month).replaceAll("/", "-");
    await dbCollection.doc(id).set({
      'month': Timestamp.fromDate(month.month),
      'allAccountsTotal': month.allAccountsTotal,
    });
    return id;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (s) => MonthDetailsPage(
              month: this,
              updateDb: update,
            ),
          ),
        );
      },
      child: ListTile(
        title: Row(
          children: [
            Text(format(month)),
            const Spacer(),
            Text(
                "Total expenses: ${Expense.formattedCost(expenses.map((e) => e.centsCost).sum)}"),
          ],
        ),
        subtitle: allAccountsTotal == null
            ? null
            : Text("Accounts total: ${Expense.formattedCost(allAccountsTotal!)}"),
      ),
    );
  }
}
