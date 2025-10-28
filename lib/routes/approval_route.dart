import 'package:flutter/material.dart';

class ApprovalRoute extends StatelessWidget {
  const ApprovalRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Approval View',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}