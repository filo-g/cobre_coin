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

  Future<void> _getUsers() async {
    final users = await SupabaseUtils.getUsers();
    setState(() {
      _users = users;
      _isLoading = false;
    });
  }

  void _sendTo(Map<String, dynamic> user) {
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
              title: Text('Enter a Number'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('How much do you want to send?'),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter a value',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final text = _amountController.text.trim();
                    final number = int.tryParse(text);
                    if (number != null) {
                      Navigator.pop(context, number);
                    } else {
                      // Show a small feedback if the input isn’t valid
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a valid number')),
                      );
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
            onTap: () => _sendTo(user),
          ),
        );
      },
    );
  }
}