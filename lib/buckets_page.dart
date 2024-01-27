import 'package:flutter/material.dart';

import 'bucket.dart';

class BucketsPage extends StatelessWidget {
  final List<Bucket> buckets;

  const BucketsPage({super.key, required this.buckets});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Buckets"),
      ),
      body: Center(
        child: ListView(
          children: buckets,
        ),
      ),
    );
  }
}
