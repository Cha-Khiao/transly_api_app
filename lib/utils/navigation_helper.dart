import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:transly_api_app/models/transaction_model.dart';
import 'package:transly_api_app/routes/app_routes.dart';

class NavigationHelper {
  NavigationHelper._();

  static Future<T?>? toNamed<T>(String routeName, {dynamic arguments}) =>
      Get.toNamed<T>(routeName, arguments: arguments);

  static Future<T?>? offNamed<T>(String routeName, {dynamic arguments}) =>
      Get.offNamed<T>(routeName, arguments: arguments);

  static Future<T?>? offAllNamed<T>(String routeName, {dynamic arguments}) =>
      Get.offAllNamed<T>(routeName, arguments: arguments);

  static void back<T>([T? result]) => Get.back<T>(result: result);

  static void toLogin({bool clearStack = false}) {
    clearStack ? offAllNamed(AppRoutes.login) : toNamed(AppRoutes.login);
  }

  static void toRegister() {
    toNamed(AppRoutes.register);
  }

  static void toForgetPassword() {
    toNamed(AppRoutes.forgetPassword);
  }

  static void toHome({bool clearStack = true}) {
    clearStack ? offAllNamed(AppRoutes.home) : toNamed(AppRoutes.home);
  }

  static void toTransactions() {
    toNamed(AppRoutes.transactions);
  }

  static void toTransactionForm({Transaction? transaction}) {
    toNamed(AppRoutes.transactionForm, arguments: transaction);
  }

  static void _showCustomSnackbar({
    required String title,
    required String message,
    required Color accentColor,
    required IconData icon,
  }) {
    final theme = Get.theme;
    Get.snackbar(
      "",
      "",
      snackPosition: SnackPosition.TOP,
      backgroundColor: theme.cardColor,
      borderRadius: 12,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      duration: const Duration(seconds: 1),
      leftBarIndicatorColor: accentColor,
      titleText: Row(
        children: [
          Icon(icon, color: accentColor, size: 22),
          const SizedBox(width: 12),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      messageText: Text(
        message,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.secondary,
        ),
      ),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
    );
  }

  static void showSuccessSnackBar(String message) {
    _showCustomSnackbar(
      title: 'สำเร็จ',
      message: message,
      accentColor: const Color(0xFF1E8E3E),
      icon: Icons.check_circle_rounded,
    );
  }

  static void showErrorSnackBar(String message) {
    _showCustomSnackbar(
      title: 'เกิดข้อผิดพลาด',
      message: message,
      accentColor: Get.theme.colorScheme.error,
      icon: Icons.error_rounded,
    );
  }

  static void showWarningSnackBar(String message) {
    _showCustomSnackbar(
      title: 'คำเตือน',
      message: message,
      accentColor: const Color(0xFFFF9800),
      icon: Icons.warning_rounded,
    );
  }

  static void showTopSuccessSnackBar(String message) {
    showSuccessSnackBar(message);
  }

  static void showTopErrorSnackBar(String message) {
    showErrorSnackBar(message);
  }

  static void showTopWarningSnackBar(String message) {
    showWarningSnackBar(message);
  }

  static Future<bool?> showConfirmDialog({
    required String title,
    required String message,
    String confirmText = 'ยืนยัน',
    String cancelText = 'ยกเลิก',
  }) {
    return Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: title.contains('ลบ')
                  ? Get.theme.colorScheme.error
                  : null,
              foregroundColor: title.contains('ลบ')
                  ? Get.theme.colorScheme.onError
                  : null,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}
