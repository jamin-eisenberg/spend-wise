import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'bucket.dart';
import 'expense_details_page.dart';

class Expense extends StatelessWidget {
  final num centsCost;
  final Bucket bucket;
  final String? name;

  final DateTime forMonth;
  final DateTime lastModified;
  final DateTime created;

  final void Function(Expense, Expense) setExpense;
  final List<Bucket> possibleBuckets;

  static final CollectionReference<Expense> dbExpensesCollection = FirebaseFirestore.instance
      .collection('users/${FirebaseAuth.instance.currentUser!.uid}/expenses')
      .withConverter(
          fromFirestore: (snapshot, _) => Expense.fromJson(snapshot.data() ?? {}),
          toFirestore: (e, _) => e.toJson());

  const Expense(
      {super.key,
      required this.centsCost,
      required this.bucket,
      required this.forMonth,
      required this.lastModified,
      required this.created,
      this.name,
      required this.possibleBuckets,
      required this.setExpense});

  Map<String, dynamic> toJson() {
    return {
      'centsCost': centsCost,
      'bucket': FirebaseFirestore.instance.doc("bucket"),
      'forMonth': forMonth,
      'lastModified': lastModified,
      'created': created,
      'name': name,
    };
  }

  static Expense fromJson(Map<String, dynamic> json) {
    return Expense(
        centsCost: 0,
        bucket: Bucket(
          bucketName: '',
          iconData: Icons.signal_cellular_null,
          amountCents: 0,
        ),
        forMonth: DateTime.now(),
        lastModified: DateTime.now(),
        created: DateTime.now(),
        possibleBuckets: [],
        setExpense: (_, __) {});
  }

  static String formattedCost(num centsCost) {
    return formattedCostString(
        "${centsCost ~/ 100}.${"${centsCost % 100}".padLeft(2, "0")}");
  }

  static String formattedCostString(String centsCost) {
    final text = centsCost.replaceAll(",", "");
    final splitText = text.split(".");
    final dollarsText = splitText[0].codeUnits;
    final centsText = splitText.elementAtOrNull(1);

    final dollarsChunks = dollarsText.reversed
        .slices(3)
        .map((e) => e.reversed)
        .map((e) => String.fromCharCodes(e))
        .toList()
        .reversed;

    return "${dollarsChunks.join(",")}${centsText != null ? ".$centsText" : ""}";
  }

  bool sameAs(Object other) =>
      identical(this, other) ||
      super == other &&
          other is Expense &&
          runtimeType == other.runtimeType &&
          centsCost == other.centsCost &&
          bucket == other.bucket &&
          name == other.name &&
          created == other.created;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: MaterialButton(
            onPressed: () async {
              final newExpense = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (s) => ExpenseDetailsPage(
                    expense: this,
                    possibleBuckets: possibleBuckets,
                    setExpense: setExpense,
                  ),
                ),
              );
              setExpense(this, newExpense);
            },
            child: ListTile(
              title: Row(
                children: [
                  Text("\$${formattedCost(centsCost)}"),
                  const Spacer(),
                  Text(
                      "${forMonth.month.toString().padLeft(2, "0")}/${forMonth.year}"),
                ],
              ),
              subtitle: Row(
                children: [
                  Text(bucket.bucketName),
                  SizedBox.fromSize(
                    size: const Size(10, 0),
                  ),
                  Text(name ?? ""),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
