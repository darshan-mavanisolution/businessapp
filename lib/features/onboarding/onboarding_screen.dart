import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/themes/app_colors.dart';
import 'onboarding_controller.dart';
import 'widgets/onboarding_graphic.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnboardingController());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final btnText = isDark ? Colors.black : Colors.white;
    final badgeBg = isDark ? const Color(0xFF18181B) : const Color(0xFFF4F4F5);
    final badgeBorder = isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar: App Brand & Skip Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                // crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // App Brand Chip
                  // Container(
                  //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  //   decoration: BoxDecoration(
                  //     color: badgeBg,
                  //     borderRadius: BorderRadius.circular(20),
                  //     border: Border.all(color: badgeBorder, width: 1),
                  //   ),
                  //   child: Row(
                  //     mainAxisSize: MainAxisSize.min,
                  //     children: [
                  //       Container(
                  //         width: 8,
                  //         height: 8,
                  //         decoration: BoxDecoration(
                  //           color: isDark ? Colors.white : Colors.black,
                  //           shape: BoxShape.circle,
                  //         ),
                  //       ),
                  //       const SizedBox(width: 7),
                  //       // Text(
                  //       //   'Rotaract Clubs',
                  //       //   style: TextStyle(
                  //       //     fontSize: 12,
                  //       //     fontWeight: FontWeight.w700,
                  //       //     letterSpacing: -0.2,
                  //       //     color: textPrimary,
                  //       //   ),
                  //       // ),
                  //     ],
                  //   ),
                  // ),

                  // Skip Button
                  Obx(() {
                    final isLastPage = controller.currentPage.value == controller.items.length - 1;
                    return AnimatedOpacity(
                      opacity: isLastPage ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: IgnorePointer(
                        ignoring: isLastPage,
                        child: TextButton(
                          onPressed: controller.skip,
                          style: TextButton.styleFrom(
                            foregroundColor: textSecondary,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            'Skip',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: textSecondary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            // PageView Content
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                itemCount: controller.items.length,
                onPageChanged: controller.onPageChanged,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final item = controller.items[index];

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),

                        // Custom Vector Graphic per Slide
                        OnboardingGraphic(
                          pageIndex: index,
                          isDark: isDark,
                        ),

                        const SizedBox(height: 18),

                        // Category Tag Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: badgeBorder, width: 1),
                          ),
                          child: Text(
                            item.badge,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: isDark ? const Color(0xFFA1A1AA) : const Color(0xFF52525B),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Title
                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                            height: 1.25,
                            color: textPrimary,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Description
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            item.description,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 1.45,
                              color: textSecondary,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Navigation Area
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Obx(() {
                final isLast = controller.currentPage.value == controller.items.length - 1;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Dot Page Indicators
                    Row(
                      children: List.generate(
                        controller.items.length,
                        (dotIndex) {
                          final isSelected = controller.currentPage.value == dotIndex;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 280),
                            curve: Curves.easeOutCubic,
                            margin: const EdgeInsets.only(right: 6),
                            height: 7,
                            width: isSelected ? 26 : 7,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.rotaryBlue
                                  : (isDark
                                      ? Colors.white.withValues(alpha: 0.2)
                                      : Colors.black.withValues(alpha: 0.15)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        },
                      ),
                    ),

                    // Next / Get Started Action Button
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      child: ElevatedButton(
                        onPressed: controller.nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.rotaryBlue,
                          foregroundColor: btnText,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                            horizontal: isLast ? 24 : 20,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isLast ? 'Get Started' : 'Next',
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 17,
                              color: btnText,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
