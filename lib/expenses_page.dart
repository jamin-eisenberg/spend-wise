import 'package:flutter/material.dart';
import 'package:spend_wise/expense_details_page.dart';

import 'bucket.dart';
import 'expense.dart';

class ExpensesPage extends StatelessWidget {
  final List<Bucket> buckets;
  final List<Expense> expenses;

  const ExpensesPage({super.key, required this.buckets, required this.expenses});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Expenses"),
      ),
      body: Center(
        child: Column(
          children: [
            for (var expense in expenses)
              Dismissible(
                key: ValueKey(expense),
                background: Container(
                    color: Colors.red, child: const Icon(Icons.delete_forever)),
                onDismissed: (_) => expense.remove(),
                child: expense,
              )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newExpense = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (s) => const ExpenseDetailsPage(updateDb: Expense.insert),
            ),
          );
        },
        tooltip: 'Add Expense',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

// class _ExpensesPageState extends State<ExpensesPage> {
//   late final List<Expense> _expenses = [
//     Expense(
//       bucket: widget.buckets[0],
//       centsCost: 1234,
//       created: DateTime.now(),
//       forMonth: DateTime.now(),
//       lastModified: DateTime.now(),
//       name: "Payment",
//       possibleBuckets: widget.buckets,
//       setExpense: _replaceSelf,
//     ),
//     Expense(
//       bucket: widget.buckets[1],
//       centsCost: 1234,
//       created: DateTime.now(),
//       forMonth: DateTime.now(),
//       lastModified: DateTime.now(),
//       name: "Payment",
//       possibleBuckets: widget.buckets,
//       setExpense: _replaceSelf,
//     )
//   ];
//
//   void _replaceSelf(oldExpense, newExpense) {
//     setState(() {
//       int index = _expenses.indexWhere((element) => element.sameAs(oldExpense));
//       _expenses[index] = newExpense;
//     });
//   }
//
//   void _addExpense(Expense expense) {
//     setState(() {
//       _expenses.add(expense);
//     });
//     Expense.dbCollection.add(expense);
//   }
//
//
// }
