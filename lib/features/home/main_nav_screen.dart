import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/themes/app_colors.dart';
import 'home_screen.dart';
import '../city_sector/city_selection_screen.dart';
import '../favorites/favorites_screen.dart';
import '../profile/profile_screen.dart';

class MainNavController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void changeTab(int index) {
    currentIndex.value = index;
  }
}

class MainNavScreen extends StatelessWidget {
  const MainNavScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MainNavController());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;

    // Rotary & Rotaract Brand Theme Colors
    final activeColor = AppColors.rotaryBlue;
    final inactiveColor = AppColors.lightTextSecondary;

    final screens = const [
      HomeScreen(),
      CitySelectionScreen(),
      FavoritesScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: bg,
      extendBody: true,
      body: Obx(() => IndexedStack(
            index: controller.currentIndex.value,
            children: screens,
          )),
      bottomNavigationBar: SafeArea(
        top: false,
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Container(
                  height: 66,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(34),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(34),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withValues(alpha: 0.95),
                              Colors.white.withValues(alpha: 0.88),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(34),
                          border: Border.all(
                            color: AppColors.lightBorder,
                            width: 1.2,
                          ),
                        ),
                        child: Obx(() {
                          final current = controller.currentIndex.value;
                          return Row(
                            children: [
                              Expanded(
                                child: _buildFloatingNavItem(
                                  index: 0,
                                  currentIndex: current,
                                  icon: Icons.home_rounded,
                                  label: 'Home',
                                  activeColor: activeColor,
                                  inactiveColor: inactiveColor,
                                  isDark: isDark,
                                  onTap: () => controller.changeTab(0),
                                ),
                              ),
                              Expanded(
                                child: _buildFloatingNavItem(
                                  index: 1,
                                  currentIndex: current,
                                  icon: Icons.location_city_rounded,
                                  label: 'Cities',
                                  activeColor: activeColor,
                                  inactiveColor: inactiveColor,
                                  isDark: isDark,
                                  onTap: () => controller.changeTab(1),
                                ),
                              ),
                              Expanded(
                                child: _buildFloatingNavItem(
                                  index: 2,
                                  currentIndex: current,
                                  icon: Icons.favorite_rounded,
                                  inactiveIcon: Icons.favorite_border_rounded,
                                  label: 'Favorites',
                                  activeColor: AppColors.rotaractPink,
                                  inactiveColor: inactiveColor,
                                  isDark: isDark,
                                  onTap: () => controller.changeTab(2),
                                ),
                              ),
                              Expanded(
                                child: _buildFloatingNavItem(
                                  index: 3,
                                  currentIndex: current,
                                  icon: Icons.person_rounded,
                                  inactiveIcon: Icons.person_outline_rounded,
                                  label: 'Profile',
                                  activeColor: activeColor,
                                  inactiveColor: inactiveColor,
                                  isDark: isDark,
                                  onTap: () => controller.changeTab(3),
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
    );
  }

  Widget _buildFloatingNavItem({
    required int index,
    required int currentIndex,
    required IconData icon,
    IconData? inactiveIcon,
    required String label,
    required Color activeColor,
    required Color inactiveColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final isSelected = index == currentIndex;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: 66,
          height: 48,
          decoration: BoxDecoration(
            color: isSelected
                ? (index == 2
                    ? AppColors.rotaractPinkLight
                    : const Color(0xFFEEF4FC))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
            border: isSelected
                ? Border.all(
                    color: index == 2
                        ? AppColors.rotaractPinkBorder
                        : AppColors.rotaryBlue.withValues(alpha: 0.18),
                    width: 1,
                  )
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 5,
                      offset: const Offset(0, 1.5),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? icon : (inactiveIcon ?? icon),
                color: isSelected ? activeColor : inactiveColor,
                size: 20,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? activeColor : inactiveColor,
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
