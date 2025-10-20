import 'package:flutter/material.dart';

class FantasyRoute extends StatelessWidget {
  const FantasyRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Fantasy View',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}