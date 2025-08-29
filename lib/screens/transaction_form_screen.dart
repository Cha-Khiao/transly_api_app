import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:transly_api_app/components/transaction_form.dart';
import 'package:transly_api_app/controllers/transaction_controller.dart';
import 'package:transly_api_app/models/transaction_model.dart';
import 'package:transly_api_app/utils/navigation_helper.dart';

class TransactionFormScreenController extends GetxController {
  final TransactionController transactionController =
      Get.find<TransactionController>();

  final RxBool isLoading = false.obs;
  late final bool isEditing;
  late final Transaction? transaction;

  @override
  void onInit() {
    super.onInit();
    transaction = Get.arguments as Transaction?;
    isEditing = transaction != null;
  }

  Future<void> handleSubmit(Transaction transactionData) async {
    FocusManager.instance.primaryFocus?.unfocus();
    isLoading.value = true;

    try {
      Transaction? result;
      if (isEditing) {
        result = await transactionController.updateTransaction(transactionData);
      } else {
        result = await transactionController.createTransaction(transactionData);
      }

      if (result != null) {
        transactionController.upsertTransactionInList(result);
        Get.back();
        NavigationHelper.showSuccessSnackBar(
          isEditing ? 'แก้ไขรายการสำเร็จแล้ว' : 'สร้างรายการสำเร็จแล้ว',
        );
      }
    } finally {
      isLoading.value = false;
    }
  }
}

class TransactionFormScreen extends GetView<TransactionFormScreenController> {
  const TransactionFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(TransactionFormScreenController());
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(controller.isEditing ? 'แก้ไขรายการ' : 'เพิ่มรายการใหม่'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        titleTextStyle: theme.appBarTheme.titleTextStyle?.copyWith(
          color: theme.colorScheme.onPrimary,
        ),
      ),
      body: SafeArea(
        child: Obx(
          () =>
              TransactionForm(
                    transaction: controller.transaction,
                    onSubmit: controller.handleSubmit,
                    isLoading: controller.isLoading.value,
                  )
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.1, curve: Curves.easeOutCubic),
        ),
      ),
    );
  }
}
