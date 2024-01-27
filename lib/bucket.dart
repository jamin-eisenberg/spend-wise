import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'expense.dart';

class Bucket extends StatelessWidget {
  late final Icon icon;
  final String bucketName;
  final num amountCents;

  String id;

  static final CollectionReference<Bucket> dbCollection =
      FirebaseFirestore.instance
          .collection('users/${FirebaseAuth.instance.currentUser!.uid}/buckets')
          .withConverter(
              fromFirestore: (snapshot, _) =>
                  Bucket.fromJson(snapshot.data() ?? {}, snapshot.id),
              toFirestore: (b, _) => b.toJson());

  Bucket(
      {super.key,
      required this.bucketName,
      required this.amountCents,
      required IconData iconData,
      this.id = "not a valid bucket ID"}) {
    icon = Icon(iconData);
  }

  static Bucket fromJson(Map<String, dynamic> json, String id) {
    return Bucket(
      bucketName: json['bucketName'],
      iconData: IconData(json['iconCodePoint'] as int, fontFamily: "MaterialIcons"),
      amountCents: json['amountCents'],
      id: id,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bucketName': bucketName,
      'iconCodePoint': icon.icon!.codePoint,
      'amountCents': amountCents,
    };
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Bucket{icon: $icon, bucketName: $bucketName, amountCents: $amountCents}';
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListTile(
        title: Row(
          children: [
            icon,
            SizedBox.fromSize(size: const Size(10, 0)),
            Text(bucketName),
            const Spacer(),
            Text(Expense.formattedCost(amountCents)),
          ],
        ),
      ),
    );
  }
}
