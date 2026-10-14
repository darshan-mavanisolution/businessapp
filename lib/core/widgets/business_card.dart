import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/business_model.dart';
import '../../app/themes/app_colors.dart';
import '../../features/favorites/favorites_controller.dart';
import '../../features/business_listing/business_controller.dart';
import '../../app/routes/app_routes.dart';
import '../utils/app_launcher.dart';
import 'app_avatar.dart';

class BusinessCard extends StatelessWidget {
  final BusinessModel business;
  final VoidCallback? onTap;

  const BusinessCard({
    super.key,
    required this.business,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final favController = Get.find<FavoritesController>();

    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final callBtnBg = AppColors.rotaryBlue;
    final callIconColor = Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (onTap != null) {
              onTap!();
            } else {
              Get.find<BusinessController>().selectBusiness(business);
              print("Business Id------ ${business.id}");
              Get.toNamed(
                AppRoutes.businessDetail,
                arguments: {
                  'id': business.id,
                  // 'business': business,
                },
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar / Image
                AppAvatar(
                  imageUrl: business.imageUrl,
                  initials: business.avatarInitials,
                  size: 56,
                  isCircle: true,
                ),
                const SizedBox(width: 12),

                // Business Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        business.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        business.specialty.isNotEmpty ? business.specialty : business.category,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Distance & Rating Row
                      // if (business.distance.isNotEmpty || business.rating > 0) ...[
                      //   const SizedBox(height: 5),
                      //   Row(
                      //     children: [
                      //       if (business.distance.isNotEmpty) ...[
                      //         Icon(
                      //           Icons.near_me_outlined,
                      //           size: 12,
                      //           color: textSecondary,
                      //         ),
                      //         const SizedBox(width: 3),
                      //         Text(
                      //           business.distance,
                      //           style: TextStyle(
                      //             fontSize: 11.5,
                      //             color: textSecondary,
                      //             fontWeight: FontWeight.w500,
                      //           ),
                      //         ),
                      //         if (business.rating > 0) const SizedBox(width: 8),
                      //       ],
                      //       if (business.rating > 0) ...[
                      //         const Icon(
                      //           Icons.star_rounded,
                      //           size: 14,
                      //           color: Color(0xFFFBBF24),
                      //         ),
                      //         const SizedBox(width: 2),
                      //         Text(
                      //           business.rating.toStringAsFixed(1),
                      //           style: TextStyle(
                      //             fontSize: 11.5,
                      //             fontWeight: FontWeight.w600,
                      //             color: textPrimary,
                      //           ),
                      //         ),
                      //         if (business.reviewCount > 0)
                      //           Text(
                      //             ' (${business.reviewCount})',
                      //             style: TextStyle(
                      //               fontSize: 11,
                      //               color: textSecondary,
                      //             ),
                      //           ),
                      //       ],
                      //     ],
                      //   ),
                      // ],
                      // Location City/Area Row
                      if (business.city.isNotEmpty || business.address.isNotEmpty || business.state.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 13,
                              color: textSecondary,
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                business.city.isNotEmpty && business.state.isNotEmpty
                                    ? '${business.city}, ${business.state}'
                                    : (business.city.isNotEmpty
                                        ? business.city
                                        : (business.address.isNotEmpty ? business.address : 'Gujarat')),
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Call and Favorite Actions on the right
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Call Button
                    InkWell(
                      onTap: () => AppLauncher.makePhoneCall(business.phoneNumber),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: callBtnBg,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.phone_rounded,
                          color: callIconColor,
                          size: 17,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Favorite Heart Button
                    Obx(() {
                      final isFav = favController.isFavorite(business.id);
                      return InkWell(
                        onTap: () => favController.toggleFavorite(
                          business.id,
                          businessName: business.name,
                          business: business,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: isFav ? AppColors.rotaractPink : textSecondary,
                            size: 20,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
