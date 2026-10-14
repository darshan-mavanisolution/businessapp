import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/themes/app_colors.dart';
import '../../app/routes/app_routes.dart';
import '../../core/widgets/app_avatar.dart';
import '../authentication/auth_controller.dart';
import '../home/main_nav_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authController = Get.find<AuthController>();

    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final dividerColor = isDark ? AppColors.darkDivider : AppColors.lightDivider;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // User Info Card
              Obx(() {
                final user = authController.currentUser.value;
                final name = user?.name ?? 'Darshan Pambhar';
                final phone = user?.phoneNumber ?? '+91 98765 43210';
                final avatar = user?.avatarUrl ?? '';

                return InkWell(
                  onTap: () => Get.toNamed(AppRoutes.profileDetail),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        AppAvatar(
                          imageUrl: avatar,
                          initials: 'DP',
                          size: 58,
                          isCircle: true,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                phone,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: textSecondary,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 14),
              Divider(color: dividerColor),
              const SizedBox(height: 8),

              // 1. My Favorites
              _buildMenuItem(
                icon: Icons.favorite_border_rounded,
                title: 'My Favorites',
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                onTap: () {
                  final nav = Get.find<MainNavController>();
                  nav.changeTab(2);
                },
              ),

              // 2. Business Create
              _buildMenuItem(
                icon: Icons.add_business_outlined,
                title: 'Business Create',
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                onTap: () => Get.toNamed(AppRoutes.createBusiness),
              ),

              // 3. Edit Profile
              _buildMenuItem(
                icon: Icons.edit_outlined,
                title: 'Edit Profile',
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                onTap: () => Get.toNamed(AppRoutes.editProfile),
              ),

              // // 4. Notifications
              // _buildMenuItem(
              //   icon: Icons.notifications_none_rounded,
              //   title: 'Notifications',
              //   textPrimary: textPrimary,
              //   textSecondary: textSecondary,
              //   onTap: () => Get.toNamed(AppRoutes.notifications),
              // ),

              // 5. Terms & Conditions
              _buildMenuItem(
                icon: Icons.article_outlined,
                title: 'Terms & Conditions',
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                onTap: () => Get.toNamed(AppRoutes.termsPrivacy),
              ),

              // 6. Privacy Policy
              _buildMenuItem(
                icon: Icons.shield_outlined,
                title: 'Privacy Policy',
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                onTap: () => Get.toNamed(AppRoutes.termsPrivacy),
              ),

              // 7. Help & Support
              _buildMenuItem(
                icon: Icons.help_outline_rounded,
                title: 'Help & Support',
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                onTap: () => Get.toNamed(AppRoutes.helpSupport),
              ),

              const SizedBox(height: 6),

              // 9. Logout
              InkWell(
                onTap: () => _showLogoutDialog(context, authController),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.logout_rounded,
                        color: Color(0xFFEF4444),
                        size: 22,
                      ),
                      const SizedBox(width: 14),
                      const Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 4),

              // 10. Delete Account
              InkWell(
                onTap: () => _showDeleteAccountDialog(context, authController),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_forever_outlined,
                        color: Colors.red.withValues(alpha: 0.8),
                        size: 22,
                      ),
                      const SizedBox(width: 14),
                      Text(
                        'Delete Account',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          color: Colors.red.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 95),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required Color textPrimary,
    required Color textSecondary,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: textPrimary, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                  color: textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthController authController) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF111827);
    final textSecondary = isDark ? const Color(0xFFA1A1AA) : const Color(0xFF6B7280);
    final cancelBorder = isDark ? const Color(0xFF3F3F46) : const Color(0xFFD1D5DB);
    final cancelText = isDark ? Colors.white : const Color(0xFF374151);

    Get.dialog(
      Dialog(
        backgroundColor: dialogBg,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Log Out',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to log out of Rotaract Club?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: cancelBorder, width: 1.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: cancelText,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          authController.logout();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, AuthController authController) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF111827);
    final textSecondary = isDark ? const Color(0xFFA1A1AA) : const Color(0xFF6B7280);
    final cancelBorder = isDark ? const Color(0xFF3F3F46) : const Color(0xFFD1D5DB);
    final cancelText = isDark ? Colors.white : const Color(0xFF374151);

    Get.dialog(
      Dialog(
        backgroundColor: dialogBg,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Delete Account',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'This action is irreversible and will permanently delete your profile and saved favorites.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: cancelBorder, width: 1.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: cancelText,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          authController.deleteAccount();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text(
                          'Delete',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
