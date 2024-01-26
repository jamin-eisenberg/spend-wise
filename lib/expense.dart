import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_wise/app_state.dart';

import 'bucket.dart';
import 'expense_details_page.dart';

class Expense extends StatelessWidget {
  final num centsCost;
  final String bucketId;
  final String? name;

  final DateTime forMonth;
  final DateTime lastModified;
  final DateTime created;

  String id;

  static final CollectionReference<Expense> dbCollection = FirebaseFirestore
      .instance
      .collection('users/${FirebaseAuth.instance.currentUser!.uid}/expenses')
      .withConverter(
          fromFirestore: (snapshot, _) =>
              Expense.fromJson(snapshot.data() ?? {}, snapshot.id),
          toFirestore: (e, _) => e.toJson());

  Expense(
      {super.key,
      required this.centsCost,
      required this.bucketId,
      required this.forMonth,
      required this.lastModified,
      required this.created,
      this.name,
      this.id = "not a valid expense ID"});

  Map<String, dynamic> toJson() {
    return {
      'centsCost': centsCost,
      'bucket': Bucket.dbCollection.doc(bucketId),
      'forMonth': forMonth,
      'lastModified': lastModified,
      'created': created,
      'name': name,
    };
  }

  static Expense fromJson(Map<String, dynamic> json, String id) {
    return Expense(
        name: json['name'],
        centsCost: json['centsCost'] as num,
        bucketId:
            (json['bucket'] as DocumentReference<Map<String, dynamic>>).id,
        forMonth: (json['forMonth'] as Timestamp).toDate(),
        lastModified: (json['lastModified'] as Timestamp).toDate(),
        created: (json['created'] as Timestamp).toDate(),
        id: id);
  }

  static Future<String> insert(Expense expense) {
    print("Inserting $expense...");
    return Expense.dbCollection.add(expense).then((value) {
      expense.id = value.id;
      return value.id;
    });
  }

  Future<String> update(Expense newExpense) {
    return Expense.dbCollection.doc(id).set(newExpense).then((value) => id);
  }

  Future<void> remove() {
    return Expense.dbCollection.doc(id).delete();
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

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Expense{centsCost: $centsCost, bucketId: $bucketId, name: $name, forMonth: $forMonth, lastModified: $lastModified, created: $created}';
  }

  bool sameAs(Object other) =>
      identical(this, other) ||
      super == other &&
          other is Expense &&
          runtimeType == other.runtimeType &&
          centsCost == other.centsCost &&
          bucketId == other.bucketId &&
          name == other.name &&
          created == other.created;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: MaterialButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (s) => ExpenseDetailsPage(
                    expense: this,
                    updateDb: update,
                  ),
                ),
              );
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
                  Consumer<ApplicationState>(
                    builder: (_, appState, __) => Text(appState.buckets
                        .where((b) => b.id == bucketId)
                        .first
                        .bucketName),
                  ),
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
