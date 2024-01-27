import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_wise/app_state.dart';

import 'bucket.dart';
import 'expense_details_page.dart';
import 'month.dart';

class Expense extends StatelessWidget {
  final num centsCost;
  final String bucketId;
  final String? name;

  final DateTime forMonth;
  final DateTime lastModified;
  final DateTime created;

  final bool isReadOnly;

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
      this.id = "not a valid expense ID",
      this.isReadOnly = false});

  Expense toReadOnly() {
    return Expense(
      centsCost: centsCost,
      bucketId: bucketId,
      forMonth: forMonth,
      lastModified: lastModified,
      created: created,
      id: id,
      isReadOnly: true,
    );
  }

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

  static updateBucketCents(
      Transaction transaction, String bucketId, num positiveDiff) async {
    var bucketDoc = Bucket.dbCollection.doc(bucketId);
    var bucket = (await transaction.get(bucketDoc)).data()!;

    transaction.set(
        bucketDoc,
        Bucket(
          name: bucket.name,
          amountCents: bucket.amountCents + positiveDiff,
          iconData: bucket.icon.icon!,
          perMonthAmountCents: bucket.perMonthAmountCents,
        ));
  }

  static Future<String> insert(Expense expense) async {
    return await FirebaseFirestore.instance.runTransaction((transaction) async {
      await updateBucketCents(
          transaction, expense.bucketId, -expense.centsCost);

      var newExpenseDoc = Expense.dbCollection.doc();
      transaction.set(newExpenseDoc, expense);
      expense.id = newExpenseDoc.id;

      return newExpenseDoc.id;
    });
  }

  Future<String> update(Expense newExpense) async {
    return await FirebaseFirestore.instance.runTransaction((transaction) async {
      var bucket1Doc = Bucket.dbCollection.doc(bucketId);
      var bucket1 = (await transaction.get(bucket1Doc)).data()!;
      var bucket2Doc = Bucket.dbCollection.doc(newExpense.bucketId);
      var bucket2 = (await transaction.get(bucket2Doc)).data()!;

      if (bucketId == newExpense.bucketId) {
        transaction.set(
            bucket2Doc,
            Bucket(
              name: bucket2.name,
              amountCents:
                  bucket2.amountCents - newExpense.centsCost + centsCost,
              iconData: bucket2.icon.icon!,
              perMonthAmountCents: bucket2.perMonthAmountCents,
            ));
      } else {
        transaction.set(
            bucket1Doc,
            Bucket(
              name: bucket1.name,
              amountCents: bucket1.amountCents + centsCost,
              iconData: bucket1.icon.icon!,
              perMonthAmountCents: bucket1.perMonthAmountCents,
            ));

        transaction.set(
            bucket2Doc,
            Bucket(
              name: bucket2.name,
              amountCents: bucket2.amountCents - newExpense.centsCost,
              iconData: bucket2.icon.icon!,
              perMonthAmountCents: bucket2.perMonthAmountCents,
            ));
      }

      transaction.update(Expense.dbCollection.doc(id), newExpense.toJson());
      newExpense.id = id;

      return id;
    });
  }

  Future<void> remove() async {
    return await FirebaseFirestore.instance.runTransaction((transaction) async {
      await updateBucketCents(transaction, bucketId, centsCost);

      transaction.delete(Expense.dbCollection.doc(id));

      return;
    });
  }

  static String formattedCost(num centsCost, [dollarSign = true]) {
    return formattedCostString(
        "${centsCost < 0 ? "-" : ""}${centsCost ~/ 100}.${centsCost.remainder(100).abs().toString().padLeft(2, "0")}",
        dollarSign);
  }

  static String formattedCostString(String centsCost, [dollarSign = true]) {
    final negativeSign = centsCost.startsWith("-");
    final text = centsCost.replaceAll(RegExp(r"[,-]"), "");
    final splitText = text.split(".");
    final dollarsText = splitText[0].codeUnits;
    final centsText = splitText.elementAtOrNull(1);

    final dollarsChunks = dollarsText.reversed
        .slices(3)
        .map((e) => e.reversed)
        .map((e) => String.fromCharCodes(e))
        .toList()
        .reversed;

    return "${negativeSign ? "-" : ""}${dollarSign ? "\$" : ""}${dollarsChunks.join(",")}${centsText != null ? ".$centsText" : ""}";
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
    final listTile = ListTile(
      title: Row(
        children: [
          Text(formattedCost(centsCost)),
          const Spacer(),
          Text(Month.format(forMonth)),
        ],
      ),
      subtitle: Row(
        children: [
          Consumer<ApplicationState>(
            builder: (_, appState, __) => Text(
                appState.buckets.where((b) => b.id == bucketId).first.name),
          ),
          const SizedBox(width: 10),
          Text(name ?? ""),
        ],
      ),
    );

    return Row(
      children: [
        Expanded(
          child: isReadOnly
              ? listTile
              : MaterialButton(
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
                  child: listTile,
                ),
        ),
      ],
    );
  }
}
