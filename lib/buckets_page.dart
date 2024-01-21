import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'bucket.dart';

class BucketsPage extends StatefulWidget {
  final List<Bucket> buckets;

  const BucketsPage({super.key, required this.buckets});

  @override
  State<BucketsPage> createState() => _BucketsPageState();
}

class _BucketsPageState extends State<BucketsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Buckets"),
      ),
      body: Center(
        child: Column(
          children: widget.buckets,
        ),
      ),
    );
  }
}
