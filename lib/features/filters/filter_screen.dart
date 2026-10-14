import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/themes/app_colors.dart';
import 'filter_controller.dart';
import '../business_listing/business_controller.dart';
import '../city_sector/city_sector_controller.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  final filterController = Get.find<FilterController>();
  final TextEditingController _citySearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filterController.openFilterScreen();
  }

  @override
  void dispose() {
    _citySearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final chipBg = isDark ? AppColors.darkCard : AppColors.lightSecondary;
    final selectedChipBg = isDark ? Colors.white : Colors.black;
    final selectedChipText = isDark ? Colors.black : Colors.white;

    final categories = [
      'All',
      'Doctor',
      'Advocates',
      'Hotel',
      'Restaurant',
      'Electronics',
      'Education',
      'Salon',
      'Gym',
    ];

    final citySectorController = Get.isRegistered<CitySectorController>()
        ? Get.find<CitySectorController>()
        : null;
    final allCities = citySectorController != null && citySectorController.allCities.isNotEmpty
        ? citySectorController.allCities.map((c) => c.name).toList()
        : (Get.isRegistered<BusinessController>()
            ? Get.find<BusinessController>().allCityOptions.where((c) => c != 'All').toList()
            : <String>[]);
    final searchQuery = _citySearchController.text.trim().toLowerCase();
    final displayedCities = searchQuery.isEmpty
        ? allCities
        : allCities.where((c) => c.toLowerCase().contains(searchQuery)).toList();

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar: Filter Title & Close X Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: textPrimary, size: 24),
                    onPressed: () => Get.back(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Business Category
                    _buildSectionTitle('Business Category', textPrimary),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: categories.map((cat) {
                        return Obx(() {
                          final isSelected =
                              filterController.draftCategory.value.toLowerCase() ==
                                  cat.toLowerCase();
                          return GestureDetector(
                            onTap: () => filterController.selectDraftCategory(cat),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 9),
                              decoration: BoxDecoration(
                                color: isSelected ? selectedChipBg : chipBg,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? Colors.transparent : border,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                cat,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: isSelected ? selectedChipText : textPrimary,
                                ),
                              ),
                            ),
                          );
                        });
                      }).toList(),
                    ),

                    const SizedBox(height: 26),

                    // Section 2: Select City
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionTitle('Select City', textPrimary),
                        Text(
                          '${displayedCities.length} cities',
                          style: TextStyle(
                            fontSize: 12,
                            color: textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // City Search Bar
                    Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : const Color(0xFFF3F5F8),
                        borderRadius: BorderRadius.circular(21),
                        border: Border.all(
                          color: isDark ? const Color(0xFF27272A) : border,
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search_rounded,
                            color: textSecondary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _citySearchController,
                              style: TextStyle(
                                color: textPrimary,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                              ),
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                hintText: 'Search city...',
                                hintStyle: TextStyle(
                                  color: textSecondary.withValues(alpha: 0.8),
                                  fontSize: 13,
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          if (_citySearchController.text.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _citySearchController.clear();
                                setState(() {});
                              },
                              child: Icon(
                                Icons.cancel_rounded,
                                color: textSecondary,
                                size: 16,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (displayedCities.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Text(
                            'No cities match "$searchQuery"',
                            style: TextStyle(
                              fontSize: 13,
                              color: textSecondary,
                            ),
                          ),
                        ),
                      )
                    else
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: displayedCities.map((city) {
                          return Obx(() {
                            final isSelected =
                                filterController.draftCity.value.toLowerCase() ==
                                    city.toLowerCase();
                            return GestureDetector(
                              onTap: () => filterController.selectDraftCity(city),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 9),
                                decoration: BoxDecoration(
                                  color: isSelected ? selectedChipBg : chipBg,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected ? Colors.transparent : border,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  city,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: isSelected ? selectedChipText : textPrimary,
                                  ),
                                ),
                              ),
                            );
                          });
                        }).toList(),
                      ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom Buttons: Clear All & Apply Filters
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  // Clear All Button
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {
                          filterController.clearDraftFilters();
                          _citySearchController.clear();
                          setState(() {});
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text(
                          'Clear All',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Apply Filters Button
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          filterController.applyDraftFilters();
                          // 1. Sync BusinessController
                          if (Get.isRegistered<BusinessController>()) {
                            final bc = Get.find<BusinessController>();
                            bc.selectedCategory.value =
                                filterController.activeCategory.value;
                            bc.selectedCity.value =
                                filterController.activeCity.value;
                          }
                          // 2. Sync CitySectorController
                          if (Get.isRegistered<CitySectorController>()) {
                            final csc = Get.find<CitySectorController>();
                            csc.applyFilter(
                              category: filterController.activeCategory.value,
                              cityName: filterController.activeCity.value,
                            );
                          }
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedChipBg,
                          foregroundColor: selectedChipText,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text(
                          'Apply Filters',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: selectedChipText,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }
}
