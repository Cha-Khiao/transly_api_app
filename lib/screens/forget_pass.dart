import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:transly_api_app/controllers/auth_controller.dart';
import 'package:transly_api_app/main.dart';
import 'package:transly_api_app/screens/splash_screen.dart';

class ForgetPasswordController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final AuthController authController = Get.find<AuthController>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late TextEditingController emailController;
  final RxBool isLoading = false.obs;
  final RxBool emailSent = false.obs;

  late AnimationController animationController;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();

    animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );
    slideAnimation =
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
    animationController.dispose();
    super.onClose();
  }

  Future<void> handleSendResetLink() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!formKey.currentState!.validate()) {
      return;
    }
    isLoading.value = true;
    try {
      bool success = await authController.resetPassword(
        emailController.text.trim(),
      );
      if (success) {
        emailSent.value = true;
      }
    } finally {
      isLoading.value = false;
    }
  }

  void resetForm() {
    emailSent.value = false;
  }
}

class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForgetPasswordController());
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          _buildAnimatedBackground(theme),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 32.0,
                ),
                child: _buildGlassmorphismCard(controller, context),
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
          bottom: -150,
          right: -150,
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
          top: -200,
          left: -100,
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

  Widget _buildGlassmorphismCard(
    ForgetPasswordController controller,
    BuildContext context,
  ) {
    return FadeTransition(
      opacity: controller.fadeAnimation,
      child: SlideTransition(
        position: controller.slideAnimation,
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
              child: Obx(
                () => AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.0, 0.3),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: controller.emailSent.value
                      ? _buildSuccessView(context, controller)
                      : _buildFormView(context, controller),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormView(
    BuildContext context,
    ForgetPasswordController controller,
  ) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Form(
      key: controller.formKey,
      child: Column(
        key: const ValueKey('formView'),
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20),
              ],
            ),
            child: Icon(
              Icons.lock_reset_rounded,
              size: 56,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'ลืมรหัสผ่าน?',
            textAlign: TextAlign.center,
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'กรอกอีเมลที่เชื่อมกับบัญชีของคุณ เราจะส่งลิงก์สำหรับรีเซ็ตรหัสผ่านให้',
            style: textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
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
          const SizedBox(height: 32),
          Obx(
            () => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : controller.handleSendResetLink,
                child: controller.isLoading.value
                    ? const SizedBox(
                        height: 24,
                        width: 80,
                        child: LoadingDots(color: Colors.white),
                      )
                    : const Text('ส่งลิงก์รีเซ็ต'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(
    BuildContext context,
    ForgetPasswordController controller,
  ) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Column(
      key: const ValueKey('successView'),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20),
            ],
          ),
          child: Icon(
            Icons.mark_email_read_rounded,
            size: 56,
            color: theme.colorScheme.tertiary,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'ส่งลิงก์แล้ว!',
          textAlign: TextAlign.center,
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: textTheme.bodyMedium,
            children: [
              const TextSpan(text: 'เราได้ส่งลิงก์รีเซ็ตรหัสผ่านไปยัง\n'),
              TextSpan(
                text: controller.emailController.text,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const TextSpan(text: '\nกรุณาตรวจสอบกล่องจดหมายของคุณ'),
            ],
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () => Get.offAllNamed('/login'),
          child: const Text('กลับไปหน้าเข้าสู่ระบบ'),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: controller.resetForm,
          child: Text(
            'ส่งอีเมลอีกครั้ง',
            style: TextStyle(color: theme.colorScheme.secondary),
          ),
        ),
      ],
    );
  }
}
