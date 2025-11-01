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

  Future<void> _getUsers() async {
    final users = await SupabaseUtils.getUsers();
    setState(() {
      _users = users;
      _isLoading = false;
    });
  }

  void _showUserInfo(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (
            BuildContext context,
            void Function(void Function()) setStateDialog
          ) {
            return AlertDialog();
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
              '${user['display_name'] ?? 'no one'})'
            ),
            subtitle: Text(
              '@${user['username'] ?? 'e404'}'
            ),
          ),
        );
      },
    );
  }
}