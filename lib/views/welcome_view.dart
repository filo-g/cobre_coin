import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/svg.dart';

import 'package:cobre_coin/utils/supabase_utils.dart';
import 'package:cobre_coin/utils/show_snack_bar.dart';

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {

  final NumberFormat _formatter = NumberFormat('#,##0', 'es_ES');
  List? _accounts = [];
  var _loading = true;
  Future<void> _getAccounts() async {
    setState(() {
      _loading = true;
    });
    try {
      _accounts = await SupabaseUtils.getUserAccounts();
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
    _getAccounts();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth * 0.8;
        final cardPadding = constraints.maxWidth < 400 ? 16.0 : 24.0;

        return Center(
          child: SizedBox(
            width: cardWidth,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _accounts?.length,
              itemBuilder: (context, index) {
                final account = _accounts![index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: cardWidth,
                  padding: EdgeInsets.all(cardPadding),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceBright,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Balance${account['name'] != null ? ' - ${account['name']}' : ''}',
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
                              _formatter.format(account['balance']),
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontSize: constraints.maxWidth < 400 ? 32 : 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          SvgPicture.asset(
                            'assets/svg/cobrecoin.svg',
                            height: constraints.maxWidth < 400 ? 36 : 48,
                            colorFilter: ColorFilter.mode(
                              theme.colorScheme.primary,
                              BlendMode.srcIn,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}