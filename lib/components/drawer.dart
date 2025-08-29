import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:transly_api_app/controllers/auth_controller.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [_buildDrawerHeader(context), _buildDrawerItems(context)],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final authController = Get.find<AuthController>();

    return Obx(() {
      final user = authController.currentUser;
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
        decoration: BoxDecoration(color: theme.colorScheme.primary),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: Colors.white,
              child: ClipOval(
                child: Image.asset(
                  'assets/images/comsci_logo.png',
                  fit: BoxFit.cover,
                  width: 64,
                  height: 64,
                  errorBuilder: (context, error, stackTrace) {
                    if (user?.fullName.isNotEmpty ?? false) {
                      return Center(
                        child: Text(
                          user!.fullName[0].toUpperCase(),
                          style: textTheme.headlineMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }
                    return Icon(
                      Icons.person_rounded,
                      color: theme.colorScheme.primary,
                      size: 32,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              user?.fullName ?? "Guest User",
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              user?.name ?? "กรุณาเข้าสู่ระบบ",
              style: textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onPrimary.withOpacity(0.8),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildDrawerItems(BuildContext context) {
    final String currentRoute = Get.currentRoute;

    void navigateTo(String route) {
      Get.back();
      if (currentRoute != route) {
        Get.offAllNamed(route);
      }
    }

    return Animate(
      effects: const [FadeEffect(), SlideEffect()],
      child: Column(
        children: [
          const SizedBox(height: 8),
          _buildDrawerItem(
            title: 'หน้าหลัก',
            icon: Icons.home_rounded,
            isSelected: currentRoute == '/home',
            onTap: () => navigateTo('/home'),
          ),
          _buildDrawerItem(
            title: 'รายการทั้งหมด',
            icon: Icons.receipt_long_rounded,
            isSelected: currentRoute == '/transactions',
            onTap: () => navigateTo('/transactions'),
          ),
          _buildDrawerItem(
            title: 'โปรไฟล์',
            icon: Icons.person_rounded,
            isSelected: currentRoute == '/profile',
            onTap: () => navigateTo('/profile'),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(height: 24, thickness: 1),
          ),
          _buildDrawerItem(
            title: 'ออกจากระบบ',
            icon: Icons.logout_rounded,
            color: Theme.of(context).colorScheme.error,
            onTap: () {
              Get.back();
              Get.find<AuthController>().confirmLogout();
            },
          ),
        ],
      ).animate().slideX(begin: -0.5).fadeIn(delay: 200.ms, duration: 400.ms),
    );
  }

  Widget _buildDrawerItem({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    bool isSelected = false,
    Color? color,
  }) {
    final theme = Get.theme;

    final Color itemColor =
        color ??
        (isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurfaceVariant);
    final Color tileColor = isSelected
        ? theme.colorScheme.primary.withOpacity(0.1)
        : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: tileColor,
          borderRadius: BorderRadius.circular(50),
        ),
        child: ListTile(
          leading: Icon(icon, color: itemColor),
          title: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: itemColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: onTap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      ),
    );
  }
}