import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:transly_api_app/controllers/auth_controller.dart';
import 'package:transly_api_app/main.dart';
import 'package:transly_api_app/routes/app_routes.dart';
import 'package:transly_api_app/screens/splash_screen.dart';

class LoginController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final AuthController authController = Get.find<AuthController>();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late final TextEditingController emailController;
  late final TextEditingController passwordController;

  final RxBool obscurePassword = true.obs;
  final RxBool isLoading = false.obs;
  final RxBool rememberMe = false.obs;

  late AnimationController animationController;
  late Animation<double> formFadeAnimation;
  late Animation<Offset> formSlideAnimation;
  late Animation<double> headerFadeAnimation;
  late Animation<Offset> headerSlideAnimation;

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
    passwordController = TextEditingController();

    animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    headerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    headerSlideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: animationController,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
          ),
        );

    formFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );
    formSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: animationController,
            curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    animationController.forward();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    animationController.dispose();
    super.onClose();
  }

  Future<void> handleLogin() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;
    try {
      final success = await authController.login(
        name: emailController.text.trim(),
        password: passwordController.text,
        rememberMe: rememberMe.value,
      );

      if (success) {
        Get.offAllNamed(AppRoutes.home);
      }
    } finally {
      isLoading.value = false;
    }
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      body: Stack(
        children: [
          _buildAnimatedBackground(theme),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 32.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(textTheme, theme, controller),
                  const SizedBox(height: 48),
                  _buildGlassmorphismCard(controller, context),
                  const SizedBox(height: 32),
                  _buildSignUpLink(textTheme, theme, controller),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground(ThemeData theme) {
    return Stack(
      children: [
        Container(color: theme.scaffoldBackgroundColor),
        Positioned(
          top: -150,
          left: -150,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: -200,
          right: -100,
          child: Container(
            width: 450,
            height: 450,
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
          ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 100.0, sigmaY: 100.0),
          child: Container(color: Colors.black.withOpacity(0.1)),
        ),
      ],
    );
  }

  Widget _buildHeader(
    TextTheme textTheme,
    ThemeData theme,
    LoginController controller,
  ) {
    return FadeTransition(
      opacity: controller.headerFadeAnimation,
      child: SlideTransition(
        position: controller.headerSlideAnimation,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.surface.withOpacity(0.8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.wallet_rounded,
                size: 56,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'ยินดีต้อนรับ!',
              textAlign: TextAlign.center,
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'กรุณาเข้าสู่ระบบเพื่อจัดการการเงินของคุณ',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassmorphismCard(
    LoginController controller,
    BuildContext context,
  ) {
    return FadeTransition(
      opacity: controller.formFadeAnimation,
      child: SlideTransition(
        position: controller.formSlideAnimation,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 32.0,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: _buildForm(controller),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(LoginController controller) {
    return Form(
      key: controller.formKey,
      child: Column(
        children: [
          TextFormField(
            controller: controller.emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'อีเมล',
              prefixIcon: Icon(Icons.alternate_email_rounded),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'กรุณากรอกอีเมล';
              }
              if (!GetUtils.isEmail(value)) {
                return 'รูปแบบอีเมลไม่ถูกต้อง';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          Obx(
            () => TextFormField(
              controller: controller.passwordController,
              obscureText: controller.obscurePassword.value,
              decoration: InputDecoration(
                labelText: 'รหัสผ่าน',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.obscurePassword.value
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () => controller.obscurePassword.toggle(),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'กรุณากรอกรหัสผ่าน';
                }
                if (value.length < 6) {
                  return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 24),
          _buildOptionsRow(controller),
          const SizedBox(height: 32),
          _buildLoginButton(controller),
        ],
      ),
    );
  }

  Widget _buildOptionsRow(LoginController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Obx(
              () => Checkbox(
                value: controller.rememberMe.value,
                onChanged: (value) => controller.rememberMe.value = value!,
                activeColor: Theme.of(Get.context!).colorScheme.primary,
                checkColor: Theme.of(Get.context!).colorScheme.onPrimary,
              ),
            ),
            const Text('จดจำฉัน'),
          ],
        ),
        TextButton(
          onPressed: () => Get.toNamed(AppRoutes.forgetPassword),
          child: const Text('ลืมรหัสผ่าน?'),
        ),
      ],
    );
  }

  Widget _buildLoginButton(LoginController controller) {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: controller.isLoading.value ? null : controller.handleLogin,
          child: controller.isLoading.value
              ? const SizedBox(
                  height: 24,
                  width: 80,
                  child: LoadingDots(color: Colors.white),
                )
              : const Text('เข้าสู่ระบบ'),
        ),
      ),
    );
  }

  Widget _buildSignUpLink(
    TextTheme textTheme,
    ThemeData theme,
    LoginController controller,
  ) {
    return FadeTransition(
      opacity: controller.formFadeAnimation,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('ยังไม่มีบัญชี?', style: textTheme.bodyMedium),
          TextButton(
            onPressed: () => Get.toNamed(AppRoutes.register),
            child: Text(
              'สร้างบัญชีใหม่',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
