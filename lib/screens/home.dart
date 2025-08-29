import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:transly_api_app/components/drawer.dart';
import 'package:transly_api_app/components/transaction_card.dart';
import 'package:transly_api_app/components/transaction_summary_card.dart';
import 'package:transly_api_app/controllers/auth_controller.dart';
import 'package:transly_api_app/controllers/transaction_controller.dart';
import 'package:transly_api_app/models/transaction_model.dart';

class HomeController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final TransactionController transactionController =
      Get.find<TransactionController>();
  final RxInt currentIndex = 0.obs;

  void changeTabIndex(int index) {
    if (currentIndex.value == index) return;
    currentIndex.value = index;
    switch (index) {
      case 1:
        Get.toNamed('/transactions')?.then((_) => currentIndex.value = 0);
        break;
      case 2:
        Get.toNamed('/profile')?.then((_) => currentIndex.value = 0);
        break;
    }
  }

  void goToAddTransaction() {
    Get.toNamed('/transaction-form');
  }

  void goToTransactionList() {
    Get.toNamed('/transactions');
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

  void showFeatureNotAvailableDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.info_outline_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text("ยังไม่พร้อมใช้งาน"),
          ],
        ),
        content: const Text('ขออภัย ฟีเจอร์นี้กำลังอยู่ในระหว่างการพัฒนาครับ'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('ตกลง')),
        ],
      ),
    );
  }
}

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HomeController());
    return Scaffold(
      appBar: AppBar(
        title: const Text('แดชบอร์ด'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        titleTextStyle: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: controller.showFeatureNotAvailableDialog,
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.transactionController.fetchTransactions();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                [
                      _buildHeader(context, controller),
                      const SizedBox(height: 24),
                      Obx(() {
                        if (controller.transactionController.isLoading.value &&
                            controller
                                .transactionController
                                .transactions
                                .isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        if (controller
                            .transactionController
                            .transactions
                            .isEmpty) {
                          return Center(
                            child: _buildEmptyState(context, controller),
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSummarySection(context, controller),
                            const SizedBox(height: 32),
                            _buildRecentTransactions(context, controller),
                          ],
                        ).animate().fadeIn();
                      }),
                    ]
                    .animate(interval: 100.ms)
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.1, curve: Curves.easeOutCubic),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.goToAddTransaction,
        child: const Icon(Icons.add_rounded),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(controller),
    );
  }

  Widget _buildHeader(BuildContext context, HomeController controller) {
    final textTheme = Theme.of(context).textTheme;
    String greeting() {
      final hour = DateTime.now().hour;
      if (hour < 12) return 'สวัสดีตอนเช้า';
      if (hour < 18) return 'สวัสดีตอนบ่าย';
      return 'สวัสดีตอนเย็น';
    }

    return Obx(() {
      final user = controller.authController.currentUser;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${greeting()},', style: textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text(
            user?.fullName ?? "ผู้ใช้งาน",
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildSummarySection(BuildContext context, HomeController controller) {
    return Obx(
      () => TransactionSummaryCard(
        balance: controller.transactionController.balance,
        totalIncome: controller.transactionController.totalIncome,
        totalExpense: controller.transactionController.totalExpense,
      ),
    );
  }

  Widget _buildRecentTransactions(
    BuildContext context,
    HomeController controller,
  ) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'รายการล่าสุด',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: controller.goToTransactionList,
              child: const Text('ดูทั้งหมด'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(() {
          final recent = controller.transactionController.sortedTransactions
              .take(5)
              .toList();
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recent.length,
            itemBuilder: (context, index) {
              final transaction = recent[index];
              return TransactionCard(
                transaction: transaction,
                onTap: () =>
                    Get.toNamed('/transaction-detail', arguments: transaction),
                onEdit: () =>
                    Get.toNamed('/transaction-form', arguments: transaction),
                onDelete: () => controller.showDeleteDialog(transaction),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, HomeController controller) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
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
            onPressed: controller.goToAddTransaction,
            icon: const Icon(Icons.add_rounded),
            label: const Text('เพิ่มรายการแรก'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(HomeController controller) {
    return Obx(
      () => NavigationBar(
        selectedIndex: controller.currentIndex.value,
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
      ),
    );
  }
}
