import 'package:flutter/material.dart';

class StatsRoute extends StatelessWidget {
  const StatsRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Stats View',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}