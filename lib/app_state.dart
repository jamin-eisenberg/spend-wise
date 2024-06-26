import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:spend_wise/expense.dart';

import 'bucket.dart';
import 'firebase_options.dart';
import 'month.dart';

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  bool _loggedIn = false;
  StreamSubscription<QuerySnapshot>? _expensesSubscription;
  List<Expense> _expenses = [];
  StreamSubscription<QuerySnapshot>? _bucketsSubscription;
  List<Bucket> _buckets = [];
  StreamSubscription<QuerySnapshot>? _monthAmountsSubscription;
  List<Month> _months = [];

  bool get loggedIn => _loggedIn;

  List<Expense> get expenses => _expenses;

  List<Bucket> get buckets => _buckets;

  List<Month> get months => _months;

  Future<void> init() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    FirebaseUIAuth.configureProviders([
      EmailAuthProvider(),
    ]);

    // final buckets = [
    //   Bucket(goalCents: 0, perMonthAmountCents: 0, name: "House", iconData: Icons.house, amountCents: 0),
    //   Bucket(goalCents: 0, perMonthAmountCents: 0, name: "Wedding", iconData: Icons.favorite, amountCents: 0),
    //   Bucket(goalCents: 0, perMonthAmountCents: 0, name: "Vacation", iconData: Icons.flight_takeoff, amountCents: 0),
    //   Bucket(goalCents: 0, perMonthAmountCents: 0, name: "Car Savings/Repairs", iconData: Icons.car_repair, amountCents: 0),
    //   Bucket(goalCents: 0, perMonthAmountCents: 0, name: "Car Insurance", iconData: Icons.health_and_safety, amountCents: 0),
    //   Bucket(goalCents: 0, perMonthAmountCents: 0, name: "Car Taxes", iconData: Icons.gavel, amountCents: 0),
    //   Bucket(goalCents: 0, perMonthAmountCents: 0, name: "Invisalign", iconData: Icons.bluetooth_disabled, amountCents: 0),
    //   Bucket(goalCents: 0, perMonthAmountCents: 0, name: "Emergency Fund", iconData: Icons.emergency, amountCents: 0),
    //   Bucket(goalCents: 0, perMonthAmountCents: 0, name: "Retirement (Roth IRA)", iconData: Icons.elderly, amountCents: 0),
    //   Bucket(goalCents: 0, perMonthAmountCents: 0, name: "Charity", iconData: Icons.volunteer_activism, amountCents: 0),
    // ];
    //
    // for (final bucket in buckets) {
    //   Bucket.dbCollection.add(bucket);
    // }


    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loggedIn = true;
        _expensesSubscription = Expense.dbCollection
            .orderBy('created', descending: true)
            .snapshots()
            .listen((event) {
          _expenses = event.docs.map((e) => e.data()).toList();
          log("EXPENSES: $_expenses");
          notifyListeners();
        });
        _bucketsSubscription =
            Bucket.dbCollection.orderBy('name').snapshots().listen((event) {
          _buckets = event.docs.map((b) => b.data()).toList();
          log("BUCKETS: $_buckets");
          notifyListeners();
        });
        _monthAmountsSubscription =
            Month.dbCollection.snapshots().listen((event) {
          _months = event.docs.map((m) => m.data()).toList();
          log("MONTH AMOUNTS: $_months");
          notifyListeners();
        });
      } else {
        _loggedIn = false;
        _expenses = [];
        _expensesSubscription?.cancel();
        _buckets = [];
        _bucketsSubscription?.cancel();
        _months = [];
        _monthAmountsSubscription?.cancel();
      }
      notifyListeners();
    });
  }
}
