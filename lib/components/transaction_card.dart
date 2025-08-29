import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:transly_api_app/models/transaction_model.dart';
import 'package:transly_api_app/utils/date_helper.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TransactionCard({
    required this.transaction,
    this.onTap,
    this.onEdit,
    this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final formatter = NumberFormat.currency(locale: 'th_TH', symbol: '฿');

    final bool isIncome = transaction.type == 1;
    final Color amountColor = isIncome
        ? theme.colorScheme.tertiary
        : theme.colorScheme.error;
    final IconData iconData = isIncome
        ? Icons.download_rounded
        : Icons.upload_rounded;

    return Slidable(
          key: ValueKey(transaction.uuid),
          endActionPane: ActionPane(
            motion: const BehindMotion(),
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.centerRight,
                  color: theme.scaffoldBackgroundColor,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => onEdit?.call(),
                        icon: const Icon(Icons.edit_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary
                              .withOpacity(0.1),
                          foregroundColor: theme.colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.all(12),
                        ),
                        tooltip: 'แก้ไข',
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => onDelete?.call(),
                        icon: const Icon(Icons.delete_forever_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: theme.colorScheme.error.withOpacity(
                            0.1,
                          ),
                          foregroundColor: theme.colorScheme.error,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.all(12),
                        ),
                        tooltip: 'ลบ',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: amountColor.withOpacity(0.1),
                      child: Icon(iconData, color: amountColor, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction.name,
                            style: textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatThaiDateShort(
                              transaction.date ?? transaction.createdAt,
                            ),
                            style: textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '${isIncome ? '+' : ''}${formatter.format(isIncome ? transaction.amount : -transaction.amount)}',
                          style: textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: amountColor,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 500.ms, curve: Curves.easeOut)
        .slideX(begin: 0.5, duration: 500.ms, curve: Curves.easeOutCubic);
  }
}
