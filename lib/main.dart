import 'package:flutter/material.dart';

import 'bucket.dart';
import 'buckets_page.dart';
import 'expenses_page.dart';
import 'home_page.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(SpendWise());
}

class SpendWise extends StatelessWidget {
  final buckets = [
    Bucket(bucketName: "House", iconData: Icons.house),
    Bucket(bucketName: "Wedding", iconData: Icons.favorite),
    Bucket(bucketName: "Vacation", iconData: Icons.flight_takeoff),
    Bucket(bucketName: "Car Savings/Repairs", iconData: Icons.car_repair),
    Bucket(bucketName: "Car Insurance", iconData: Icons.health_and_safety),
    Bucket(bucketName: "Car Taxes", iconData: Icons.gavel),
    Bucket(bucketName: "Invisalign", iconData: Icons.bluetooth_disabled),
    Bucket(bucketName: "Emergency Fund", iconData: Icons.emergency),
    Bucket(bucketName: "Retirement (Roth IRA)", iconData: Icons.elderly),
    Bucket(bucketName: "Charity", iconData: Icons.volunteer_activism),
  ];

  SpendWise({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'SpendWise',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: HomePage([ExpensesPage(possibleBuckets: buckets), BucketsPage(buckets: buckets)]),
    );
  }
}
