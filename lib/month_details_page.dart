import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_wise/app_state.dart';
import 'package:spend_wise/expense.dart';
import 'package:spend_wise/month.dart';

import 'bucket.dart';

class MonthDetailsPage extends StatefulWidget {
  final Month? nextMonth;
  final Month month;
  final Future<String> Function(Month) updateDb;

  const MonthDetailsPage(
      {super.key,
      required this.month,
      required this.updateDb,
      required this.nextMonth});

  @override
  State<MonthDetailsPage> createState() => _MonthDetailsPageState();
}

class _MonthDetailsPageState extends State<MonthDetailsPage> {
  late final allAccountsTotalCents = TextEditingController(
      text: Expense.formattedCost(widget.month.allAccountsTotal ?? 0, false));
  late final estimatedMonthlyIncomeCents = TextEditingController(
      text: Expense.formattedCost(
          widget.month.estimatedMonthlyIncome ?? 0, false));
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
                final allAccountsTotal =
                    Expense.centsFromText(allAccountsTotalCents.text);
                final estimatedMonthlyIncome =
                    Expense.centsFromText(estimatedMonthlyIncomeCents.text);

                final month = Month(
                  month: widget.month.month,
                  allAccountsTotal: allAccountsTotal,
                  estimatedMonthlyIncome: estimatedMonthlyIncome,
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
                Row(children: [
                  const Text("Income this month: "),
                  const SizedBox(width: 10),
                  const Text("\$"),
                  Expanded(
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: TextInputType.number,
                      onTapOutside: (_) => estimatedMonthlyIncomeCents.text =
                          Expense.formattedCostString(
                              estimatedMonthlyIncomeCents.text, false),
                      controller: estimatedMonthlyIncomeCents,
                      validator: (amount) {
                        if (RegExp(r"-?[\d,]+(\.\d{2})?")
                                .firstMatch(estimatedMonthlyIncomeCents.text)?[0] ==
                            estimatedMonthlyIncomeCents.text) {
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
                            estimatedMonthlyIncome: widget.month.estimatedMonthlyIncome,
                            bucketTransferDate: DateTime.now(),
                          ));

                          setState(() {
                            buttonPressed = true;
                          });
                        },
                        child: const Text(
                            "Transfer monthly amounts into each bucket"),
                      ),
                    )
                  : Text(widget.month.bucketTransferDate == null
                      ? "Bucket amount transfer completed"
                      : "Bucket amount transfer completed on ${widget.month.bucketTransferDate!.toString()}"),
            ),
            const SizedBox(height: 30),
            Text("${Month.format(widget.month.month)} expenses total: ${Expense.formattedCost(widget.month.expenses.map((e) => e.centsCost).sum)}"),
            if (widget.nextMonth != null)
              Text(
                  "${Month.format(widget.nextMonth!.month)} account total: ${Expense.formattedCost(widget.nextMonth?.allAccountsTotal ?? 0)}"),
            const SizedBox(height: 15),
            if (widget.nextMonth != null &&
                widget.month.allAccountsTotal != null &&
                widget.nextMonth!.allAccountsTotal != null)
              Text(
                  "This month's 'real spending': ${Expense.formattedCost((widget.month.estimatedMonthlyIncome ?? 0) - widget.month.expenses.map((e) => e.centsCost).sum + widget.month.allAccountsTotal! - widget.nextMonth!.allAccountsTotal!)}"),
          ],
          // real spending = estimated monthly income - total of input expenses + this month's account total - next month's account total
          // amount not in any bucket = this month's account total - bucket total snapshot; not this
          // amount not in any bucket (not for a particular month) = the most recent month's total - total buckets
        ),
      ),
    );
  }
}
