import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:transly_api_app/components/drawer.dart';
import 'package:transly_api_app/components/user_profile_card.dart';
import 'package:transly_api_app/controllers/auth_controller.dart';

class ProfileController extends GetxController {
  final AuthController authController = Get.find<AuthController>();

  void logout() {
    authController.confirmLogout();
  }

  void changeTabIndex(int index) {
    if (index == 2) return;
    switch (index) {
      case 0:
        Get.offAllNamed('/home');
        break;
      case 1:
        Get.offAllNamed('/transactions');
        break;
    }
  }

  void showFeatureNotAvailableDialog(String featureName) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(featureName),
        content: const Text('ขออภัย, ฟีเจอร์นี้ยังไม่พร้อมใช้งาน'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('ตกลง')),
        ],
      ),
    );
  }

  void showHelpDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('ช่วยเหลือและสนับสนุน'),
        content: const SingleChildScrollView(
          child: Text(
            'หากพบปัญหาการใช้งานหรือต้องการสอบถามข้อมูลเพิ่มเติม กรุณาติดต่อทีมงานได้ที่ support@example.com',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('ปิด')),
        ],
      ),
    );
  }

  void showAppAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Finance App',
      applicationVersion: '1.0.0',
      applicationIcon: Image.asset(
        'assets/images/comsci_logo.png',
        height: 60,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.wallet_rounded,
            size: 60,
            color: Get.theme.primaryColor,
          );
        },
      ),
      children: [
        const SizedBox(height: 16),
        const Text('แอปพลิเคชันสำหรับจัดการรายรับรายจ่ายส่วนตัว'),
      ],
    );
  }
}

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ProfileController());
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('โปรไฟล์ของฉัน'),
            pinned: true,
            centerTitle: true,
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            titleTextStyle: theme.appBarTheme.titleTextStyle?.copyWith(
              color: theme.colorScheme.onPrimary,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                      const UserProfileCard(),
                      const SizedBox(height: 16),
                      _buildMenuItems(context),
                      const SizedBox(height: 24),
                      _buildLogoutButton(context),
                    ]
                    .animate(interval: 80.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.1),
              ),
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    return Card(
      child: Column(
        children: [
          _CustomListTile(
            icon: Icons.person_outline_rounded,
            title: 'แก้ไขข้อมูลส่วนตัว',
            onTap: () =>
                controller.showFeatureNotAvailableDialog('แก้ไขข้อมูลส่วนตัว'),
          ),
          _CustomListTile(
            icon: Icons.lock_outline_rounded,
            title: 'เปลี่ยนรหัสผ่าน',
            onTap: () => Get.toNamed('/forget-password'),
          ),
          _CustomListTile(
            icon: Icons.notifications_none_rounded,
            title: 'การแจ้งเตือน',
            onTap: () =>
                controller.showFeatureNotAvailableDialog('การแจ้งเตือน'),
          ),
          const Divider(height: 1, thickness: 1),
          _CustomListTile(
            icon: Icons.help_outline_rounded,
            title: 'ช่วยเหลือและสนับสนุน',
            onTap: controller.showHelpDialog,
          ),
          _CustomListTile(
            icon: Icons.info_outline_rounded,
            title: 'เกี่ยวกับแอปพลิเคชัน',
            onTap: () => controller.showAppAboutDialog(context),
            hasDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: controller.logout,
        icon: const Icon(Icons.logout_rounded),
        label: const Text('ออกจากระบบ'),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.error.withOpacity(0.1),
          foregroundColor: theme.colorScheme.error,
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return NavigationBar(
      selectedIndex: 2,
      onDestinationSelected: controller.changeTabIndex,
      indicatorShape: const StadiumBorder(),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'หน้าหลัก',
        ),
        NavigationDestination(
          icon: Icon(Icons.receipt_long_outlined),
          selectedIcon: Icon(Icons.receipt_long_rounded),
          label: 'รายการ',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(Icons.person_rounded),
          label: 'โปรไฟล์',
        ),
      ],
    );
  }
}

class _CustomListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool hasDivider;

  const _CustomListTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.hasDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 4.0,
              ),
              child: ListTile(
                leading: Icon(icon, color: theme.colorScheme.primary),
                title: Text(title, style: theme.textTheme.titleMedium),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: theme.textTheme.bodySmall?.color,
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            if (hasDivider)
              const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
          ],
        ),
      ),
    );
  }
}
