import 'package:flutter/material.dart';

import 'expense.dart';

class Bucket extends StatelessWidget {
  late final Icon icon;
  final String bucketName;
  late final num amountCents;

  Bucket(
      {super.key, required this.bucketName, num? amountCents, required IconData iconData}) {
    this.amountCents = amountCents ?? 0;
    icon = Icon(iconData);
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
            Text("\$${Expense.formattedCost(amountCents)}"),
          ],
        ),
      ),
    );
  }
}