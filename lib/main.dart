import 'package:flutter/material.dart';
import 'package:transly_api_app/controllers/auth_controller.dart';
import 'package:transly_api_app/controllers/transaction_controller.dart';
import 'package:transly_api_app/routes/app_pages.dart';
import 'package:transly_api_app/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';
import 'package:transly_api_app/services/storage_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('th', null);
  final directory = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(directory.path);

  await Get.putAsync(() async {
    final storageService = StorageService();
    await storageService.init();
    return storageService;
  }, permanent: true);

  Get.put(AuthController(), permanent: true);
  Get.put(TransactionController(), permanent: true);

  runApp(const MainApp());
}

class AppTheme {
  static const _primaryColor = Color(0xFF4F46E5);
  static const _accentColor = Color(0xFFDB2777);
  static const _backgroundColor = Color(0xFFF4F6FA);
  static const _surfaceColor = Color(0xFFFFFFFF);
  static const _textColor = Color(0xFF1E293B);
  static const _subtleTextColor = Color(0xFF64748B);
  static const _incomeColor = Color(0xFF22C55E);
  static const _expenseColor = Color(0xFFEF4444);

  static const primaryGradient = LinearGradient(
    colors: [_accentColor, _primaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get theme {
    final textTheme = GoogleFonts.kanitTextTheme();

    return ThemeData(
      useMaterial3: true,
      fontFamily: GoogleFonts.kanit().fontFamily,
      brightness: Brightness.light,
      primaryColor: _primaryColor,
      scaffoldBackgroundColor: _backgroundColor,
      colorScheme: const ColorScheme.light(
        primary: _primaryColor,
        secondary: _accentColor,
        surface: _surfaceColor,
        error: _expenseColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: _textColor,
        tertiary: _incomeColor,
      ),
      textTheme: textTheme
          .copyWith(
            displayLarge: textTheme.displayLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: _textColor,
            ),
            headlineMedium: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: _textColor,
              fontSize: 28,
            ),
            titleLarge: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: _textColor,
              fontSize: 22,
            ),
            bodyLarge: textTheme.bodyLarge?.copyWith(
              fontSize: 18,
              color: _textColor,
              height: 1.5,
            ),
            bodyMedium: textTheme.bodyMedium?.copyWith(
              fontSize: 16,
              color: _subtleTextColor,
              height: 1.5,
            ),
            labelLarge: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 17,
            ),
          )
          .apply(bodyColor: _textColor, displayColor: _textColor),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: _primaryColor,
        selectionColor: _primaryColor.withOpacity(0.5),
        selectionHandleColor: _primaryColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: _textColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: _textColor,
          fontWeight: FontWeight.bold,
          fontSize: 21,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: textTheme.labelLarge?.copyWith(
            color: Colors.white,
            fontSize: 17,
          ),
          elevation: 5,
          shadowColor: _primaryColor.withOpacity(0.4),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        color: _surfaceColor,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _primaryColor, width: 2.0),
        ),
        labelStyle: textTheme.bodyLarge?.copyWith(color: _subtleTextColor),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _accentColor,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade200,
        thickness: 1,
        space: 1,
      ),
    );
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Finance Tracker App',
      initialRoute: AppRoutes.splash,
      getPages: AppPages.routes,
      locale: const Locale('th', 'TH'),
      fallbackLocale: const Locale('th', 'TH'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('th', 'TH')],
      theme: AppTheme.theme,
    );
  }
}
