import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:transly_api_app/models/user_model.dart';
import 'package:transly_api_app/routes/app_routes.dart';
import 'package:transly_api_app/services/api_service.dart';
import 'package:transly_api_app/services/storage_service.dart';
import 'package:transly_api_app/utils/navigation_helper.dart';

class AuthController extends GetxController {
  final isLoggedIn = false.obs;
  final isLoading = false.obs;
  final _currentUser = Rxn<User>();

  final StorageService _storageService = Get.find<StorageService>();

  User? get currentUser => _currentUser.value;

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      if (kDebugMode) print('Checking login status...');

      final token = _storageService.getToken();
      if (token == null || token.isEmpty) {
        if (kDebugMode) print('No token found, user is logged out.');
        isLoggedIn.value = false;
        return;
      }

      final userData = _storageService.getUser();
      if (userData == null) {
        if (kDebugMode) {
          print('Token found but no user data, user is logged out.');
        }
        isLoggedIn.value = false;
        await _storageService.deleteToken();
        return;
      }

      final user = User.fromJson(userData);
      _currentUser.value = user;
      isLoggedIn.value = true;
      if (kDebugMode) print('User restored from storage: ${user.name}');
    } catch (e) {
      if (kDebugMode) print('Error checking login status: $e');
      isLoggedIn.value = false;
      await logout();
    }
  }

  Future<bool> login({
    required String name,
    required String password,
    required bool rememberMe,
  }) async {
    try {
      isLoading.value = true;
      final response = await ApiService.login(name, password);

      if (response['success'] == true) {
        final token = response['data']['access'];
        final authData = response['data']['auth'];
        final user = User.fromJson(authData);

        _currentUser.value = user;
        await _storageService.saveToken(token);
        await _storageService.saveUser(user.toJson());
        isLoggedIn.value = true;

        NavigationHelper.showTopSuccessSnackBar('เข้าสู่ระบบสำเร็จแล้ว');
        Get.offAllNamed(AppRoutes.home);
        return true;
      } else {
        NavigationHelper.showTopErrorSnackBar(
          'ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง',
        );
        return false;
      }
    } catch (e) {
      NavigationHelper.showTopErrorSnackBar('เกิดข้อผิดพลาด: ${e.toString()}');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> register({
    required String name,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      isLoading.value = true;
      final response = await ApiService.register(
        name,
        password,
        firstName,
        lastName,
      );

      if (response['success'] == true) {
        NavigationHelper.showTopSuccessSnackBar('สมัครสมาชิกสำเร็จแล้ว');
        await Future.delayed(const Duration(milliseconds: 1500));
        Get.offNamed(AppRoutes.login);
        return true;
      } else {
        NavigationHelper.showTopErrorSnackBar(
          'สมัครสมาชิกล้มเหลว: ${response['message'] ?? 'เกิดข้อผิดพลาด'}',
        );
        return false;
      }
    } catch (e) {
      NavigationHelper.showTopErrorSnackBar(
        'สมัครสมาชิกล้มเหลว: ${e.toString()}',
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> resetPassword(String name) async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(seconds: 2));
      NavigationHelper.showTopSuccessSnackBar(
        'ส่งลิงก์รีเซ็ตรหัสผ่านไปยังอีเมลของคุณแล้ว',
      );
      return true;
    } catch (e) {
      NavigationHelper.showTopErrorSnackBar('เกิดข้อผิดพลาด: ${e.toString()}');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      await _storageService.deleteToken();
      await _storageService.deleteUser();
      isLoggedIn.value = false;
      _currentUser.value = null;

      Get.offAllNamed(AppRoutes.login);
      NavigationHelper.showTopSuccessSnackBar('ออกจากระบบแล้ว');
    } catch (e) {
      NavigationHelper.showTopErrorSnackBar('เกิดข้อผิดพลาด: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void confirmLogout() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('ยืนยันการออกจากระบบ'),
        content: const Text('คุณต้องการออกจากระบบใช่หรือไม่?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('ยกเลิก')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Get.theme.colorScheme.error,
            ),
            child: const Text('ออกจากระบบ'),
          ),
        ],
      ),
    );
  }
}
