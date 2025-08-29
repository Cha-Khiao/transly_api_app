import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:transly_api_app/main.dart';

class TransactionSummaryCard extends StatelessWidget {
  final double totalIncome;
  final double totalExpense;
  final double balance;

  const TransactionSummaryCard({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final formatter = NumberFormat.currency(locale: 'th_TH', symbol: '฿');
    final compactFormatter = NumberFormat.compactCurrency(
      locale: 'th_TH',
      symbol: '฿',
    );

    String formatAmount(double amount) {
      if (amount.abs() >= 1000000) {
        return compactFormatter.format(amount);
      }
      return formatter.format(amount);
    }

    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: -5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:
              [
                    Text(
                      'ยอดคงเหลือทั้งหมด',
                      style: textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimary.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 8),

                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        formatAmount(balance),
                        style: textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 36,
                        ),
                        maxLines: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Container(
                        height: 1,
                        color: theme.colorScheme.onPrimary.withOpacity(0.2),
                      ),
                    ),
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildIncomeExpenseInfo(
                              context: context,
                              icon: Icons.arrow_downward_rounded,
                              label: 'รายรับ',
                              amount: formatAmount(totalIncome),
                              color: theme.colorScheme.tertiary,
                            ),
                          ),
                          VerticalDivider(
                            color: theme.colorScheme.onPrimary.withOpacity(0.2),
                            thickness: 1,
                            width: 24,
                          ),
                          Expanded(
                            child: _buildIncomeExpenseInfo(
                              context: context,
                              icon: Icons.arrow_upward_rounded,
                              label: 'รายจ่าย',
                              amount: formatAmount(totalExpense),
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]
                  .animate(interval: 80.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.2),
        ),
      ),
    );
  }

  Widget _buildIncomeExpenseInfo({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String amount,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: theme.colorScheme.onPrimary.withOpacity(0.15),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimary.withOpacity(0.8),
                ),
              ),

              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  amount,
                  style: textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
