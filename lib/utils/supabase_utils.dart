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

  /// Get the current user's role.
  static Future<String> getUserRole() async {
    final data = await getUserData();
    return data?['role'];
  }

  /// Check if current user has been approved by an admin.
  static Future<bool> getUserApproval() async {
    final data = await getUserData();
    return data?['approved'] == true;
  }

  /// More global getter for non-specific user fields.
  static Future<String> getUserField(String field) async {
    final data = await getUserData();
    return data?[field];
  }

  /// Get all users (except admins and self).
  /// 
  /// Returns List&lt;Map&lt;String, dynamic&gt;&gt;
  static Future<List<Map<String, dynamic>>?> getUsers() async {
    final userId = getUserId();
    if (userId == null) {
      // User is not logged in.
      return null;
    }

    final data = await supabase
      .from('users')
      .select()
      .neq('id', userId)
      .neq('role', 'admin');
    
    return data;
  }

  /// Update the fields of current user.
  /// 
  /// Returns a &lt;PostgrestResponse&gt; or null if something foes wrong.
  static Future<dynamic> updateSelf(Map<String, dynamic> updates) async {
    final userId = getUserId();
    late dynamic res;

    if (userId == null) {
      // User is not logged in.
      return null;
    }
    
    final updatedFields = {
      ...updates,
      'updated_at': DateTime.now().toIso8601String(),
    };

    try {
      res = await supabase
        .from('users')
        .update(updatedFields)
        .eq('id', userId);

      return res;

    } catch (e) {
      print('Error updating user: $e');
    }
  }

  /// Update the fields of given user.
  /// 
  /// Returns a &lt;PostgrestResponse&gt; or null if something foes wrong.
  static Future<dynamic> updateUser(String userId, Map<String, dynamic> updates) async {
    late dynamic res;
    
    final updatedFields = {
      ...updates,
      'updated_at': DateTime.now().toIso8601String(),
    };

    try {
      res = await supabase
        .from('users')
        .update(updatedFields)
        .eq('id', userId);

      return res;

    } catch (e) {
      print('Error updating user: $e');
    }
  }
}