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

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  bool _loggedIn = false;
  StreamSubscription<QuerySnapshot>? _expensesSubscription;
  List<Expense> _expenses = [];
  StreamSubscription<QuerySnapshot>? _bucketsSubscription;
  List<Bucket> _buckets = [];

  bool get loggedIn => _loggedIn;
  List<Expense> get expenses => _expenses;
  List<Bucket> get buckets => _buckets;

  Future<void> init() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    FirebaseUIAuth.configureProviders([
      EmailAuthProvider(),
    ]);

    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loggedIn = true;
        _expensesSubscription = Expense.dbCollection.snapshots().listen((event) {
          _expenses = event.docs.map((e) => e.data()).toList();
          log("EXPENSES: $_expenses");
          notifyListeners();
        });
        _bucketsSubscription = Bucket.dbCollection.snapshots().listen((event) {
          _buckets = event.docs.map((b) => b.data()).toList();
          log("BUCKETS: $_buckets");
          notifyListeners();
        });
      } else {
        _loggedIn = false;
        _expenses = [];
        _expensesSubscription?.cancel();
        _buckets = [];
        _bucketsSubscription?.cancel();
      }
      notifyListeners();
    });
  }
}
