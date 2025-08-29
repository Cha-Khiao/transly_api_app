import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:transly_api_app/controllers/auth_controller.dart';
import 'package:transly_api_app/main.dart';
import 'package:transly_api_app/routes/app_routes.dart';
import 'package:transly_api_app/screens/splash_screen.dart';

class RegisterController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final AuthController authController = Get.find<AuthController>();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late TextEditingController emailController;
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;

  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;
  final RxBool isLoading = false.obs;
  final RxBool acceptTerms = false.obs;

  late AnimationController animationController;
  late Animation<double> formFadeAnimation;
  late Animation<Offset> formSlideAnimation;
  late Animation<double> headerFadeAnimation;
  late Animation<Offset> headerSlideAnimation;

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();

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
    firstNameController.dispose();
    lastNameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    animationController.dispose();
    super.onClose();
  }

  Future<void> handleRegister() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!formKey.currentState!.validate()) return;

    if (!acceptTerms.value) {
      Get.snackbar(
        'ข้อผิดพลาด',
        'กรุณายอมรับเงื่อนไขการใช้งานก่อนดำเนินการต่อ',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.theme.colorScheme.error,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
      );
      return;
    }

    isLoading.value = true;
    try {
      final success = await authController.register(
        name: emailController.text.trim(),
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        password: passwordController.text,
      );

      if (success) {
        Get.offNamed(AppRoutes.login);
      }
    } finally {
      isLoading.value = false;
    }
  }

  void showTermsBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.only(top: 16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text("ข้อกำหนดและเงื่อนไข", style: textTheme.titleLarge),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Text(
                  "ยินดีต้อนรับสู่แอปพลิเคชันของเรา\n\n"
                  "1. การใช้งาน: ผู้ใช้บริการตกลงที่จะใช้แอปพลิเคชันนี้เพื่อวัตถุประสงค์ที่ถูกกฎหมายและไม่ละเมิดสิทธิ์ของผู้อื่น\n\n"
                  "2. ข้อมูลส่วนบุคคล: เราจะเก็บรวบรวมข้อมูลของท่านตามนโยบายความเป็นส่วนตัว เพื่อใช้ในการปรับปรุงการให้บริการ ท่านมีสิทธิ์ในการเข้าถึงและแก้ไขข้อมูลของท่าน\n\n"
                  "3. ความรับผิดชอบ: ข้อมูลทางการเงินที่ท่านบันทึกเป็นความรับผิดชอบของท่านแต่เพียงผู้เดียว ทางผู้พัฒนาจะไม่รับผิดชอบต่อความเสียหายใดๆ ที่เกิดจากการใช้ข้อมูลดังกล่าว\n\n"
                  "4. การเปลี่ยนแปลงบริการ: เราขอสงวนสิทธิ์ในการเปลี่ยนแปลงหรือยกเลิกบริการส่วนใดส่วนหนึ่งได้ตลอดเวลาโดยไม่ต้องแจ้งให้ทราบล่วงหน้า\n\n"
                  "การกด 'สร้างบัญชี' ถือว่าท่านได้อ่านและเข้าใจเงื่อนไขทั้งหมดนี้แล้ว",
                  style: textTheme.bodyMedium,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text("ฉันเข้าใจแล้ว"),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RegisterController());
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

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
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40), // Space for AppBar
                  _buildHeader(textTheme, controller),
                  const SizedBox(height: 32),
                  _buildGlassmorphismCard(controller, context),
                  const SizedBox(height: 24),
                  _buildLoginLink(textTheme, theme, controller),
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
          bottom: -200,
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

  Widget _buildHeader(TextTheme textTheme, RegisterController controller) {
    return FadeTransition(
      opacity: controller.headerFadeAnimation,
      child: SlideTransition(
        position: controller.headerSlideAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'สร้างบัญชีใหม่',
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'กรอกข้อมูลของคุณเพื่อเริ่มต้นใช้งาน',
              style: textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassmorphismCard(
    RegisterController controller,
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
              child: _buildForm(controller, context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(RegisterController controller, BuildContext context) {
    return Form(
      key: controller.formKey,
      child: Column(
        children: [
          _buildEmailField(controller),
          const SizedBox(height: 20),
          _buildNameFields(controller),
          const SizedBox(height: 20),
          _buildPasswordField(controller),
          const SizedBox(height: 20),
          _buildConfirmPasswordField(controller),
          const SizedBox(height: 24),
          _buildTermsAndConditions(controller, context),
          const SizedBox(height: 32),
          _buildRegisterButton(controller),
        ],
      ),
    );
  }

  Widget _buildEmailField(RegisterController controller) {
    return TextFormField(
      controller: controller.emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        labelText: 'อีเมล',
        prefixIcon: Icon(Icons.alternate_email_rounded),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'กรุณากรอกอีเมล';
        if (!GetUtils.isEmail(value)) return 'รูปแบบอีเมลไม่ถูกต้อง';
        return null;
      },
    );
  }

  Widget _buildNameFields(RegisterController controller) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: controller.firstNameController,
            decoration: const InputDecoration(labelText: 'ชื่อ'),
            validator: (value) => (value == null || value.trim().isEmpty)
                ? 'กรุณากรอกชื่อ'
                : null,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            controller: controller.lastNameController,
            decoration: const InputDecoration(labelText: 'นามสกุล'),
            validator: (value) => (value == null || value.trim().isEmpty)
                ? 'กรุณากรอกนามสกุล'
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(RegisterController controller) {
    return Obx(
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
          if (value == null || value.isEmpty) return 'กรุณากรอกรหัสผ่าน';
          if (value.length < 6) return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
          return null;
        },
      ),
    );
  }

  Widget _buildConfirmPasswordField(RegisterController controller) {
    return Obx(
      () => TextFormField(
        controller: controller.confirmPasswordController,
        obscureText: controller.obscureConfirmPassword.value,
        decoration: InputDecoration(
          labelText: 'ยืนยันรหัสผ่าน',
          prefixIcon: const Icon(Icons.lock_outline_rounded),
          suffixIcon: IconButton(
            icon: Icon(
              controller.obscureConfirmPassword.value
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
            onPressed: () => controller.obscureConfirmPassword.toggle(),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'กรุณายืนยันรหัสผ่าน';
          if (value != controller.passwordController.text) {
            return 'รหัสผ่านไม่ตรงกัน';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildTermsAndConditions(
    RegisterController controller,
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Obx(
          () => Checkbox(
            value: controller.acceptTerms.value,
            onChanged: (val) => controller.acceptTerms.value = val!,
            activeColor: theme.colorScheme.primary,
            checkColor: theme.colorScheme.onPrimary,
          ),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: theme.textTheme.bodyMedium,
              children: [
                const TextSpan(text: 'ฉันได้อ่านและยอมรับ '),
                TextSpan(
                  text: 'ข้อกำหนดและเงื่อนไข',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => controller.showTermsBottomSheet(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton(RegisterController controller) {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: controller.isLoading.value
              ? null
              : controller.handleRegister,
          child: controller.isLoading.value
              ? const SizedBox(
                  height: 24,
                  width: 80,
                  child: LoadingDots(color: Colors.white),
                )
              : const Text('สร้างบัญชี'),
        ),
      ),
    );
  }

  Widget _buildLoginLink(
    TextTheme textTheme,
    ThemeData theme,
    RegisterController controller,
  ) {
    return FadeTransition(
      opacity: controller.formFadeAnimation,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('มีบัญชีอยู่แล้ว?', style: textTheme.bodyMedium),
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'เข้าสู่ระบบที่นี่',
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
