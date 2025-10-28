import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseUtils {
  static final supabase = Supabase.instance.client;
  
  /// Returns supabase instance.
  static SupabaseClient getInstance() {
    return supabase;
  }

  /// Returns current user session.
  /// 
  /// Returns NULL if there is no session.
  static Session? getCurrentSession() {
    return supabase.auth.currentSession;
  }

  /// Get the currently authenticated user's ID
  /// 
  /// Returns NULL if user is not logged in.
  static String? getUserId() {
    return supabase.auth.currentSession?.user.id;
  }

  /// Fetch a user data from the 'users' table
  /// 
  /// Returns a Map&lt;String, dynamic&gt; with the user data, NULL if failed.
  static Future<Map<String, dynamic>?> getUserData() async {
    final userId = getUserId();
    if (userId == null) {
      // User is not logged in.
      return null;
    }

    final data = await supabase
        .from('users')
        .select()
        .eq('id', userId)
        .single();

    return data;
  }

  /// Check if current user has been approved by an admin.
  static Future<bool> getUserApproval() async {
    final data = await getUserData();
    return data?['approved'] == true;
  }

  /// Fetch the user balance from the 'accounts' table.
  /// 
  /// Returns List&lt;Map&lt;String, dynamic&gt;&gt; with all the accounts
  /// found. (should be just one but whatever, admin user has multiple so)
  static Future<List<Map<String, dynamic>>?> getUserAccounts() async {
    final userId = getUserId();
    if (userId == null) {
      // User is not logged in.
      return null;
    }

    final accounts = await supabase
      .from('accounts')
      .select('id, balance, name, is_primary')
      .eq('user_id', userId)
      .order('is_primary', ascending: false);

    return accounts;
  }
}