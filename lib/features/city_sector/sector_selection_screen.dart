import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/themes/app_colors.dart';
import '../../app/routes/app_routes.dart';
import 'city_sector_controller.dart';

class SectorSelectionScreen extends StatefulWidget {
  const SectorSelectionScreen({super.key});

  @override
  State<SectorSelectionScreen> createState() => _SectorSelectionScreenState();
}

class _SectorSelectionScreenState extends State<SectorSelectionScreen> {
  @override
  void initState() {
    super.initState();
    final controller = Get.find<CitySectorController>();
    if (controller.allSectors.isEmpty && !controller.isLoadingSectors.value) {
      controller.fetchCitySectors(city: controller.selectedCity.value.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = Get.find<CitySectorController>();

    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final border = isDark ? AppColors.darkBorder : const Color(0xFFE9EDF2);
    final selectedBorder = isDark ? Colors.white : const Color(0xFF111111);
    final cityPillBg = isDark ? AppColors.darkSecondary : const Color(0xFFF5F7FA);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: RefreshIndicator(
          color: isDark ? Colors.white : Colors.black,
          backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          onRefresh: () async {
            await controller.fetchCitySectors(city: controller.selectedCity.value.name);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Bar with Back Button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: textPrimary,
                        size: 20,
                      ),
                      onPressed: () => Get.back(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Sector',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Obx(() => Text(
                                'Choose a sector to see all businesses in ${controller.selectedCity.value.name}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: textSecondary,
                                  fontWeight: FontWeight.w400,
                                ),
                              )),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Selected City Pill Bar with "Change" button
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: cityPillBg,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: border, width: 1),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            color: isDark ? Colors.white : const Color(0xFF111111),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Obx(() {
                            final stateName = controller.selectedCity.value.state.isNotEmpty
                                ? controller.selectedCity.value.state
                                : controller.selectedState.value;
                            return Text(
                              '${controller.selectedCity.value.name}, $stateName',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: textPrimary,
                              ),
                            );
                          }),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF242426) : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: border, width: 1),
                          ),
                          child: Text(
                            'Change',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : const Color(0xFF111111),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // Reactive Sector Section (Loading, Empty, or Grid)
                Obx(() {
                  // 1. Loading State
                  if (controller.isLoadingSectors.value) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 60),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: textPrimary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Loading sectors...',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // 2. Empty State (No sectors returned by API)
                  if (controller.allSectors.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 76,
                              height: 76,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF3F4F6),
                                shape: BoxShape.circle,
                                border: Border.all(color: border, width: 1),
                              ),
                              child: Icon(
                                Icons.location_city_outlined,
                                size: 36,
                                color: textSecondary,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'Sector Not Available',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'No sectors are available for ${controller.selectedCity.value.name}.\nPlease select another city or check back later.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.4,
                                color: textSecondary,
                              ),
                            ),
                            const SizedBox(height: 20),
                            OutlinedButton.icon(
                              onPressed: () => controller.fetchCitySectors(
                                city: controller.selectedCity.value.name,
                              ),
                              icon: Icon(Icons.refresh_rounded, size: 16, color: textPrimary),
                              label: Text(
                                'Retry',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: textPrimary,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: border, width: 1.2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // 3. Sectors Grid
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.allSectors.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.95,
                    ),
                    itemBuilder: (context, index) {
                      final sector = controller.allSectors[index];
                      final isSelected = controller.selectedSector.value.id == sector.id;

                      return GestureDetector(
                        onTap: () {
                          controller.selectSector(sector);
                          Get.toNamed(AppRoutes.sectorListing);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected ? selectedBorder : border,
                              width: isSelected ? 2.0 : 1.0,
                            ),
                            boxShadow: isDark
                                ? []
                                : [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.03),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Modern commercial building icon
                              Container(
                                width: 54,
                                height: 54,
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF222224) : const Color(0xFFF3F5F9),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.apartment_rounded,
                                    size: 28,
                                    color: isDark ? Colors.white : const Color(0xFF111111),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Sector Name
                              Text(
                                sector.name,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),

                              // Business Count
                              Text(
                                sector.businessCount,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: textSecondary,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
