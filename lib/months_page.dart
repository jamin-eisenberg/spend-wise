import 'package:flutter/material.dart';
import 'package:spend_wise/expense.dart';

import 'month.dart';

class MonthsPage extends StatelessWidget {
  final List<Expense> expenses;
  final Map<DateTime, num> monthAmounts;

  const MonthsPage(
      {super.key, required this.expenses, required this.monthAmounts});

  List<DateTime> getMonthsBetween(DateTime start, DateTime end) {
    var curr = start;
    List<DateTime> dates = [];
    while (curr.isBefore(end)) {
      dates.add(curr);
      curr = DateTime(curr.year, curr.month + 1);
    }
    dates.add(curr);
    return dates;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Months"),
      ),
      body: Center(
        child: Column(
          children: [
            for (var date
                in getMonthsBetween(DateTime.utc(2024), DateTime.now()))
              Month(
                month: date,
                expenses: expenses.where((e) => e.forMonth == date).toList(),
                allAccountsTotal: monthAmounts[date],
              )
          ],
        ),
      ),
    );
  }
}
