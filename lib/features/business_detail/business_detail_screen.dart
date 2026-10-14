import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';
import '../../app/themes/app_colors.dart';
import '../../core/services/remote_service.dart';
import '../../core/utils/app_launcher.dart';
import '../../core/widgets/app_avatar.dart';
import '../../data/models/business_model.dart';
import '../authentication/auth_controller.dart';
import '../business_listing/business_controller.dart';
import '../favorites/favorites_controller.dart';

class BusinessDetailScreen extends StatefulWidget {
  const BusinessDetailScreen({super.key});

  @override
  State<BusinessDetailScreen> createState() => _BusinessDetailScreenState();
}

class _BusinessDetailScreenState extends State<BusinessDetailScreen> {
  // 0: Personal, 1: Business
  int _selectedTab = 0;
  int _selectedBusinessIndex = 0;
  List<BusinessModel> _entityBusinesses = [];
  bool _isLoadingBusinesses = false;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is Map && args['business'] is BusinessModel) {
      final passed = args['business'] as BusinessModel;
      Get.find<BusinessController>().selectBusiness(passed);
    }
    _fetchPersonDetails();
  }

  Future<void> _fetchPersonDetails() async {
    if (!mounted) return;
    final businessController = Get.find<BusinessController>();
    businessController.isLoadingDetails.value = true;
    setState(() => _isLoadingBusinesses = true);

    try {
      final args = Get.arguments;
      final String? targetId = args is Map
          ? args['id']?.toString()
          : (args is String ? args : businessController.selectedBusiness.value?.id);

      print("BusinessDetailScreen _fetchPersonDetails targetId: $targetId");

      if (targetId != null && targetId.isNotEmpty) {
        final res = await RemoteService.getPersonDetails(id: targetId);
        log("BusinessDetailScreen getPersonDetails ($targetId) res: $res");

        if (res != null && (res['success'] == true || res['status'] == 200)) {
          dynamic pData = res['data'] ?? res['person'] ?? res;
          if (pData is Map && pData['person'] is Map) {
            pData = pData['person'];
          }
          if (pData is Map) {
            final personModel = BusinessModel.fromJson(Map<String, dynamic>.from(pData));
            businessController.selectBusiness(personModel);

            List<BusinessModel> loaded = [];
            final bList = pData['businesses'];
            if (bList is List && bList.isNotEmpty) {
              final personBusinesses = bList
                  .map((b) => BusinessModel.fromJson(Map<String, dynamic>.from(b)))
                  .toList();
              for (final pb in personBusinesses) {
                if (!loaded.any((l) => l.id == pb.id)) {
                  loaded.add(pb);
                }
              }
            }

            if (mounted) {
              setState(() {
                _entityBusinesses = loaded;
                _selectedBusinessIndex = 0;
              });
            }
          }
        }
      }
    } catch (e) {
      log("Error fetching person details: $e");
    } finally {
      businessController.isLoadingDetails.value = false;
      if (mounted) {
        setState(() => _isLoadingBusinesses = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final businessController = Get.find<BusinessController>();
    final favController = Get.find<FavoritesController>();

    final bg = isDark ? AppColors.darkBackground : const Color(0xFFFFFFFF);
    final cardBg = isDark ? const Color(0xFF111D30) : const Color(0xFFFFFFFF);
    final textPrimary = isDark ? AppColors.darkTextPrimary : const Color(0xFF0F172A);
    final textSecondary = isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);
    final border = isDark ? const Color(0xFF1E2D44) : const Color(0xFFE9EDF2);
    final circleBtnBg = isDark ? const Color(0xFF142234) : const Color(0xFFF1F4F9);
    final circleBtnBorder = isDark ? const Color(0xFF22354E) : const Color(0xFFE5E9F0);
    final pillBg = isDark ? const Color(0xFF142032) : const Color(0xFFF0F3F8);
    final selectedTabBg = isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
    final selectedTabText = isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
    final unselectedTabText = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Obx(() {
      final business = businessController.selectedBusiness.value;
      final authController = Get.isRegistered<AuthController>() ? Get.find<AuthController>() : null;
      final currentUser = authController?.currentUser.value;
      final isLoading = businessController.isLoadingDetails.value;
      log("businessController.selectedBusiness.value--------->>>> ${business?.toJson()}");

      if (isLoading && business == null) {
        return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: bg,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary, size: 20),
              onPressed: () => Get.back(),
            ),
          ),
          body: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: textPrimary,
            ),
          ),
        );
      }

      if (business == null && _entityBusinesses.isEmpty) {
        return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: bg,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary, size: 20),
              onPressed: () => Get.back(),
            ),
          ),
          body: const Center(child: Text('No business selected')),
        );
      }

      List<BusinessModel> effectiveBusinesses = List.from(_entityBusinesses);
      if (effectiveBusinesses.isEmpty && business != null) {
        effectiveBusinesses.add(business);
      }

      final int currentIndex = effectiveBusinesses.isNotEmpty
          ? _selectedBusinessIndex.clamp(0, effectiveBusinesses.length - 1)
          : 0;

      final BusinessModel? activeBusiness =
          effectiveBusinesses.isNotEmpty ? effectiveBusinesses[currentIndex] : business;

      final isCurrentUser = currentUser != null && (
          (business != null && (
              currentUser.name.trim().toLowerCase() == business.name.trim().toLowerCase() ||
              currentUser.email.trim().toLowerCase() == business.email.trim().toLowerCase() ||
              (currentUser.phoneNumber.isNotEmpty && business.phoneNumber.isNotEmpty &&
                  currentUser.phoneNumber.replaceAll(RegExp(r'\D'), '') == business.phoneNumber.replaceAll(RegExp(r'\D'), '')) ||
              _entityBusinesses.any((ub) => ub.id == business.id)
          ))
      );

      final displayName = (isCurrentUser && currentUser.name.isNotEmpty)
          ? currentUser.name
          : (business?.name.isNotEmpty == true ? business!.name : (activeBusiness?.name ?? ''));

      final displaySpecialty = _selectedTab == 1
          ? (activeBusiness?.specialty.isNotEmpty == true
              ? activeBusiness!.specialty
              : (activeBusiness?.category.isNotEmpty == true
                  ? activeBusiness!.category
                  : (business?.specialty.isNotEmpty == true ? business!.specialty : 'Business')))
          : (business?.specialty.isNotEmpty == true
              ? business!.specialty
              : (business?.category.isNotEmpty == true ? business!.category : 'advocates'));

      final heroImageUrl = (_selectedTab == 1 && activeBusiness?.imageUrl.isNotEmpty == true)
          ? activeBusiness!.imageUrl
          : ((isCurrentUser && currentUser.avatarUrl.isNotEmpty)
              ? currentUser.avatarUrl
              : (business?.imageUrl ?? (activeBusiness?.imageUrl ?? '')));

      final heroInitials = (business?.avatarInitials.isNotEmpty == true)
          ? business!.avatarInitials
          : (displayName.trim().isNotEmpty
              ? displayName.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
              : 'DA');

      final activeBusinessId = activeBusiness?.id ?? business?.id ?? 'biz_detail';
      final isFav = favController.isFavorite(activeBusinessId);

      return Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: Column(
            children: [
              // Loading bar when refreshing in background
              if (isLoading || _isLoadingBusinesses)
                LinearProgressIndicator(
                  minHeight: 2,
                  backgroundColor: Colors.transparent,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),

              // Top Bar with Back, Heart (Save), Share, and Edit Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: isFav ? const Color(0xFFEF4444) : textPrimary,
                            size: 24,
                          ),
                          onPressed: () => favController.toggleFavorite(
                            activeBusinessId,
                            businessName: activeBusiness?.name ?? business?.name ?? displayName,
                            business: activeBusiness ?? business,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: Icon(
                            Icons.ios_share_rounded,
                            color: textPrimary,
                            size: 24,
                          ),
                          onPressed: () => AppLauncher.shareBusiness(
                            name: activeBusiness?.displayBusinessName ?? business?.name ?? displayName,
                            specialty: activeBusiness?.specialty ?? business?.specialty ?? displaySpecialty,
                            address: activeBusiness?.address ?? business?.address ?? '',
                            phone: activeBusiness?.displayBusinessPhone ?? business?.displayBusinessPhone ?? '',
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        if (isCurrentUser) ...[
                          const SizedBox(width: 14),
                          IconButton(
                            icon: Icon(
                              Icons.edit_outlined,
                              color: textPrimary,
                              size: 22,
                            ),
                            tooltip: 'Edit Profile',
                            onPressed: () => Get.toNamed(AppRoutes.editProfile),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Scrollable Detail Content with Pull to Refresh
              Expanded(
                child: RefreshIndicator(
                  color: textPrimary,
                  backgroundColor: cardBg,
                  onRefresh: () async {
                    await _fetchPersonDetails();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),

                        // Centered Round Avatar
                        Center(
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                                width: 3.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                                  blurRadius: 18,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: AppAvatar(
                              imageUrl: heroImageUrl,
                              initials: heroInitials,
                              size: 110,
                              isCircle: true,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Doctor / Business / Person Name (Centered)
                        Center(
                          child: Text(
                            displayName,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ),

                        if (displaySpecialty.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          // Category / Profession Subtitle (Centered)
                          Center(
                            child: Text(
                              displaySpecialty,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w500,
                                color: textSecondary,
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 22),

                        // Action Buttons: Call, WhatsApp, Save
                        Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // 1. Call Button
                          _buildDetailActionButton(
                            iconWidget: Icon(
                              Icons.phone_rounded,
                              color: textPrimary,
                              size: 22,
                            ),
                            label: 'Call',
                            circleBg: circleBtnBg,
                            borderColor: circleBtnBorder,
                            textColor: textPrimary,
                            onTap: () => AppLauncher.makePhoneCall(
                              _selectedTab == 1
                                  ? (activeBusiness?.displayBusinessPhone ?? business?.displayBusinessPhone ?? '')
                                  : (activeBusiness?.displayPersonalPhone ?? business?.displayPersonalPhone ?? ''),
                            ),
                          ),

                          // 2. WhatsApp Button
                          _buildDetailActionButton(
                            iconWidget: Image.asset("assets/image/whatsapp.png", height: 25, width: 25),
                            label: 'WhatsApp',
                            circleBg: circleBtnBg,
                            borderColor: circleBtnBorder,
                            textColor: textPrimary,
                            onTap: () => AppLauncher.openWhatsApp(
                              _selectedTab == 1
                                  ? (activeBusiness?.whatsappNumber.isNotEmpty == true
                                      ? activeBusiness!.whatsappNumber
                                      : (activeBusiness?.phoneNumber ?? business?.phoneNumber ?? ''))
                                  : (business?.whatsappNumber.isNotEmpty == true
                                      ? business!.whatsappNumber
                                      : (business?.phoneNumber ?? '')),
                            ),
                          ),

                          // 3. Save Button
                          _buildDetailActionButton(
                            iconWidget: Icon(
                              isFav ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                              color: textPrimary,
                              size: 22,
                            ),
                            label: 'Save',
                            circleBg: circleBtnBg,
                            borderColor: circleBtnBorder,
                            textColor: textPrimary,
                            onTap: () => favController.toggleFavorite(
                              activeBusinessId,
                              businessName: activeBusiness?.name ?? business?.name ?? displayName,
                              business: activeBusiness ?? business,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // Segmented Switcher / Pill Bar (Personal / Business)
                      Container(
                        height: 48,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: pillBg,
                          borderRadius: BorderRadius.circular(26),
                        ),
                        child: Row(
                          children: [
                            // Personal Tab
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  if (_selectedTab != 0) {
                                    setState(() => _selectedTab = 0);
                                  }
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                  decoration: BoxDecoration(
                                    color: _selectedTab == 0 ? selectedTabBg : Colors.transparent,
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Personal',
                                    style: TextStyle(
                                      color: _selectedTab == 0
                                          ? selectedTabText
                                          : unselectedTabText,
                                      fontWeight: _selectedTab == 0
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Business Tab
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  if (_selectedTab != 1) {
                                    setState(() => _selectedTab = 1);
                                  }
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                  decoration: BoxDecoration(
                                    color: _selectedTab == 1 ? selectedTabBg : Colors.transparent,
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Business',
                                    style: TextStyle(
                                      color: _selectedTab == 1
                                          ? selectedTabText
                                          : unselectedTabText,
                                      fontWeight: _selectedTab == 1
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Horizontal Selector Bar for Businesses (matching second Image)
                      if (_selectedTab == 1) ...[
                        const SizedBox(height: 14),
                        if (effectiveBusinesses.isNotEmpty)
                          _buildBusinessHorizontalSelector(
                            businesses: effectiveBusinesses,
                            selectedIndex: currentIndex,
                            onSelect: (index) {
                              setState(() {
                                _selectedBusinessIndex = index;
                              });
                            },
                            isDark: isDark,
                            isLoading: _isLoadingBusinesses,
                            cardBg: cardBg,
                            border: border,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                          ),
                      ],

                      const SizedBox(height: 16),

                      // Card Container for Active Tab Content
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: border, width: 1.2),
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          switchInCurve: Curves.easeInOut,
                          switchOutCurve: Curves.easeInOut,
                          child: _selectedTab == 0
                              ? _buildPersonalTab(
                                  business: activeBusiness ?? business,
                                  textPrimary: textPrimary,
                                  textSecondary: textSecondary,
                                )
                              : _buildBusinessTab(
                                  business: activeBusiness ?? business,
                                  textPrimary: textPrimary,
                                  textSecondary: textSecondary,
                                  border: border,
                                  isDark: isDark,
                                ),
                        ),
                      ),

                      const SizedBox(height: 36),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  });
}

  // Business Horizontal Selector Bar (matching second image mockup)
  Widget _buildBusinessHorizontalSelector({
    required List<BusinessModel> businesses,
    required int selectedIndex,
    required ValueChanged<int> onSelect,
    required bool isDark,
    bool isLoading = false,
    required Color cardBg,
    required Color border,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.business_center_rounded,
                  size: 16,
                  color: textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Your Businesses (${businesses.length})',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: textSecondary,
                    letterSpacing: 0.2,
                  ),
                ),
                if (isLoading) ...[
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.8,
                      color: textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 66,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: businesses.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final b = businesses[index];
              final bool isSelected = index == selectedIndex;
              final bName = b.displayBusinessName.isNotEmpty ? b.displayBusinessName : b.name;
              final subText = [
                if (b.category.isNotEmpty) b.category,
                if (b.city.isNotEmpty) b.city,
              ].join(' • ');

              return GestureDetector(
                onTap: () => onSelect(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  constraints: const BoxConstraints(minWidth: 145),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark ? const Color(0xFF1E355B) : const Color(0xFFEBF3FE))
                        : (isDark ? const Color(0xFF131F33) : const Color(0xFFF8FAFC)),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? (isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB))
                          : (isDark ? const Color(0xFF1E2D44) : const Color(0xFFE2E8F0)),
                      width: isSelected ? 1.8 : 1.0,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF2563EB).withValues(alpha: isDark ? 0.3 : 0.18),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark ? const Color(0xFF2563EB) : const Color(0xFF3B82F6))
                              : (isDark ? const Color(0xFF1E2B40) : const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.apartment_rounded,
                          size: 19,
                          color: isSelected ? Colors.white : textSecondary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                bName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                  color: isSelected
                                      ? (isDark ? Colors.white : const Color(0xFF0F172A))
                                      : textPrimary,
                                ),
                              ),
                              if (isSelected) ...[
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 14,
                                  color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
                                ),
                              ],
                            ],
                          ),
                          if (subText.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              subText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Personal Tab View matching Left Mockup
  Widget _buildPersonalTab({
    required dynamic business,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final String phone = (business.displayPersonalPhone.isNotEmpty)
        ? business.displayPersonalPhone
        : (_entityBusinesses.isNotEmpty && _entityBusinesses.first.displayPersonalPhone.isNotEmpty)
            ? _entityBusinesses.first.displayPersonalPhone
            : (business.phoneNumber.isNotEmpty ? business.phoneNumber : '');

    final String email = (business.displayPersonalEmail.isNotEmpty)
        ? business.displayPersonalEmail
        : (_entityBusinesses.isNotEmpty && _entityBusinesses.first.displayPersonalEmail.isNotEmpty)
            ? _entityBusinesses.first.displayPersonalEmail
            : (business.email.isNotEmpty ? business.email : '');

    return Column(
      key: const ValueKey('personal_tab'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Information',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 16),

        // Phone Row
        _buildContactRow(
          icon: Icons.phone_rounded,
          text: phone.isNotEmpty ? phone : 'Not provided',
          onTap: phone.isNotEmpty ? () => AppLauncher.makePhoneCall(phone) : () {},
          textPrimary: phone.isNotEmpty ? textPrimary : textSecondary,
          textSecondary: textSecondary,
        ),
        const SizedBox(height: 16),

        // Email Row
        _buildContactRow(
          icon: Icons.mail_outline_rounded,
          text: email.isNotEmpty ? email : 'Not provided',
          onTap: email.isNotEmpty ? () => AppLauncher.sendEmail(email) : () {},
          textPrimary: email.isNotEmpty ? textPrimary : textSecondary,
          textSecondary: textSecondary,
        ),
      ],
    );
  }

  // Business Tab View matching Right Mockup
  Widget _buildBusinessTab({
    required dynamic business,
    required Color textPrimary,
    required Color textSecondary,
    required Color border,
    required bool isDark,
  }) {
    final String description =
        business.description != null ? business.description.toString().trim() : '';
    final bool hasDescription = description.isNotEmpty;

    final String specialtyText =
        business.specialty != null ? business.specialty.toString().trim() : '';
    final bool hasSpecialty = specialtyText.isNotEmpty;

    List<String> rawSpecializations = [];
    if (business is BusinessModel) {
      rawSpecializations = business.specializations;
    } else if (business.specializations is List) {
      rawSpecializations = (business.specializations as List).map((e) => e.toString()).toList();
    } else if (business.specializations is String && (business.specializations as String).trim().isNotEmpty) {
      rawSpecializations = (business.specializations as String).split(',');
    }

    final List<String> cleanSpecializations = rawSpecializations
        .expand((s) => s.split(','))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();

    final List<String> displaySpecializations = (cleanSpecializations.length == 1 &&
            hasSpecialty &&
            cleanSpecializations.first.toLowerCase() == specialtyText.toLowerCase())
        ? []
        : cleanSpecializations;
    final bool hasSpecializations = displaySpecializations.isNotEmpty;

    return Column(
      key: const ValueKey('business_tab'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Business Name Row with Building Icon & Arrow
        Row(
          children: [
            Icon(
              Icons.apartment_rounded,
              size: 26,
              color: textPrimary,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Business Name',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    business.displayBusinessName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 22,
              color: textSecondary,
            ),
          ],
        ),

        const SizedBox(height: 14),
        Divider(
          color: border,
          thickness: 1,
          height: 1,
        ),
        const SizedBox(height: 16),

        // Contact Information Section
        Text(
          'Contact Information',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 14),

        // Phone Row
        _buildContactRow(
          icon: Icons.phone_rounded,
          text: business.displayBusinessPhone,
          onTap: () => AppLauncher.makePhoneCall(business.displayBusinessPhone),
          textPrimary: textPrimary,
          textSecondary: textSecondary,
        ),
        const SizedBox(height: 14),

        // Email Row
        _buildContactRow(
          icon: Icons.mail_outline_rounded,
          text: business.displayBusinessEmail,
          onTap: () => AppLauncher.sendEmail(business.displayBusinessEmail),
          textPrimary: textPrimary,
          textSecondary: textSecondary,
        ),

        const SizedBox(height: 20),

        // Address Section
        Text(
          'Address',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location Pin and Address Text
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 20,
                    color: textPrimary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      business.address,
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.4,
                        fontWeight: FontWeight.w400,
                        color: textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),

            // Mini Map Preview with "Open in Maps" Overlay Badge
            _buildMiniMapCard(
              business: business,
              isDark: isDark,
              border: border,
            ),
          ],
        ),

        // Description Section (shown only if available)
        if (hasDescription) ...[
          const SizedBox(height: 20),
          Text(
            'Description',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.5,
              fontWeight: FontWeight.w400,
              color: textSecondary,
            ),
          ),
        ],

        // Specialty Section
        if (hasSpecialty) ...[
          const SizedBox(height: 20),
          Text(
            'Specialty',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            specialtyText,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.5,
              fontWeight: FontWeight.w400,
              color: textSecondary,
            ),
          ),
        ],

        // Specializations Section
        if (hasSpecializations) ...[
          const SizedBox(height: 20),
          Text(
            'Specializations',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: displaySpecializations.map((spec) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2D44) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: border,
                    width: 1,
                  ),
                ),
                child: Text(
                  spec,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: textPrimary,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildContactRow({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Icon(icon, size: 20, color: textPrimary),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniMapCard({
    required dynamic business,
    required bool isDark,
    required Color border,
  }) {
    return GestureDetector(
      onTap: () => AppLauncher.openMap(
        business.latitude,
        business.longitude,
        business.name,
      ),
      child: Container(
        width: 112,
        height: 78,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            CustomPaint(
              size: const Size(112, 78),
              painter: MiniMapPreviewPainter(isDark: isDark),
            ),
            const Center(
              child: Icon(
                Icons.location_on_rounded,
                color: Color(0xFFEF4444),
                size: 22,
              ),
            ),
            Positioned(
              bottom: 4,
              left: 5,
              right: 5,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.14),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 11,
                      color: Color(0xFFEF4444),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      'Open in Maps',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailActionButton({
    required Widget iconWidget,
    required String label,
    required Color circleBg,
    required Color borderColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: circleBg,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 1),
            ),
            alignment: Alignment.center,
            child: iconWidget,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

// Clean Custom WhatsApp Outline Icon
class WhatsAppIcon extends StatelessWidget {
  final double size;
  final Color color;

  const WhatsAppIcon({
    super.key,
    this.size = 22,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _WhatsAppPainter(color: color),
    );
  }
}

class _WhatsAppPainter extends CustomPainter {
  final Color color;
  _WhatsAppPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale);

    final outlinePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final phonePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Speech bubble outline
    final bubble = Path();
    bubble.moveTo(12, 2.5);
    bubble.cubicTo(6.75, 2.5, 2.5, 6.75, 2.5, 12);
    bubble.cubicTo(2.5, 13.85, 3.05, 15.6, 4.0, 17.1);
    bubble.lineTo(2.8, 21.2);
    bubble.lineTo(7.1, 20.05);
    bubble.cubicTo(8.55, 20.95, 10.2, 21.5, 12, 21.5);
    bubble.cubicTo(17.25, 21.5, 21.5, 17.25, 21.5, 12);
    bubble.cubicTo(21.5, 6.75, 17.25, 2.5, 12, 2.5);
    canvas.drawPath(bubble, outlinePaint);

    // Phone handset inside
    final phone = Path();
    phone.moveTo(8.8, 7.8);
    phone.cubicTo(8.6, 7.4, 8.3, 7.4, 8.0, 7.4);
    phone.cubicTo(7.7, 7.4, 7.4, 7.4, 7.2, 7.7);
    phone.cubicTo(6.9, 8.0, 6.3, 8.6, 6.3, 9.8);
    phone.cubicTo(6.3, 11.0, 7.2, 12.2, 7.3, 12.4);
    phone.cubicTo(7.5, 12.6, 9.1, 15.1, 11.6, 16.1);
    phone.cubicTo(13.7, 16.9, 14.2, 16.7, 14.6, 16.6);
    phone.cubicTo(15.1, 16.5, 16.0, 15.9, 16.2, 15.3);
    phone.cubicTo(16.4, 14.7, 16.4, 14.2, 16.3, 14.1);
    phone.cubicTo(16.2, 14.0, 16.0, 13.9, 15.5, 13.7);
    phone.cubicTo(15.0, 13.5, 12.8, 12.4, 12.4, 12.2);
    phone.cubicTo(12.1, 12.1, 11.8, 12.0, 11.6, 12.4);
    phone.cubicTo(11.3, 12.8, 10.6, 13.6, 10.4, 13.9);
    phone.cubicTo(10.2, 14.1, 10.0, 14.1, 9.6, 13.9);
    phone.cubicTo(9.2, 13.7, 7.8, 13.2, 7.0, 12.1);
    phone.close();
    canvas.drawPath(phone, phonePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WhatsAppPainter oldDelegate) =>
      oldDelegate.color != color;
}

class MiniMapPreviewPainter extends CustomPainter {
  final bool isDark;
  MiniMapPreviewPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    // Background terrain
    final bgPaint = Paint()
      ..color = isDark ? const Color(0xFF1E2836) : const Color(0xFFE8EEF5);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Secondary subtle road
    final minorRoadPaint = Paint()
      ..color = isDark ? const Color(0xFF283648) : const Color(0xFFD4DFEE)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;

    final minorPath = Path();
    minorPath.moveTo(0, size.height * 0.75);
    minorPath.lineTo(size.width, size.height * 0.3);
    canvas.drawPath(minorPath, minorRoadPaint);

    // Primary road
    final roadPaint = Paint()
      ..color = isDark ? const Color(0xFF33455C) : const Color(0xFFFFFFFF)
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke;

    final path1 = Path();
    path1.moveTo(0, size.height * 0.38);
    path1.lineTo(size.width, size.height * 0.65);
    canvas.drawPath(path1, roadPaint);

    final path2 = Path();
    path2.moveTo(size.width * 0.48, 0);
    path2.lineTo(size.width * 0.58, size.height);
    canvas.drawPath(path2, roadPaint);
  }

  @override
  bool shouldRepaint(covariant MiniMapPreviewPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
