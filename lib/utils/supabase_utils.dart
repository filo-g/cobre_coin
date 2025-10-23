import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseUtils {
  static final supabase = Supabase.instance.client;
  
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
}