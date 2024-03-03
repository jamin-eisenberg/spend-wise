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
  final num? estimatedMonthlyIncome;
  final DateTime? bucketTransferDate;
  final Month? nextMonth;

  // bucketId -> (amount before transfer for this month, transfer amount this month)
  final Map<String, (num, num)>? bucketAmounts;

  const Month({
    super.key,
    required this.month,
    required this.expenses,
    required this.allAccountsTotal,
    required this.bucketTransferDate,
    this.nextMonth,
    required this.estimatedMonthlyIncome,
    required this.bucketAmounts,
  });

  static final CollectionReference<Month> dbCollection = FirebaseFirestore
      .instance
      .collection('users/${FirebaseAuth.instance.currentUser!.uid}/months')
      .withConverter(
          fromFirestore: (snapshot, _) =>
              Month.fromJson(snapshot.data() ?? {}, snapshot.id),
          toFirestore: (m, _) => m.toJson());

  static Month fromJson(Map<String, dynamic> json, String id) {
    final monthYear = id.split("-");
    final bucketAmounts = json['bucketAmounts'] as Map<String, dynamic>?;
    return Month(
      month: DateTime(int.parse(monthYear[1]), int.parse(monthYear[0])),
      expenses: [],
      // will be filled in before being displayed
      allAccountsTotal: json['allAccountsTotal'] as num?,
      estimatedMonthlyIncome: json['estimatedMonthlyIncome'] as num?,
      bucketTransferDate: (json['bucketTransferDate'] as Timestamp?)?.toDate(),
      bucketAmounts: bucketAmounts == null
          ? null
          : {
              for (final entry in bucketAmounts.entries)
                entry.key: (entry.value[0], entry.value[1])
            },
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'allAccountsTotal': allAccountsTotal,
      'estimatedMonthlyIncome': estimatedMonthlyIncome,
      'bucketTransferDate': bucketTransferDate == null
          ? null
          : Timestamp.fromDate(bucketTransferDate!),
      'bucketAmounts': bucketAmounts == null ? null : {
        for (final entry in bucketAmounts!.entries)
          entry.key: [entry.value.$1, entry.value.$2]
      }
    };
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Month{month: $month, expenses: $expenses, allAccountsTotal: $allAccountsTotal, bucketTransferDate: $bucketTransferDate, estimatedMonthlyIncome: $estimatedMonthlyIncome}';
  }

  static String format(DateTime month) {
    return "${month.month.toString().padLeft(2, "0")}/${month.year}";
  }

  static Future<String> update(Month month) async {
    final id = Month.format(month.month).replaceAll("/", "-");
    await dbCollection.doc(id).set(month);
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
              nextMonth: nextMonth,
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
            : Text(
                "Accounts total: ${Expense.formattedCost(allAccountsTotal!)}"),
      ),
    );
  }
}
