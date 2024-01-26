import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:spend_wise/expense_details_page.dart';

import 'bucket.dart';
import 'expense.dart';

class ExpensesPage extends StatefulWidget {
  final List<Bucket> possibleBuckets;

  const ExpensesPage({super.key, required this.possibleBuckets});

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  late final List<Expense> _expenses = [
    Expense(
      bucket: widget.possibleBuckets[0],
      centsCost: 1234,
      created: DateTime.now(),
      forMonth: DateTime.now(),
      lastModified: DateTime.now(),
      name: "Payment",
      possibleBuckets: widget.possibleBuckets,
      setExpense: _replaceSelf,
    ),
    Expense(
      bucket: widget.possibleBuckets[1],
      centsCost: 1234,
      created: DateTime.now(),
      forMonth: DateTime.now(),
      lastModified: DateTime.now(),
      name: "Payment",
      possibleBuckets: widget.possibleBuckets,
      setExpense: _replaceSelf,
    )
  ];

  void _replaceSelf(oldExpense, newExpense) {
    setState(() {
      int index = _expenses.indexWhere((element) => element.sameAs(oldExpense));
      _expenses[index] = newExpense;
    });
  }

  void _addExpense(Expense expense) {
    setState(() {
      _expenses.add(expense);
    });
    Expense.dbExpensesCollection.add(expense);
  }

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
            for (var (i, expense) in _expenses.indexed)
              Dismissible(
                key: ValueKey(expense),
                background: Container(
                    color: Colors.red, child: const Icon(Icons.delete_forever)),
                onDismissed: (_) => setState(() {
                  _expenses.removeAt(i);
                }),
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
              builder: (s) => ExpenseDetailsPage(
                  possibleBuckets: widget.possibleBuckets,
                  setExpense: _replaceSelf),
            ),
          );
          _addExpense(newExpense);
        },
        tooltip: 'Add Expense',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
