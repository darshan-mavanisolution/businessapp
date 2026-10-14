import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/themes/app_colors.dart';
import '../../app/routes/app_routes.dart';
import '../../core/widgets/business_card.dart';
import '../../core/widgets/city_selector_sheet.dart';
import '../business_listing/business_controller.dart';
import '../filters/filter_controller.dart';
import '../home/home_controller.dart';

class BusinessSearchScreen extends GetView<BusinessController> {
  const BusinessSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filterController = Get.find<FilterController>();
    final homeController = Get.find<HomeController>();

    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final searchBg = isDark ? AppColors.darkSecondary : AppColors.lightSecondary;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Location and Filter Icon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios_new_rounded,
                            color: textPrimary, size: 20),
                        onPressed: () => Get.back(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => CitySelectorSheet.show(),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              color: isDark ? Colors.white : Colors.black,
                              size: 19,
                            ),
                            const SizedBox(width: 5),
                            Obx(() => Text(
                                  homeController.currentLocation.value,
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w600,
                                    color: textPrimary,
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // IconButton(
                  //   icon: Icon(Icons.tune_rounded, color: textPrimary, size: 22),
                  //   onPressed: () => Get.toNamed(AppRoutes.filter),
                  // ),
                ],
              ),
            ),

            // Search Bar Input Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: searchBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: border),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded, color: textSecondary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: controller.searchInputController,
                        autofocus: false,
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search here...',
                          hintStyle: TextStyle(
                            color: textSecondary.withValues(alpha: 0.8),
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    Obx(() {
                      if (controller.searchQuery.value.isNotEmpty) {
                        return GestureDetector(
                          onTap: () => controller.clearSearch(),
                          child: Icon(Icons.cancel_rounded,
                              color: textSecondary, size: 18),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Search Results List
            Expanded(
              child: Obx(() {
                final results = controller.searchResultsBusinesses;

                if (results.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 52,
                            color: textSecondary.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'No Matching Businesses',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Try changing filters, city, or clearing search query.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              controller.clearSearch();
                              filterController.resetAllActiveFilters();
                            },
                            child: Text(
                              'Reset All Filters',
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final b = results[index];
                    return BusinessCard(business: b);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
