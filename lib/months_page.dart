import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:spend_wise/expense.dart';
import 'package:http/http.dart' as http;

import 'bucket.dart';
import 'month.dart';

class MonthsPage extends StatelessWidget {
  final List<Expense> expenses;
  final List<Month> months;
  final List<Bucket> buckets;

  const MonthsPage(
      {super.key,
      required this.expenses,
      required this.months,
      required this.buckets});

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

  List<(T, T?)> twoSlidingWindow<T>(List<T> ls) {
    List<(T, T?)> res = [];
    for (final (i, x) in ls.sublist(1).indexed) {
      res.add((ls[i], x));
    }
    res.add((ls.last, null));
    return res;
  }

  Future<void> exportToSpreadsheet() {
    return http.post(
      Uri.parse('https://script.google.com/macros/s/AKfycbzCBlozl_Z3JLj5b-lDyL8FgexlPG51zDnBc2YB4wj6-tyc4pilcDmCBuFsIVZfDazRJA/exec'),
      body: jsonEncode({
        'buckets': buckets.map((bucket) => {
          'name': bucket.name,
          'months': months.map((month) => {
            'month': Month.format(month.month),
            'spent': expenses.where((e) => e.bucketId == bucket.id && e.forMonth == month.month).map((e) => e.centsCost).sum,
            'amountCents': month.bucketAmounts?[bucket.id]?.$1 ?? 0,
            'perMonthAmountCents': month.bucketAmounts?[bucket.id]?.$2 ?? 0,
          }).toList()
        }).toList(),
      }),
      headers: {
        "Content-Type": "application/json"
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    matchingFromDb(date) => months.where((m) => m.month == date).firstOrNull;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Months"),
        actions: [
          IconButton(onPressed: () async => await exportToSpreadsheet(), icon: const Icon(Icons.file_upload))
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
              color: Colors.grey[350],
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Center(
                  child: Text(
                      "Total untracked in buckets: ${Expense.formattedCost((months.where((m) => m.allAccountsTotal != null).lastOrNull?.allAccountsTotal ?? 0) - buckets.map((b) => b.amountCents).sum)}"),
                ),
              )),
          Flexible(
            child: Center(
              child: ListView(
                children: [
                  for (var (date, nextDate) in twoSlidingWindow(
                      getMonthsBetween(DateTime(2024), DateTime.now())))
                    Month(
                      month: date,
                      expenses:
                          expenses.where((e) => e.forMonth == date).toList(),
                      allAccountsTotal: matchingFromDb(date)?.allAccountsTotal,
                      estimatedMonthlyIncome:
                          matchingFromDb(date)?.estimatedMonthlyIncome,
                      bucketTransferDate:
                          matchingFromDb(date)?.bucketTransferDate,
                      bucketAmounts: matchingFromDb(date)?.bucketAmounts,
                      nextMonth: nextDate == null
                          ? null
                          : Month(
                              month: nextDate,
                              expenses: expenses
                                  .where((e) => e.forMonth == nextDate)
                                  .toList(),
                              allAccountsTotal:
                                  matchingFromDb(nextDate)?.allAccountsTotal,
                              estimatedMonthlyIncome: matchingFromDb(nextDate)
                                  ?.estimatedMonthlyIncome,
                              bucketTransferDate:
                                  matchingFromDb(nextDate)?.bucketTransferDate,
                              bucketAmounts: matchingFromDb(nextDate)?.bucketAmounts,
                            ),
                    )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
