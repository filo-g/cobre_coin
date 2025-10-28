import 'package:flutter/material.dart';

class FantasyView extends StatelessWidget {
  const FantasyView({super.key});

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