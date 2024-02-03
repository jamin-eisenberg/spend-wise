import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_wise/app_state.dart';
import 'package:spend_wise/expense.dart';
import 'package:spend_wise/month.dart';

import 'bucket.dart';

class MonthDetailsPage extends StatefulWidget {
  final Month month;
  final Future<String> Function(Month) updateDb;

  const MonthDetailsPage(
      {super.key, required this.month, required this.updateDb});

  @override
  State<MonthDetailsPage> createState() => _MonthDetailsPageState();
}

class _MonthDetailsPageState extends State<MonthDetailsPage> {
  late final allAccountsTotalCents = TextEditingController(
      text: Expense.formattedCost(widget.month.allAccountsTotal ?? 0, false));
  final _formKey = GlobalKey<FormState>();
  bool buttonPressed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Month.format(widget.month.month)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                final hasCents = allAccountsTotalCents.text.contains(".");
                final rawAllAccountsTotal = int.parse(
                    allAccountsTotalCents.text.replaceAll(RegExp(r"[,.]"), ""));
                final allAccountsTotal =
                    hasCents ? rawAllAccountsTotal : rawAllAccountsTotal * 100;

                final month = Month(
                  month: widget.month.month,
                  allAccountsTotal: allAccountsTotal,
                  expenses: widget.month.expenses,
                  bucketTransferDate: widget.month.bucketTransferDate,
                );

                widget.updateDb(month);

                Navigator.pop(
                  context,
                );
              }
            },
            icon: const Icon(Icons.save),
          )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                Row(children: [
                  const Text("Total in all accounts: "),
                  const SizedBox(width: 10),
                  const Text("\$"),
                  Expanded(
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: TextInputType.number,
                      onTapOutside: (_) => allAccountsTotalCents.text =
                          Expense.formattedCostString(
                              allAccountsTotalCents.text, false),
                      controller: allAccountsTotalCents,
                      validator: (amount) {
                        if (RegExp(r"-?[\d,]+(\.\d{2})?")
                                .firstMatch(allAccountsTotalCents.text)?[0] ==
                            allAccountsTotalCents.text) {
                          return null;
                        } else {
                          return "Incorrect format for currency. Example: 1,234.56";
                        }
                      },
                    ),
                  ),
                ]),
              ]),
            ),
            const SizedBox(height: 20),
            Center(
                child: widget.month.bucketTransferDate == null && !buttonPressed
                    ? Consumer<ApplicationState>(
                        builder: (_, appState, __) => ElevatedButton(
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .runTransaction((transaction) async {
                                List<Bucket> newBuckets = await Future.wait(
                                    appState.buckets.map((bucket) async {
                                  final bucketDoc = await transaction
                                      .get(Bucket.dbCollection.doc(bucket.id));
                                  final bucketData = bucketDoc.data()!;

                                  return Bucket(
                                    name: bucketData.name,
                                    amountCents: bucketData.amountCents +
                                        bucketData.perMonthAmountCents,
                                    iconData: bucketData.icon.icon!,
                                    perMonthAmountCents:
                                        bucketData.perMonthAmountCents,
                                    id: bucketData.id,
                                  );
                                }));

                                for (final bucket in newBuckets) {
                                  transaction.update(
                                      Bucket.dbCollection.doc(bucket.id),
                                      bucket.toJson());
                                }

                                print(
                                    "JAMIN: ${newBuckets.map((b) => b.toJson())}");
                              });

                              await Month.update(Month(
                                month: widget.month.month,
                                expenses: [],
                                allAccountsTotal: widget.month.allAccountsTotal,
                                bucketTransferDate: DateTime.now(),
                              ));

                              setState(() {
                                buttonPressed = true;
                              });
                            },
                            child: const Text(
                                "Transfer monthly amounts into each bucket")),
                      )
                    : Text(widget.month.bucketTransferDate == null
                        ? "Bucket amount transfer completed"
                        : "Bucket amount transfer completed on ${widget.month.bucketTransferDate!.toString()}")),
          ],
        ),
      ),
    );
  }
}
