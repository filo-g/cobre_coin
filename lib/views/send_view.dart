import 'package:cobre_coin/utils/show_snack_bar.dart';
import 'package:cobre_coin/utils/transactions.dart';
import 'package:flutter/material.dart';
import 'package:cobre_coin/utils/supabase_utils.dart';

class SendView extends StatefulWidget {
  const SendView({super.key});

  @override
  State<SendView> createState() => _SendViewState();
}

class _SendViewState extends State<SendView> {
  bool _isLoading = true;
  late final List<Map<String, dynamic>>? _users;
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  Future<void> _getUsers() async {
    final users = await SupabaseUtils.getUsers();
    setState(() {
      _users = users;
      _isLoading = false;
    });
  }

  void _sendToDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (
            BuildContext context,
            void Function(void Function()) setStateDialog
          ) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text('Sending to ${user['display_name']}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      label: Text('Transaction description'),
                      border: OutlineInputBorder(),
                      hintText: 'The motive of this transaction',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      label: Text('How much do you want to send?'),
                      border: OutlineInputBorder(),
                      hintText: 'Amount of Cobre to send',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _descriptionController.clear();
                    _amountController.clear();
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final amountString = _amountController.text.trim();
                    final amountInt = int.tryParse(amountString);
                    final descriptionString = _descriptionController.text.trim();

                    if (amountInt != null && amountInt > 0) {
                      final res = await Transactions.sendTo(
                        user['id'],
                        amountInt,
                        descriptionString
                      );

                      if (res != null && res['status'] == 'success') {
                        print(res);
                        context.showSnackBar('Cobre sent successfully!');
                        _descriptionController.clear();
                        _amountController.clear();
                        Navigator.pop(context);
                      }
                    } else {
                      // Show a small feedback if the input isn’t valid
                      context.showSnackBar('Please enter a valid amount');
                    }
                  },
                  child: const Text('Confirm'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _getUsers();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator()
      );
    }

    if (_users == null || _users.isEmpty) {
      return Center(
        child: Text('No users found.')
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            title: Text(
              '${user['display_name'] ?? 'no one'}'
            ),
            subtitle: Text(
              '@${user['username'] ?? 'e404'}'
            ),
            onTap: () => _sendToDialog(user),
          ),
        );
      },
    );
  }
}