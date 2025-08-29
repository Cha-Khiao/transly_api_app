import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:transly_api_app/components/drawer.dart';
import 'package:transly_api_app/components/transaction_card.dart';
import 'package:transly_api_app/components/transaction_summary_card.dart';
import 'package:transly_api_app/controllers/transaction_controller.dart';
import 'package:transly_api_app/models/transaction_model.dart';

class TransactionListController extends GetxController {
  final TransactionController transactionController =
      Get.find<TransactionController>();

  final Rx<String?> selectedMonth = Rx<String?>(null);

  List<String> get availableMonths {
    final transactions = transactionController.sortedTransactions;
    if (transactions.isEmpty) return [];
    final monthSet = <String>{};
    for (var tx in transactions) {
      final date = tx.date ?? tx.createdAt!;
      monthSet.add(DateFormat('MMMM yyyy', 'th').format(date.toLocal()));
    }
    return monthSet.toList();
  }

  Map<String, List<Transaction>> get groupedTransactions {
    var transactions = transactionController.sortedTransactions;

    if (selectedMonth.value != null) {
      transactions = transactions.where((tx) {
        final date = tx.date ?? tx.createdAt!;
        final monthYear = DateFormat('MMMM yyyy', 'th').format(date.toLocal());
        return monthYear == selectedMonth.value;
      }).toList();
    }

    final grouped = groupBy(transactions, (Transaction t) {
      final date = t.date ?? t.createdAt ?? DateTime(2000);
      final localDate = date.toLocal();
      return DateFormat('MMMM yyyy', 'th').format(localDate);
    });

    grouped.forEach((key, value) {
      value.sort((a, b) {
        final dateA = a.date ?? a.createdAt!;
        final dateB = b.date ?? b.createdAt!;
        return dateB.compareTo(dateA);
      });
    });

    return grouped;
  }

  void changeMonthFilter(String? month) {
    selectedMonth.value = month;
    update();
  }

  void showDeleteDialog(Transaction transaction) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('ยืนยันการลบ'),
        content: Text('คุณต้องการลบรายการ "${transaction.name}" ใช่หรือไม่?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('ยกเลิก')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              transactionController.deleteTransaction(transaction.uuid);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Get.theme.colorScheme.error,
              foregroundColor: Get.theme.colorScheme.onError,
            ),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
  }

  void changeTabIndex(int index) {
    if (index == 1) return;
    switch (index) {
      case 0:
        Get.offAllNamed('/home');
        break;
      case 2:
        Get.offAllNamed('/profile');
        break;
    }
  }
}

class TransactionListScreen extends GetView<TransactionListController> {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(TransactionListController());
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการทั้งหมด'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        titleTextStyle: theme.appBarTheme.titleTextStyle?.copyWith(
          color: theme.colorScheme.onPrimary,
        ),
      ),
      drawer: const AppDrawer(),
      body: Obx(() {
        if (controller.transactionController.isLoading.value &&
            controller.transactionController.transactions.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.transactionController.transactions.isEmpty) {
          return _buildEmptyState(context);
        }

        final grouped = controller.groupedTransactions;
        final sortedGroupEntries = grouped.entries.toList();
        sortedGroupEntries.sort((a, b) {
          final firstDateInA = a.value.first.date ?? a.value.first.createdAt!;
          final firstDateInB = b.value.first.date ?? b.value.first.createdAt!;
          return firstDateInB.compareTo(firstDateInA);
        });

        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              sliver: SliverToBoxAdapter(
                child: Obx(
                  () => TransactionSummaryCard(
                    balance: controller.transactionController.balance,
                    totalIncome: controller.transactionController.totalIncome,
                    totalExpense: controller.transactionController.totalExpense,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('รายการทั้งหมด', style: theme.textTheme.titleLarge),
                    _buildMonthFilterDropdown(),
                  ],
                ),
              ),
            ),
            ...sortedGroupEntries.expand((entry) {
              final dateKey = entry.key;
              final transactionsInGroup = entry.value;
              return [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
                    child: Text(
                      dateKey,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final transaction = transactionsInGroup[index];
                      return TransactionCard(
                        transaction: transaction,
                        onTap: () => Get.toNamed(
                          '/transaction-detail',
                          arguments: transaction,
                        ),
                        onEdit: () => Get.toNamed(
                          '/transaction-form',
                          arguments: transaction,
                        ),
                        onDelete: () =>
                            controller.showDeleteDialog(transaction),
                      );
                    }, childCount: transactionsInGroup.length),
                  ),
                ),
              ];
            }),
            SliverToBoxAdapter(child: const SizedBox(height: 100)),
          ],
        ).animate().fadeIn(duration: 400.ms);
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/transaction-form'),
        child: const Icon(Icons.add_rounded),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(controller),
    );
  }

  Widget _buildMonthFilterDropdown() {
    return Obx(() {
      final availableMonths = controller.availableMonths;
      final selectedMonth = controller.selectedMonth.value;

      return DropdownButton<String>(
        value: selectedMonth,
        hint: const Text('ทุกเดือน'),
        underline: Container(),
        items: [
          const DropdownMenuItem<String>(value: null, child: Text('ทุกเดือน')),
          ...availableMonths.map((String month) {
            return DropdownMenuItem<String>(value: month, child: Text(month));
          }),
        ],
        onChanged: (String? newValue) {
          controller.changeMonthFilter(newValue);
        },
      );
    });
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: theme.colorScheme.primary.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'ยังไม่มีรายการธุรกรรม',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'เริ่มต้นบันทึกรายรับ-รายจ่ายแรกของคุณได้เลย',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Get.toNamed('/transaction-form');
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('เพิ่มรายการแรก'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(TransactionListController controller) {
    return NavigationBar(
      selectedIndex: 1,
      onDestinationSelected: controller.changeTabIndex,
      indicatorShape: const StadiumBorder(),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'หน้าหลัก',
        ),
        NavigationDestination(
          icon: Icon(Icons.receipt_long_outlined),
          selectedIcon: Icon(Icons.receipt_long_rounded),
          label: 'รายการ',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(Icons.person_rounded),
          label: 'โปรไฟล์',
        ),
      ],
    );
  }
}
