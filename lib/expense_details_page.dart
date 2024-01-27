import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_wise/app_state.dart';
import 'package:spend_wise/expense.dart';

import 'month.dart';

class ExpenseDetailsPage extends StatefulWidget {
  final Expense? expense;
  final Future<String> Function(Expense expense) updateDb;

  const ExpenseDetailsPage({super.key, this.expense, required this.updateDb});

  @override
  State<ExpenseDetailsPage> createState() => _ExpenseDetailsPageState();
}

class _ExpenseDetailsPageState extends State<ExpenseDetailsPage> {
  late final name = TextEditingController(text: widget.expense?.name ?? "");
  late final centsCost = TextEditingController(
      text: widget.expense == null
          ? ""
          : Expense.formattedCost(widget.expense!.centsCost, false));
  late DateTime forMonth = widget.expense?.forMonth ??
      DateTime(DateTime.now().year, DateTime.now().month);
  late String? selectedBucketId =
      widget.expense?.bucketId;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expense?.name ?? "New Expense"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                final costHasCents = centsCost.text.contains(".");
                final rawCost =
                    int.parse(centsCost.text.replaceAll(RegExp(r"[,.]"), ""));
                final cost = costHasCents ? rawCost : rawCost * 100;

                final expense = Expense(
                  name: name.text,
                  centsCost: cost,
                  bucketId: selectedBucketId!,
                  forMonth: forMonth,
                  created: DateTime.now(),
                  lastModified: DateTime.now(),
                );

                widget.updateDb(expense).then((value) => expense.id = value);

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
        child: Form(
          key: _formKey,
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            Row(children: [
              const Text("Name: "),
              SizedBox.fromSize(size: const Size(10, 0)),
              Expanded(
                child: TextFormField(
                  controller: name,
                ),
              ),
            ]),
            Row(children: [
              const Text("Amount: "),
              SizedBox.fromSize(size: const Size(10, 0)),
              const Text("\$"),
              Expanded(
                child: TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  keyboardType: TextInputType.number,
                  onTapOutside: (_) => centsCost.text =
                      Expense.formattedCostString(centsCost.text, false),
                  controller: centsCost,
                  validator: (amount) {
                    if (RegExp(r"-?[\d,]+(\.\d{2})?")
                            .firstMatch(centsCost.text)?[0] ==
                        centsCost.text) {
                      return null;
                    } else {
                      return "Incorrect format for currency. Example: 1,234.56";
                    }
                  },
                ),
              ),
            ]),
            Row(children: [
              const Text("Bucket: "),
              SizedBox.fromSize(size: const Size(10, 0)),
              Expanded(
                child: Consumer<ApplicationState>(
                    builder: (_, appState, __) => DropdownButtonFormField(
                        value: appState.buckets.where((element) => selectedBucketId == element.id).firstOrNull,
                        items: appState.buckets
                            .map((b) => DropdownMenuItem(
                                value: b, child: Text(b.bucketName)))
                            .toList(),
                        validator: (bucket) {
                          if (bucket == null) {
                            return "Bucket must not be empty.";
                          } else {
                            return null;
                          }
                        },
                        onChanged: (bucket) => setState(() {
                              selectedBucketId = bucket?.id ?? selectedBucketId;
                            }))),
              )
            ]),
            Row(children: [
              const Text("For month: "),
              SizedBox.fromSize(size: const Size(10, 0)),
              MaterialButton(
                onPressed: () {
                  showDatePicker(
                          context: context,
                          firstDate: DateTime.now()
                              .subtract(const Duration(days: 365)),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                          currentDate: forMonth,
                          selectableDayPredicate: (day) => day.day == 1,
                          errorInvalidText:
                              "Out of range (should be a first of the month).")
                      .then((value) =>
                          setState(() => forMonth = value ?? forMonth));
                },
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month),
                    SizedBox.fromSize(size: const Size(10, 0)),
                    Text(Month.format(forMonth)),
                  ],
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }
}
