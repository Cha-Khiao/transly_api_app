abstract class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const forgetPassword = '/forget-password';
  static const home = '/home';
  static const profile = '/profile';

  static const transactions = '/transactions';
  static const transactionForm = '/transaction-form';
  static const transactionDetail = '/transaction-detail';

  static String getSplashRoute() => splash;
  static String getLoginRoute() => login;
  static String getRegisterRoute() => register;
  static String getForgetPasswordRoute() => forgetPassword;
  static String getHomeRoute() => home;
  static String getProfileRoute() => profile;
  static String getTransactionsRoute() => transactions;
  static String getTransactionFormRoute() => transactionForm;
  static String getTransactionDetailRoute() => transactionDetail;
}
