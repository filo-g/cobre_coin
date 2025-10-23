import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/svg.dart';

import 'package:cobre_coin/utils/supabase_utils.dart';
import 'package:cobre_coin/utils/show_snack_bar.dart';

class WelcomeRoute extends StatefulWidget {
  const WelcomeRoute({super.key});

  @override
  State<WelcomeRoute> createState() => _WelcomeRouteState();
}

class _WelcomeRouteState extends State<WelcomeRoute> {

  int? _balance;
  String _formattedBalance = '0';
  var _loading = true;
  Future<void> _getBalance() async {
    setState(() {
      _loading = true;
    });
    try {
      final accounts = await SupabaseUtils.getUserAccounts();
      context.showSnackBar('$accounts', isError: false);
      if (accounts != null && accounts.isNotEmpty) {
        final balanceValue = accounts.first['balance'];

        if (balanceValue is num) {
          _balance = balanceValue.toInt();
        } else {
          _balance = 0;
        }
        _formattedBalance = NumberFormat('#,##0', 'es_ES').format(_balance);
      }
    } catch (error) {
      if (mounted) {
        context.showSnackBar('$error', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }
  
  @override
  void initState() {
    super.initState();
    _getBalance();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth * 0.8; // 80% of screen width
        final cardPadding = constraints.maxWidth < 400 ? 16.0 : 24.0;

        return Center(
          child: Container(
            padding: EdgeInsets.all(cardPadding),
            width: cardWidth,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceBright,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.7),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Balance',
                  style: TextStyle(
                    color: theme.colorScheme.secondary,
                    fontSize: constraints.maxWidth < 400 ? 14 : 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        _formattedBalance,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: constraints.maxWidth < 400 ? 24 : 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    SvgPicture.asset(
                      'assets/svg/cobre.svg',
                      height: constraints.maxWidth < 400 ? 24 : 28,
                      colorFilter: ColorFilter.mode(
                        theme.colorScheme.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}