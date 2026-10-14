import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/themes/app_colors.dart';
import '../../core/widgets/business_card.dart';
import 'business_controller.dart';
import '../../app/routes/app_routes.dart';

class BusinessListingScreen extends StatefulWidget {
  const BusinessListingScreen({super.key});

  @override
  State<BusinessListingScreen> createState() => _BusinessListingScreenState();
}

class _BusinessListingScreenState extends State<BusinessListingScreen> {
  final BusinessController controller = Get.find<BusinessController>();

  @override
  void initState() {
    super.initState();
    controller.fetchAvailableStates();
    _loadPeopleData();
  }

  void _loadPeopleData() {
    final cat = controller.selectedCategory.value;
    final query = cat.isNotEmpty && cat.toLowerCase() != 'all' ? cat.toLowerCase() : 'advocate';
    controller.fetchPeople(
      query: query,
      page: 1,
      limit: 20,
      state: controller.selectedState.value != 'All' ? controller.selectedState.value : null,
      city: controller.selectedCity.value != 'All' ? controller.selectedCity.value : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Obx(() {
          final cat = controller.selectedCategory.value;
          final title = cat.toLowerCase() == 'doctor' ? 'Doctors' : cat;
          return Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          );
        }),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search_rounded, color: textPrimary, size: 22),
            onPressed: () => Get.toNamed(AppRoutes.search),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Side: State & City Dropdown Filter Bar
            _buildStateCityFilterBar(
              isDark: isDark,
              cardBg: cardBg,
              border: border,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),

            // Business Listing
            Expanded(
              child: Obx(() {
                final list = controller.categoryListingBusinesses;

                if (controller.isLoading.value && list.isEmpty) {
                  return Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: textPrimary,
                    ),
                  );
                }

                if (list.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 54,
                            color: textSecondary.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'No Businesses Found',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            controller.selectedCity.value != 'All'
                                ? 'No listings found in ${controller.selectedCity.value}. Try changing the city or state filter.'
                                : 'No listings available in this category.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: textSecondary,
                            ),
                          ),
                          if (controller.selectedState.value != 'All' || controller.selectedCity.value != 'All') ...[
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => controller.resetListingFilters(),
                              icon: const Icon(Icons.refresh_rounded, size: 16),
                              label: const Text('Reset Filters'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark ? Colors.white : Colors.black,
                                foregroundColor: isDark ? Colors.black : Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  color: isDark ? Colors.white : Colors.black,
                  backgroundColor: cardBg,
                  onRefresh: () async {
                    final cat = controller.selectedCategory.value;
                    final query = cat.isNotEmpty && cat.toLowerCase() != 'all' ? cat.toLowerCase() : 'advocate';
                    await controller.fetchPeople(
                      query: query,
                      page: 1,
                      limit: 20,
                      state: controller.selectedState.value != 'All' ? controller.selectedState.value : null,
                      city: controller.selectedCity.value != 'All' ? controller.selectedCity.value : null,
                    );
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final business = list[index];
                      return BusinessCard(business: business);
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

  Widget _buildStateCityFilterBar({
    required bool isDark,
    required Color cardBg,
    required Color border,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Obx(() {
      final states = controller.availableStateOptions;
      final cities = controller.availableCityOptions;
      final selectedState = controller.selectedState.value;
      final selectedCity = controller.selectedCity.value;
      final isCityEnabled = controller.isCityFilterEnabled;
      final hasActiveFilter = (selectedState != 'All' || selectedCity != 'All');

      return Container(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        child: Row(
          children: [
            // 1. State Dropdown
            Expanded(
              child: _buildDropdownCard(
                label: 'State',
                icon: Icons.map_outlined,
                value: selectedState,
                items: states,
                allLabel: 'All States',
                onChanged: (val) {
                  if (val != null) {
                    controller.selectState(val);
                  }
                },
                isDark: isDark,
                cardBg: cardBg,
                border: border,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),
            ),
            const SizedBox(width: 10),
            // 2. City Dropdown (Enabled only when state is selected)
            Expanded(
              child: _buildDropdownCard(
                label: 'City',
                icon: Icons.location_on_outlined,
                value: selectedCity,
                items: cities,
                allLabel: 'All Cities',
                isEnabled: isCityEnabled,
                onDisabledTap: () {
                  Get.snackbar(
                    'Select State First',
                    'Please select a state to view and filter cities.',
                    snackPosition: SnackPosition.BOTTOM,
                    margin: const EdgeInsets.all(16),
                    backgroundColor: const Color(0xFF00246C),
                    colorText: Colors.white,
                    icon: const Icon(Icons.info_outline_rounded, color: Color(0xFFF7A81B)),
                    duration: const Duration(seconds: 2),
                  );
                },
                onChanged: (val) {
                  if (val != null) {
                    controller.selectCity(val);
                  }
                },
                isDark: isDark,
                cardBg: cardBg,
                border: border,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),
            ),
            if (hasActiveFilter) ...[
              const SizedBox(width: 8),
              Tooltip(
                message: 'Reset Filters',
                child: InkWell(
                  onTap: () => controller.resetListingFilters(),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    height: 48,
                    width: 44,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF242426) : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: border, width: 1),
                    ),
                    child: Icon(
                      Icons.refresh_rounded,
                      size: 20,
                      color: textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildDropdownCard({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required String allLabel,
    required ValueChanged<String?> onChanged,
    required bool isDark,
    required Color cardBg,
    required Color border,
    required Color textPrimary,
    required Color textSecondary,
    bool isEnabled = true,
    VoidCallback? onDisabledTap,
  }) {
    if (!isEnabled) {
      final disabledBg = isDark ? const Color(0xFF161922) : const Color(0xFFF8FAFC);
      final disabledBorder = isDark ? const Color(0xFF262B36) : const Color(0xFFE2E8F0);
      final disabledText = isDark ? const Color(0xFF555B6D) : const Color(0xFF94A3B8);

      return GestureDetector(
        onTap: onDisabledTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: disabledBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: disabledBorder,
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: disabledText,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  allLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: disabledText,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: disabledText.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      );
    }

    // Ensure value exists in items to avoid DropdownButton assertion
    final dropdownItems = items.contains(value) ? items : [value, ...items];
    final isFiltered = value != 'All' && value != 'All States' && value != 'All Cities';

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isFiltered ? (isDark ? Colors.white : Colors.black) : border,
          width: isFiltered ? 1.4 : 1.0,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isFiltered ? textPrimary : textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isDense: true,
                isExpanded: true,
                dropdownColor: cardBg,
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: textSecondary,
                ),
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 13,
                  fontWeight: isFiltered ? FontWeight.w700 : FontWeight.w500,
                ),
                items: dropdownItems.map((item) {
                  final isAll = (item == 'All' || item == 'All States' || item == 'All Cities');
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      isAll ? allLabel : item,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: (item == value) ? FontWeight.w700 : FontWeight.w500,
                        color: textPrimary,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
