import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:spend_wise/bucket_details_page.dart';

import 'expense.dart';

class Bucket extends StatelessWidget {
  late final Icon icon;
  final String name;
  final num amountCents;
  final num perMonthAmountCents;
  final num goalCents;

  String id;

  static final CollectionReference<Bucket> dbCollection = FirebaseFirestore
      .instance
      .collection('users/${FirebaseAuth.instance.currentUser!.uid}/buckets')
      .withConverter(
          fromFirestore: (snapshot, _) =>
              Bucket.fromJson(snapshot.data() ?? {}, snapshot.id),
          toFirestore: (b, _) => b.toJson());

  Bucket(
      {super.key,
      required this.name,
      required this.amountCents,
      required IconData iconData,
      this.id = "not a valid bucket ID",
      required this.perMonthAmountCents,
      required this.goalCents}) {
    icon = Icon(iconData);
  }

  static Bucket fromJson(Map<String, dynamic> json, String id) {
    return Bucket(
      name: json['name'],
      iconData:
          IconData(json['iconCodePoint'] as int, fontFamily: "MaterialIcons"),
      amountCents: json['amountCents'],
      id: id,
      perMonthAmountCents: json['perMonthAmountCents'] as num,
      goalCents: json['goalCents'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'iconCodePoint': icon.icon!.codePoint,
      'amountCents': amountCents,
      'perMonthAmountCents': perMonthAmountCents,
      'goalCents': goalCents,
    };
  }

  static Future<String> update(Bucket bucket) async {
    await dbCollection.doc(bucket.id).set(bucket);
    return bucket.id;
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Bucket{icon: $icon, name: $name, amountCents: $amountCents}';
  }

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (s) => BucketDetailsPage(
              bucket: this,
              updateDb: update,
            ),
          ),
        );
      },
      child: ListTile(
        title: Row(
          children: [
            icon,
            const SizedBox(width: 10),
            Text(name),
            const Spacer(),
            Text(Expense.formattedCost(amountCents)),
          ],
        ),
        subtitle: LinearProgressIndicator(value: goalCents == 0 ? 1 : amountCents / goalCents),
      ),
    );
  }
}
