import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/themes/app_colors.dart';
import '../../features/home/home_controller.dart';
import '../../features/filters/filter_controller.dart';
import '../../features/business_listing/business_controller.dart';

class CitySelectorSheet extends StatelessWidget {
  const CitySelectorSheet({super.key});

  static void show() {
    Get.bottomSheet(
      const CitySelectorSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final homeController = Get.find<HomeController>();
    final filterController = Get.find<FilterController>();
    final businessController = Get.find<BusinessController>();

    final bg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Your City',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close_rounded, color: textSecondary),
                onPressed: () => Get.back(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...homeController.availableCities.map((cityLocation) {
            final cityName = cityLocation.split(',').first.trim();
            return Obx(() {
              final isSelected = homeController.currentLocation.value.startsWith(cityName);
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                leading: Icon(
                  Icons.location_city_rounded,
                  color: isSelected
                      ? (isDark ? Colors.white : Colors.black)
                      : textSecondary,
                ),
                title: Text(
                  cityLocation,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? (isDark ? Colors.white : Colors.black)
                        : textPrimary,
                  ),
                ),
                trailing: isSelected
                    ? Icon(
                        Icons.check_circle_rounded,
                        color: isDark ? Colors.white : Colors.black,
                      )
                    : null,
                onTap: () {
                  homeController.changeLocation(cityLocation);
                  filterController.setCity(cityName);
                  businessController.selectCity(cityName);
                  Get.back();
                },
              );
            });
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
