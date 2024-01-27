import 'package:flutter/material.dart';
import 'package:spend_wise/expense.dart';

class MonthsPage extends StatelessWidget {
  final List<Expense> expenses;

  const MonthsPage({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Months"),
      ),
      body: Center(
        child: Column(
          children: expenses,
        ),
      ),
    );
  }
}
