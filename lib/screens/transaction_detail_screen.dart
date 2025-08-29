import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:transly_api_app/controllers/transaction_controller.dart';
import 'package:transly_api_app/models/transaction_model.dart';
import 'package:transly_api_app/utils/date_helper.dart';

class TransactionDetailScreen extends StatefulWidget {
  const TransactionDetailScreen({super.key});

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen>
    with TickerProviderStateMixin {
  late final Transaction initTransaction;
  late final TransactionController transactionController;
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    initTransaction = Get.arguments as Transaction;
    transactionController = Get.find<TransactionController>();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showDeleteDialog(Transaction transaction) {
    final context = Get.context!;
    final colorScheme = Theme.of(context).colorScheme;
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('ยืนยันการลบ'),
        content: Text('คุณต้องการลบรายการ "${transaction.name}" ใช่หรือไม่?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('ยกเลิก')),
          ElevatedButton(
            onPressed: () {
              transactionController.deleteTransaction(transaction.uuid);
              Get.back();
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final transaction = transactionController.transactions.firstWhereOrNull(
        (tx) => tx.uuid == initTransaction.uuid,
      );

      if (transaction == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => Get.back());
        return const Scaffold(
          body: Center(child: Text("รายการนี้ถูกลบไปแล้ว")),
        );
      }

      final theme = Theme.of(context);
      final isIncome = transaction.type == 1;
      final typeColor = isIncome
          ? theme.colorScheme.tertiary
          : theme.colorScheme.error;

      return Scaffold(
        appBar: AppBar(
          title: const Text('รายละเอียดรายการ'),
          centerTitle: true,
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          titleTextStyle: theme.appBarTheme.titleTextStyle?.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () =>
                  Get.toNamed('/transaction-form', arguments: transaction),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _showDeleteDialog(transaction),
            ),
          ],
        ),
        body: FadeTransition(
          opacity: _animationController,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildAmountHeroCard(context, transaction, typeColor),
                const SizedBox(height: 24),
                _buildDetailsCard(context, transaction, typeColor),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildAmountHeroCard(
    BuildContext context,
    Transaction transaction,
    Color typeColor,
  ) {
    final formatter = NumberFormat.currency(locale: 'th_TH', symbol: '฿');
    final isIncome = transaction.type == 1;

    return Card(
      color: typeColor,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              isIncome
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              size: 120,
              color: Colors.white.withOpacity(0.15),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Text(
              '${isIncome ? '+' : '-'}${formatter.format(transaction.amount)}',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(
    BuildContext context,
    Transaction transaction,
    Color typeColor,
  ) {
    final bool wasEdited =
        transaction.updatedAt != null &&
        transaction.updatedAt!.difference(transaction.createdAt!).inSeconds >
            10;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: [
            _DetailRowTile(
              icon: Icons.label_outline_rounded,
              label: 'ประเภท',
              value: transaction.type == 1 ? 'รายรับ' : 'รายจ่าย',
              valueColor: typeColor,
            ),
            const Divider(indent: 16, endIndent: 16),
            _DetailRowTile(
              icon: Icons.drive_file_rename_outline_rounded,
              label: 'ชื่อรายการ',
              value: transaction.name,
            ),
            if (transaction.desc?.isNotEmpty == true) ...[
              const Divider(indent: 16, endIndent: 16),
              _DetailRowTile(
                icon: Icons.notes_rounded,
                label: 'คำอธิบาย',
                value: transaction.desc!,
              ),
            ],
            const Divider(indent: 16, endIndent: 16),
            _DetailRowTile(
              icon: Icons.calendar_today_outlined,
              label: 'วันและเวลาที่ทำรายการ',
              value:
                  '${formatThaiDateShort(transaction.date ?? transaction.createdAt)}\n'
                  '${formatThaiTime(transaction.createdAt)}',
            ),
            if (wasEdited) ...[
              const Divider(indent: 16, endIndent: 16),
              _DetailRowTile(
                icon: Icons.edit_calendar_outlined,
                label: 'วันและเวลาที่แก้ไข',
                value:
                    '${formatThaiDateShort(transaction.updatedAt!)}\n'
                    '${formatThaiTime(transaction.updatedAt!)}',
              ),
            ],
          ].animate(interval: 80.ms).fadeIn().slideX(begin: 0.1),
        ),
      ),
    );
  }
}

class _DetailRowTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Color? valueColor;

  const _DetailRowTile({
    required this.icon,
    required this.label,
    this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary.withOpacity(0.8)),
      title: Text(label, style: theme.textTheme.bodyMedium),
      trailing: Text(
        value ?? '',
        textAlign: TextAlign.end,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: valueColor,
        ),
      ),
    );
  }
}
