import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:transly_api_app/controllers/auth_controller.dart';
import 'package:transly_api_app/main.dart';
import 'package:transly_api_app/routes/app_routes.dart';

class SplashScreenController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> logoScale;
  late Animation<double> logoOpacity;
  late Animation<double> auroraOpacity;
  late Animation<double> textOpacity;
  late Animation<Offset> textSlide;
  late Animation<double> loaderOpacity;

  @override
  void onInit() {
    super.onInit();
    _initializeAnimations();
    _startSplashSequence();
  }

  void _initializeAnimations() {
    animationController = AnimationController(
      duration: const Duration(milliseconds: 2800),
      vsync: this,
    );

    logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );
    logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    auroraOpacity =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.5), weight: 50),
          TweenSequenceItem(tween: Tween(begin: 0.5, end: 0.3), weight: 50),
        ]).animate(
          CurvedAnimation(
            parent: animationController,
            curve: const Interval(0.2, 1.0, curve: Curves.easeInOut),
          ),
        );

    textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeInOut),
      ),
    );
    textSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: animationController,
            curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    loaderOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.8, 1.0, curve: Curves.easeIn),
      ),
    );
  }

  Future<void> _startSplashSequence() async {
    animationController.forward();

    await Future.delayed(const Duration(milliseconds: 7000));
    _checkUserStatus();
  }

  Future<void> _checkUserStatus() async {
    final authController = Get.find<AuthController>();
    if (authController.isLoggedIn.value) {
      Get.offAllNamed(AppRoutes.home);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SplashScreenController());
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      body: AnimatedBuilder(
        animation: controller.animationController,
        builder: (context, child) {
          return Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                ),
              ),

              _buildAnimatedAurora(controller, theme),

              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    _buildAnimatedLogo(controller),
                    const SizedBox(height: 32),
                    _buildAnimatedText(controller, textTheme),
                    const Spacer(),
                    _buildAnimatedLoader(controller, textTheme),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAnimatedLogo(SplashScreenController controller) {
    return ScaleTransition(
      scale: controller.logoScale,
      child: FadeTransition(
        opacity: controller.logoOpacity,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 25,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/comsci_logo.png',
            height: 120,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.school_rounded,
                size: 100,
                color: Theme.of(context).primaryColor,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedText(
    SplashScreenController controller,
    TextTheme textTheme,
  ) {
    return FadeTransition(
      opacity: controller.textOpacity,
      child: SlideTransition(
        position: controller.textSlide,
        child: Column(
          children: [
            Text(
              'Transly',
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: Colors.black.withOpacity(0.3),
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ComSci • SSKRU',
              style: textTheme.bodyLarge?.copyWith(
                fontSize: 18,
                color: Colors.white.withOpacity(0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedLoader(
    SplashScreenController controller,
    TextTheme textTheme,
  ) {
    return FadeTransition(
      opacity: controller.loaderOpacity,
      child: Column(
        children: [
          const SizedBox(height: 22, child: LoadingDots()),
          const SizedBox(height: 16),
          Text(
            'กำลังเริ่มต้น...',
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedAurora(
    SplashScreenController controller,
    ThemeData theme,
  ) {
    return Positioned.fill(
      child: Opacity(
        opacity: controller.auroraOpacity.value,
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                theme.colorScheme.secondary.withOpacity(0.3),
                Colors.transparent,
              ],
              center: const Alignment(0, -1.2),
              radius: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

class LoadingDots extends StatefulWidget {
  final Color color;
  const LoadingDots({super.key, this.color = Colors.white});

  @override
  State<LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildDot(int index) {
    final animation = Tween(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          0.1 * index,
          0.5 + 0.1 * index,
          curve: Curves.easeInOutSine,
        ),
      ),
    );
    return FadeTransition(
      opacity: animation,
      child: CircleAvatar(radius: 4, backgroundColor: widget.color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: _buildDot(index),
        );
      }),
    );
  }
}
