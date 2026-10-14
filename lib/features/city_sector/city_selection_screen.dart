import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/themes/app_colors.dart';
import '../../app/routes/app_routes.dart';
import 'city_sector_controller.dart';

class CitySelectionScreen extends StatelessWidget {
  const CitySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = Get.put(CitySectorController());

    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final searchBg = isDark ? AppColors.darkSecondary : const Color(0xFFF5F7FA);
    final border = isDark ? AppColors.darkBorder : const Color(0xFFEFF1F5);
    final linkColor = isDark ? Colors.white : const Color(0xFF111111);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // Location Pin Icon & Select City Title
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF222224) : const Color(0xFFF2F4F7),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.location_on_rounded,
                      color: isDark ? Colors.white : const Color(0xFF111111),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select City',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Choose your city to find nearby businesses',
                          style: TextStyle(
                            fontSize: 13,
                            color: textSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // State Selection Dropdown (Above Search Field)
              GestureDetector(
                onTap: () => _showStatePicker(
                  context,
                  controller,
                  isDark: isDark,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  modalBg: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                  cardBg: cardBg,
                  border: border,
                ),
                child: Container(
                  height: 52,
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
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF222224) : Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.map_rounded,
                          color: isDark ? Colors.white : const Color(0xFF111111),
                          size: 17,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'State',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: textSecondary,
                              ),
                            ),
                            Obx(() => Text(
                                  controller.selectedState.value,
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    color: textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                )),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF252528) : const Color(0xFFE9ECF1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: textPrimary,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Search City Bar
              Container(
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
                        controller: controller.citySearchController,
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search city...',
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
                      if (controller.citySearchQuery.value.isNotEmpty) {
                        return GestureDetector(
                          onTap: () => controller.clearCitySearch(),
                          child: Icon(Icons.cancel_rounded,
                              color: textSecondary, size: 18),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // Dynamic Section Header: "{Selected State} Cities"
              Obx(() {
                final total = controller.filteredCities.length;
                final stateName = controller.selectedState.value;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$stateName Cities',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    Text(
                      'View All ($total)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: linkColor,
                      ),
                    ),
                  ],
                );
              }),

              const SizedBox(height: 16),

              // 3-Column Circular Cities Grid
              Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator.adaptive(),
                    ),
                  );
                }

                final cities = controller.filteredCities;

                if (cities.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_off_outlined,
                            size: 46,
                            color: textSecondary.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No cities found for ${controller.selectedState.value}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            controller.citySearchQuery.value.isNotEmpty
                                ? 'Try searching a different city name.'
                                : 'Select another state from the dropdown.',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cities.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 20,
                    childAspectRatio: 0.74,
                  ),
                  itemBuilder: (context, index) {
                    final city = cities[index];
                    return GestureDetector(
                      onTap: () {
                        controller.selectCity(city);
                        Get.toNamed(AppRoutes.sectorSelection);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Circular City Landmark Photo
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF22364F)
                                    : const Color(0xFFE2E7ED),
                                width: 2,
                              ),
                              boxShadow: isDark
                                  ? []
                                  : [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.network(
                              city.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildCityFallback(city.name, isDark),
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return _buildCityFallback(city.name, isDark);
                              },
                            ),
                          ),
                          const SizedBox(height: 8),

                          // City Name
                          Text(
                            city.name,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                              height: 1.15,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
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
    );
  }

  // Modern Searchable State Selection Bottom Sheet Modal
  void _showStatePicker(
    BuildContext context,
    CitySectorController controller, {
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
    required Color modalBg,
    required Color cardBg,
    required Color border,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: modalBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.72,
          minChildSize: 0.45,
          maxChildSize: 0.92,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  // Drag Handle Bar
                  Center(
                    child: Container(
                      width: 44,
                      height: 4.5,
                      decoration: BoxDecoration(
                        color: textSecondary.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select State',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: Icon(Icons.close_rounded, color: textSecondary, size: 22),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Search Field for State with API & Local Search
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF262628) : const Color(0xFFF4F5F8),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: border, width: 1),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Icon(Icons.search_rounded, color: textSecondary, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: controller.stateSearchController,
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search state (e.g. Gujarat)...',
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
                            onChanged: (val) {
                              if (val.length >= 2) {
                                controller.fetchStates(search: val.trim());
                              }
                            },
                          ),
                        ),
                        Obx(() {
                          if (controller.stateSearchQuery.value.isNotEmpty) {
                            return GestureDetector(
                              onTap: () {
                                controller.stateSearchController.clear();
                                controller.fetchStates();
                              },
                              child: Icon(Icons.cancel_rounded,
                                  color: textSecondary, size: 18),
                            );
                          }
                          return const SizedBox.shrink();
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // List of States
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoadingStates.value) {
                        return const Center(
                          child: CircularProgressIndicator.adaptive(),
                        );
                      }

                      final states = controller.filteredStates;

                      if (states.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              'No states found matching "${controller.stateSearchQuery.value}"',
                              style: TextStyle(color: textSecondary, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        controller: scrollController,
                        physics: const BouncingScrollPhysics(),
                        itemCount: states.length,
                        separatorBuilder: (_, __) => Divider(
                          color: border.withValues(alpha: 0.6),
                          height: 1,
                        ),
                        itemBuilder: (context, index) {
                          final state = states[index];
                          final isSelected = controller.selectedState.value.toLowerCase() ==
                              state.toLowerCase();

                          return ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                            title: Text(
                              state,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                color: isSelected
                                    ? (isDark ? Colors.white : Colors.black)
                                    : textPrimary,
                              ),
                            ),
                            trailing: isSelected
                                ? Icon(
                                    Icons.check_circle_rounded,
                                    color: isDark ? Colors.white : Colors.black,
                                    size: 21,
                                  )
                                : null,
                            onTap: () {
                              controller.selectState(state);
                              Navigator.pop(ctx);
                            },
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCityFallback(String name, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF2C2C2E), const Color(0xFF1C1C1E)]
              : [const Color(0xFFE5E7EB), const Color(0xFFD1D5DB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name.substring(0, 1) : 'G',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
