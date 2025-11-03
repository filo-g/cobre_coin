import 'package:cobre_coin/utils/supabase_utils.dart';

class Transactions {  // TODO: I don't like the class name, i want to find another
  static final supabase = SupabaseUtils.getInstance();

  /// Core function for getting accounts from the 'accounts' table, expects a
  /// valid [userId].
  static Future<List<Map<String, dynamic>>?> _getAccountsForUser(String userId) async {
    try {
      final accounts = await supabase
        .from('accounts')
        .select('id, balance, name, is_primary')
        .eq('user_id', userId)
        .order('is_primary', ascending: false);

      return accounts;
    } catch (e) {
      print('Error finding user accounts: $e');
      return null;
    }
  }
  /// Fetch the logged-in user balance from the 'accounts' table.
  /// 
  /// Returns List&lt;Map&lt;String, dynamic&gt;&gt; with all the accounts
  /// found. (should be just one but whatever, admin user has multiple so)
  static Future<List<Map<String, dynamic>>?> getOwnAccounts() async {
    final userId = SupabaseUtils.getUserId();
    if (userId == null) {
      // User is not logged in.
      return null;
    }
    return await _getAccountsForUser(userId);
  }
  /// Fetch the [pUserId] balance from the 'accounts' table.
  /// 
  /// Returns List&lt;Map&lt;String, dynamic&gt;&gt; with all the accounts
  /// found. (same as getOwnAccounts, should be just one)
  static Future<List<Map<String, dynamic>>?> getUserAccounts(String pUserId) async {
    final userId = pUserId;
    return await _getAccountsForUser(userId);
  }

  static Future<Map<String, dynamic>?> getOwnMainAccount() async {
    final accounts = await getOwnAccounts();
    if (accounts == null || accounts.isEmpty) return null; // should never happen
    return accounts.first;
  }

  static Future<Map<String, dynamic>?> getUserMainAccount(String pUserId) async {
    final accounts = await getUserAccounts(pUserId);
    if (accounts == null || accounts.isEmpty) return null; // should never happen
    return accounts.first;
  }

  /// Update the fields of given user.
  /// 
  /// Returns a &lt;PostgrestResponse&gt; or null if something foes wrong.
  static Future<Map<String, dynamic>?> sendTo(String userId, int amount, [String? description]) async {
    late dynamic res;
    final fromAccount = await getOwnMainAccount();
    final toAccount = await getUserMainAccount(userId);

    if (fromAccount == null || toAccount == null) {
      // Either user does not have main account (should never happen)
      return null;
    }

    // Trigger 'make_transaction'. Send to [userId]'s main account [amount] cobre.
    try {
      res = await supabase.rpc(
        'make_transaction',
        params: {
          'p_from_account': fromAccount['id'],
          'p_to_account': toAccount['id'],
          'p_amount': amount,
          'p_description': description ?? 'Cobre Transaction',
        },
      );

      return res;
    } catch (e) {
      print('Error on transaction: $e');
    }
  }
}