import 'package:get/get.dart';
import 'package:transly_api_app/controllers/auth_controller.dart';
import 'package:transly_api_app/models/transaction_model.dart';
import 'package:transly_api_app/services/api_service.dart';
import 'package:transly_api_app/utils/api.dart';
import 'package:transly_api_app/utils/navigation_helper.dart';

class TransactionController extends GetxController {
  var transactions = <Transaction>[].obs;
  var isLoading = false.obs;

  final AuthController authController = Get.find<AuthController>();
  late Worker _authWorker;

  List<Transaction> get sortedTransactions {
    final sortedList = List<Transaction>.from(transactions);
    sortedList.sort((a, b) {
      final dateA = a.updatedAt ?? a.date ?? a.createdAt ?? DateTime(2000);
      final dateB = b.updatedAt ?? b.date ?? b.createdAt ?? DateTime(2000);
      return dateB.compareTo(dateA);
    });
    return sortedList;
  }

  @override
  void onInit() {
    super.onInit();
    if (authController.isLoggedIn.value) {
      fetchTransactions();
    }
    _authWorker = ever(authController.isLoggedIn, (bool isLoggedIn) {
      if (isLoggedIn) {
        fetchTransactions();
      } else {
        transactions.clear();
      }
    });
  }

  @override
  void onClose() {
    _authWorker.dispose();
    super.onClose();
  }

  Future<void> fetchTransactions() async {
    if (isLoading.value) return;
    if (!authController.isLoggedIn.value) return;
    try {
      isLoading.value = true;
      final response = await ApiService.get(TRANSACTION_ENDPOINT);
      if (response['success'] == true) {
        final List<dynamic> data = response['data'];
        transactions.value = data
            .map((json) => Transaction.fromJson(json))
            .toList();
      }
    } catch (e) {
      NavigationHelper.showErrorSnackBar('ไม่สามารถดึงข้อมูลรายการได้');
    } finally {
      isLoading.value = false;
    }
  }

  Future<Transaction?> createTransaction(Transaction transaction) async {
    try {
      final data = transaction.toJson();
      final response = await ApiService.post(TRANSACTION_ENDPOINT, data);
      if (response['success'] == true) {
        return Transaction.fromJson(response['data']);
      } else {
        NavigationHelper.showTopErrorSnackBar(
          'สร้างรายการล้มเหลว: ${response['message'] ?? 'เกิดข้อผิดพลาด'}',
        );
        return null;
      }
    } catch (e) {
      NavigationHelper.showTopErrorSnackBar(
        'สร้างรายการล้มเหลว: ${e.toString()}',
      );
      return null;
    }
  }

  Future<Transaction?> updateTransaction(Transaction transaction) async {
    try {
      if (transaction.uuid == null) {
        NavigationHelper.showTopErrorSnackBar(
          'ไม่สามารถแก้ไขรายการนี้ได้: ไม่พบรหัสรายการ',
        );
        return null;
      }
      final data = transaction.toJson();
      final response = await ApiService.put(
        '$TRANSACTION_ENDPOINT/${transaction.uuid}',
        data,
      );
      if (response['success'] == true) {
        final updatedData = Transaction.fromJson(response['data']);
        return Transaction(
          uuid: transaction.uuid,
          createdAt: transaction.createdAt,
          name: updatedData.name,
          desc: updatedData.desc,
          amount: updatedData.amount,
          type: updatedData.type,
          date: updatedData.date,
          updatedAt: updatedData.updatedAt,
        );
      } else {
        NavigationHelper.showTopErrorSnackBar(
          'แก้ไขรายการล้มเหลว: ${response['message'] ?? 'เกิดข้อผิดพลาด'}',
        );
        return null;
      }
    } catch (e) {
      NavigationHelper.showTopErrorSnackBar(
        'แก้ไขรายการล้มเหลว: ${e.toString()}',
      );
      return null;
    }
  }

  void upsertTransactionInList(Transaction transaction) {
    final index = transactions.indexWhere((t) => t.uuid == transaction.uuid);
    if (index != -1) {
      transactions[index] = transaction;
    } else {
      transactions.insert(0, transaction);
    }
  }

  Future<void> deleteTransaction(String? uuid) async {
    try {
      if (uuid == null) {
        NavigationHelper.showTopErrorSnackBar(
          'ไม่สามารถลบรายการนี้ได้: ไม่พบรหัสรายการ',
        );
        return;
      }
      final response = await ApiService.delete('$TRANSACTION_ENDPOINT/$uuid');
      if (response['success'] == true) {
        transactions.removeWhere((t) => t.uuid == uuid);
        NavigationHelper.showTopSuccessSnackBar('ลบรายการสำเร็จแล้ว');
      } else {
        NavigationHelper.showTopErrorSnackBar(
          'ลบรายการล้มเหลว: ${response['message'] ?? 'เกิดข้อผิดพลาด'}',
        );
      }
    } catch (e) {
      NavigationHelper.showTopErrorSnackBar('ลบรายการล้มเหลว: ${e.toString()}');
    }
  }

  double get totalIncome => transactions
      .where((t) => t.type == 1)
      .fold(0, (sum, t) => sum + t.amount);
  double get totalExpense => transactions
      .where((t) => t.type != 1)
      .fold(0, (sum, t) => sum + t.amount);
  double get balance => totalIncome - totalExpense;
}
