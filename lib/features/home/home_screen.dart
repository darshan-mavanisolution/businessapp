import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/themes/app_colors.dart';
import '../../app/routes/app_routes.dart';
import '../../core/widgets/app_avatar.dart';
import '../../core/widgets/category_illustration.dart';
import '../authentication/auth_controller.dart';
import '../business_listing/business_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final businessController = Get.find<BusinessController>();
    final authController = Get.find<AuthController>();

    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final searchBg = isDark ? AppColors.darkSecondary : const Color(0xFFF4F4F6);
    final border = isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB);
    final arrowBtnBg = isDark ? const Color(0xFF222224) : const Color(0xFFF3F4F6);
    final arrowIconColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Background soft bottom wave decoration matching reference
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 160,
            child: CustomPaint(
              painter: HomeWaveBackgroundPainter(isDark: isDark),
            ),
          ),

          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),

                  // Top User Profile Bar & Notification Bell
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // User Info
                      Obx(() {
                        final user = authController.currentUser.value;
                        final name = user?.name ?? 'Darshan Pambhar';
                        final phone = user?.phoneNumber ?? '+91 98765 43210';
                        final avatar = user?.avatarUrl ?? '';

                        return InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => Get.toNamed(AppRoutes.profileDetail),
                          child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark ? const Color(0xFF27272A) : const Color(0xFFE5E7EB),
                                  width: 2,
                                ),
                              ),
                              child: AppAvatar(
                                imageUrl: avatar,
                                initials: 'DP',
                                size: 50,
                                isCircle: true,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: textPrimary,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  phone,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                      }),

                      // // Rotary & Rotaract Brand Logos
                      // Row(
                      //   children: [
                      //     Image.asset(
                      //       'assets/image/rotary_logo.png',
                      //       height: 28,
                      //       fit: BoxFit.contain,
                      //     ),
                      //     const SizedBox(width: 8),
                      //     Image.asset(
                      //       'assets/image/rotaract_logo.png',
                      //       height: 28,
                      //       fit: BoxFit.contain,
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Pill Search Bar
                  GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.search),
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: searchBg,
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(
                          color: isDark ? const Color(0xFF27272A) : const Color(0xFFE5E7EB),
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search_rounded,
                            color: textSecondary,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Search for doctors, restaurants, hotels...',
                              style: TextStyle(
                                fontSize: 13.5,
                                color: textSecondary.withValues(alpha: 0.85),
                                fontWeight: FontWeight.w400,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Icon(
                          //   Icons.mic_none_rounded,
                          //   color: textSecondary,
                          //   size: 21,
                          // ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // 3-Column Categories Grid (Show All Categories, No "More" Button)
                  Obx(() {
                    final allCategories = businessController.categories;
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: allCategories.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 11,
                        childAspectRatio: 0.68,
                      ),
                      itemBuilder: (context, index) {
                        final cat = allCategories[index];
                        final circleBg = isDark ? cat.bgCircleDark : cat.bgCircleLight;

                      return GestureDetector(
                        onTap: () {
                          businessController.selectCategory(cat.name);
                          Get.toNamed(AppRoutes.businessListing);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: border, width: 1),
                            boxShadow: isDark
                                ? []
                                : [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.035),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                          ),
                          padding: const EdgeInsets.fromLTRB(10, 14, 10, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top Circular Illustration Container
                              Center(
                                child: Container(
                                  width: 78,
                                  height: 78,
                                  decoration: BoxDecoration(
                                    color: circleBg,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(5),
                                  child: Center(
                                    child: CategoryIllustration(
                                      categoryId: cat.id,
                                      imageUrl: cat.imageUrl,
                                      size: 68,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Category Title
                              Text(
                                cat.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: textPrimary,
                                  letterSpacing: -0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),

                              const SizedBox(height: 3),

                              // Subtitle & Arrow Circle Button Row
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    // Subtitle
                                    Expanded(
                                      child: Text(
                                        cat.subtitle,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w400,
                                          color: textSecondary,
                                          height: 1.25,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 4),

                                    // Circular Right Arrow Button
                                    Container(
                                      width: 25,
                                      height: 25,
                                      decoration: BoxDecoration(
                                        color: arrowBtnBg,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.chevron_right_rounded,
                                        size: 16,
                                        color: arrowIconColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),

                  const SizedBox(height: 95),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeWaveBackgroundPainter extends CustomPainter {
  final bool isDark;
  HomeWaveBackgroundPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final wave1Paint = Paint()
      ..color = isDark
          ? const Color(0xFF141416).withValues(alpha: 0.5)
          : const Color(0xFFF3F4F6).withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    final wave2Paint = Paint()
      ..color = isDark
          ? const Color(0xFF0D0D0F).withValues(alpha: 0.4)
          : const Color(0xFFEBECEF).withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    // Wave 1
    final path1 = Path();
    path1.moveTo(0, size.height * 0.45);
    path1.quadraticBezierTo(
      size.width * 0.35,
      size.height * 0.15,
      size.width * 0.7,
      size.height * 0.5,
    );
    path1.quadraticBezierTo(
      size.width * 0.88,
      size.height * 0.7,
      size.width,
      size.height * 0.55,
    );
    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();
    canvas.drawPath(path1, wave1Paint);

    // Wave 2
    final path2 = Path();
    path2.moveTo(0, size.height * 0.65);
    path2.quadraticBezierTo(
      size.width * 0.45,
      size.height * 0.4,
      size.width,
      size.height * 0.75,
    );
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, wave2Paint);
  }

  @override
  bool shouldRepaint(covariant HomeWaveBackgroundPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
