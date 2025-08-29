import 'package:get/get.dart';
import 'package:transly_api_app/controllers/auth_binding.dart';
import 'package:transly_api_app/controllers/transaction_binding.dart';
import 'package:transly_api_app/routes/app_routes.dart';
import 'package:transly_api_app/screens/forget_pass.dart';
import 'package:transly_api_app/screens/home.dart';
import 'package:transly_api_app/screens/login.dart';
import 'package:transly_api_app/screens/profile_screen.dart';
import 'package:transly_api_app/screens/regis.dart';
import 'package:transly_api_app/screens/splash_screen.dart';
import 'package:transly_api_app/screens/transaction_detail_screen.dart';
import 'package:transly_api_app/screens/transaction_form_screen.dart';
import 'package:transly_api_app/screens/transaction_list_screen.dart';

class AppPages {
  AppPages._();

  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.forgetPassword,
      page: () => const ForgetPasswordScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.transactions,
      page: () => const TransactionListScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      binding: TransactionBinding(),
    ),
    GetPage(
      name: AppRoutes.transactionForm,
      page: () => const TransactionFormScreen(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 300),
      binding: TransactionBinding(),
    ),
    GetPage(
      name: AppRoutes.transactionDetail,
      page: () => const TransactionDetailScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}
