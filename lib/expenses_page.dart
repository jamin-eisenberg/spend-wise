import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:spend_wise/expense_details_page.dart';

import 'bucket.dart';
import 'expense.dart';

class ExpensesPage extends StatelessWidget {
  final List<Bucket> buckets;
  final List<Expense> expenses;

  const ExpensesPage(
      {super.key, required this.buckets, required this.expenses});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Expenses"),
        actions: [
          IconButton(
              onPressed: () async => await FirebaseAuth.instance.signOut(),
              icon: const Icon(Icons.logout))
        ],
      ),
      body: Center(
        child: ListView(
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
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (s) =>
                  const ExpenseDetailsPage(updateDb: Expense.insert),
            ),
          );
        },
        tooltip: 'Add Expense',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
