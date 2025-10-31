import 'package:cobre_coin/utils/supabase_utils.dart';
import 'package:flutter/material.dart';

class UsersView extends StatefulWidget {
  const UsersView({super.key});

  @override
  State<UsersView> createState() => UsersViewState();
}

class UsersViewState extends State<UsersView> {
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
    bool approved = user['approved'] ?? false;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (
            BuildContext context,
            void Function(void Function()) setStateDialog
          ) {
            return AlertDialog(
              title: Text(user['full_name'] ?? 'No name'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Alias: ${user['display_name'] ?? 'N/A'}'),
                  const SizedBox(height: 8),
                  Text('Username: @${user['username'] ?? 'N/A'}'),
                  const SizedBox(height: 8),
                  Text('ID: ${user['id']}'),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Approved:'),
                      Switch(
                        value: approved,
                        onChanged: (value) async {
                          setStateDialog(() {
                            approved = value;
                          });
                          if (mounted) {
                            setState(() {
                              // Also update the local value
                              user['approved'] = value;
                            });
                          }
                          await SupabaseUtils.updateUser(
                            user['id'],
                            {'approved': value}
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
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
              '${user['full_name'] ?? 'Unknown user'} '
              '(${user['display_name'] ?? 'no one'})'
            ),
            subtitle: Text(
              '@${user['username'] ?? 'e404'}'
            ),
            trailing: user['approved'] ?
              Icon(Icons.verified, color: Colors.greenAccent,) :
              Icon(Icons.new_releases, color: Colors.redAccent),
            onTap: () => _showUserInfo(user),
          ),
        );
      },
    );
  }
}