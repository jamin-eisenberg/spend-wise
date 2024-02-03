import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_wise/app_state.dart';
import 'package:spend_wise/expense.dart';

import 'bucket.dart';

class BucketDetailsPage extends StatefulWidget {
  final Bucket bucket;
  final Future<String> Function(Bucket) updateDb;

  const BucketDetailsPage(
      {super.key, required this.bucket, required this.updateDb});

  @override
  State<BucketDetailsPage> createState() => _BucketDetailsPageState();
}

class _BucketDetailsPageState extends State<BucketDetailsPage> {
  late final perMonthAmountCents = TextEditingController(
      text: Expense.formattedCost(widget.bucket.perMonthAmountCents, false));
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bucket.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                final perMonthAmount = Expense.centsFromText(perMonthAmountCents.text);

                final bucket = Bucket(
                    name: widget.bucket.name,
                    amountCents: widget.bucket.amountCents,
                    iconData: widget.bucket.icon.icon!,
                    id: widget.bucket.id,
                    perMonthAmountCents: perMonthAmount);

                widget.updateDb(bucket).then((value) => bucket.id = value);

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
                  const Text("Amount per month: "),
                  const SizedBox(width: 10),
                  const Text("\$"),
                  Expanded(
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: TextInputType.number,
                      onTapOutside: (_) => perMonthAmountCents.text =
                          Expense.formattedCostString(
                              perMonthAmountCents.text, false),
                      controller: perMonthAmountCents,
                      validator: (amount) {
                        if (RegExp(r"-?[\d,]+(\.\d{2})?")
                                .firstMatch(perMonthAmountCents.text)?[0] ==
                            perMonthAmountCents.text) {
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
            const Text("History:"),
            const SizedBox(height: 20),
            Expanded(
              child: Consumer<ApplicationState>(
                builder: (_, appState, __) => ListView(
                  children: appState.expenses
                      .where((e) => e.bucketId == widget.bucket.id)
                      .map((e) => e.toReadOnly())
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
