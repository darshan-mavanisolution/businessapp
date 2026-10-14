import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/themes/app_colors.dart';
import '../../app/routes/app_routes.dart';
import '../../core/widgets/business_card.dart';
import '../business_listing/business_controller.dart';
import 'city_sector_controller.dart';

class SectorListingScreen extends StatefulWidget {
  const SectorListingScreen({super.key});

  @override
  State<SectorListingScreen> createState() => _SectorListingScreenState();
}

class _SectorListingScreenState extends State<SectorListingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Get.find<CitySectorController>().fetchPeopleForSector();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = Get.find<CitySectorController>();
    final businessController = Get.find<BusinessController>();

    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final searchBg = isDark ? AppColors.darkSecondary : const Color(0xFFF5F7FA);
    final border = isDark ? AppColors.darkBorder : const Color(0xFFE9EDF2);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Row(
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
                        Obx(() => Text(
                              controller.selectedSector.value.name,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: textPrimary,
                                letterSpacing: -0.3,
                              ),
                            )),
                        const SizedBox(height: 2),
                        Obx(() {
                              final city = controller.selectedCity.value.name;
                              final cat = controller.selectedCategory.value;
                              final count = controller.businessesForSelectedSector.length;
                              if (cat != 'All') {
                                return Text(
                                  '$cat in $city ($count found)',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: textSecondary,
                                    fontWeight: FontWeight.w400,
                                  ),
                                );
                              }
                              return Text(
                                'All in $city ($count found)',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: textSecondary,
                                  fontWeight: FontWeight.w400,
                                ),
                              );
                            }),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar & Filter Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: searchBg,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark ? const Color(0xFF223348) : border,
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search_rounded,
                            color: textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: controller.sectorSearchController,
                              style: TextStyle(
                                color: textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search name, category...',
                                hintStyle: TextStyle(
                                  color: textSecondary.withValues(alpha: 0.8),
                                  fontSize: 13.5,
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
                            if (controller.sectorSearchQuery.value.isNotEmpty) {
                              return GestureDetector(
                                onTap: () => controller.clearSectorSearch(),
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
                ],
              ),
            ),

            // Active Filter Chip Row (if Category Filter is Applied)
            Obx(() {
              final cat = controller.selectedCategory.value;
              if (cat == 'All') return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(
                    left: 18, right: 18, top: 10, bottom: 2),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF222224)
                            : const Color(0xFFF4F4F6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? Colors.white : Colors.black,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Category: $cat',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => controller.clearCategoryFilter(),
                            child: Icon(
                              Icons.close_rounded,
                              size: 15,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => controller.clearCategoryFilter(),
                      child: Text(
                        'Clear Filter',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 12),

            // Sector People / Users List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator.adaptive());
                }
                final list = controller.businessesForSelectedSector;

                if (list.isEmpty) {
                  return RefreshIndicator(
                    color: isDark ? Colors.white : Colors.black,
                    backgroundColor: cardBg,
                    onRefresh: () => controller.fetchPeopleForSector(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.55,
                        alignment: Alignment.center,
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
                              'No People Found in this Sector',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              controller.selectedCategory.value != 'All'
                                  ? 'No ${controller.selectedCategory.value} found in ${controller.selectedCity.value.name}.'
                                  : 'Try clearing search or check another sector.',
                              style: TextStyle(color: textSecondary, fontSize: 13),
                            ),
                            if (controller.selectedCategory.value != 'All') ...[
                              const SizedBox(height: 14),
                              ElevatedButton(
                                onPressed: () => controller.clearCategoryFilter(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDark ? Colors.white : Colors.black,
                                  foregroundColor: isDark ? Colors.black : Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Text('Show All'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  color: isDark ? Colors.white : Colors.black,
                  backgroundColor: cardBg,
                  onRefresh: () => controller.fetchPeopleForSector(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final business = list[index];
                      return BusinessCard(
                        business: business,
                        onTap: () {
                          businessController.selectBusiness(business);
                          Get.toNamed(
                            AppRoutes.businessDetail,
                            arguments: {
                              'id': (business.ownerId != null && business.ownerId!.isNotEmpty)
                                  ? business.ownerId
                                  : business.id,
                              'business': business,
                            },
                          );
                        },
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
