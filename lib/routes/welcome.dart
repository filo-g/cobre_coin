import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/svg.dart';

class WelcomeRoute extends StatelessWidget {
  const WelcomeRoute({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final balance = 12345; // TODO: Change to get balance from supabase
    final formattedBalance = NumberFormat('#,##0', 'es_ES').format(balance);

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
                        formattedBalance,
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