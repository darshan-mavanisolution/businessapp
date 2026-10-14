import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';
import '../../app/themes/app_colors.dart';
import '../../core/utils/app_launcher.dart';
import '../../core/widgets/app_avatar.dart';
import '../../data/models/business_model.dart';
import '../../data/models/user_model.dart';
import '../authentication/auth_controller.dart';
import '../business_listing/business_controller.dart';
import '../favorites/favorites_controller.dart';
import '../../core/services/remote_service.dart';

class UserProfileDetailScreen extends StatefulWidget {
  const UserProfileDetailScreen({super.key});

  @override
  State<UserProfileDetailScreen> createState() => _UserProfileDetailScreenState();
}

class _UserProfileDetailScreenState extends State<UserProfileDetailScreen> {
  // 0: Personal, 1: Business
  int _selectedTab = 0;
  BusinessModel? _apiUserBusiness;
  List<BusinessModel> _userBusinesses = [];
  int _selectedBusinessIndex = 0;
  bool _isLoadingBusinesses = false;

  @override
  void initState() {
    super.initState();
    _fetchUserBusiness();
  }

  Future<void> _fetchUserBusiness() async {
    setState(() => _isLoadingBusinesses = true);
    try {
      final res = await RemoteService.getUserBusinesses();
      if (res != null && (res['success'] == true || res['status'] == 200 || res['data'] != null || res is List)) {
        final data = res is List
            ? res
            : (res['data'] ?? res['businesses'] ?? res['listings'] ?? res['business']);
        List<BusinessModel> loaded = [];
        if (data is List && data.isNotEmpty) {
          loaded = data
              .map((b) => BusinessModel.fromJson(Map<String, dynamic>.from(b)))
              .toList();
        } else if (data is Map && data.isNotEmpty) {
          loaded = [BusinessModel.fromJson(Map<String, dynamic>.from(data))];
        }

        if (loaded.isNotEmpty) {
          if (mounted) {
            setState(() {
              _userBusinesses = loaded;
              // Default to the latest (last) business added as requested
              _selectedBusinessIndex = _userBusinesses.length - 1;
              _apiUserBusiness = _userBusinesses[_selectedBusinessIndex];
            });
          }
        }
      }
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() => _isLoadingBusinesses = false);
      }
    }
  }

  BusinessModel? _findMatchingBusiness(UserModel? user, BusinessController? bController) {
    if (user == null || bController == null) return null;

    final userCleanPhone = user.phoneNumber.replaceAll(RegExp(r'\D'), '');
    final userCleanName = user.name.trim().toLowerCase();
    final userCleanEmail = user.email.trim().toLowerCase();

    for (final b in bController.allBusinesses) {
      final bCleanPhone = b.phoneNumber.replaceAll(RegExp(r'\D'), '');
      if (bCleanPhone.isNotEmpty && userCleanPhone.isNotEmpty && bCleanPhone == userCleanPhone) {
        return b;
      }
      if (userCleanEmail.isNotEmpty && b.email.trim().toLowerCase() == userCleanEmail) {
        return b;
      }
      if (userCleanName.isNotEmpty && b.name.trim().toLowerCase() == userCleanName) {
        return b;
      }
      if (b.id == user.id) {
        return b;
      }
    }

    // Default fallback check for Darshan Pambhar
    if (userCleanName.contains('darshan')) {
      for (final b in bController.allBusinesses) {
        if (b.id == 'adv_darshan' || b.name.toLowerCase().contains('darshan')) {
          return b;
        }
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authController = Get.find<AuthController>();
    final businessController =
        Get.isRegistered<BusinessController>() ? Get.find<BusinessController>() : null;
    final favController =
        Get.isRegistered<FavoritesController>() ? Get.find<FavoritesController>() : null;

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
      final user = authController.currentUser.value;

      List<BusinessModel> effectiveBusinesses = List.from(_userBusinesses);
      if (effectiveBusinesses.isEmpty) {
        final fallback = _apiUserBusiness ?? _findMatchingBusiness(user, businessController);
        if (fallback != null) {
          effectiveBusinesses.add(fallback);
        }
      }

      final int currentIndex = effectiveBusinesses.isNotEmpty
          ? _selectedBusinessIndex.clamp(0, effectiveBusinesses.length - 1)
          : 0;

      final BusinessModel? activeBusiness =
          effectiveBusinesses.isNotEmpty ? effectiveBusinesses[currentIndex] : null;

      final displayName = user?.name.isNotEmpty == true
          ? user!.name
          : (activeBusiness?.name ?? 'Darshan Pambhar');

      final displaySpecialty = (_selectedTab == 1 && activeBusiness?.specialty.isNotEmpty == true)
          ? activeBusiness!.specialty
          : (activeBusiness?.specialty.isNotEmpty == true
              ? activeBusiness!.specialty
              : (activeBusiness?.category.isNotEmpty == true ? activeBusiness!.category : 'seller'));

      final displayPersonalPhone = user?.phoneNumber.isNotEmpty == true
          ? user!.phoneNumber
          : (activeBusiness?.displayPersonalPhone ?? '+91 9825033441');

      final displayPersonalEmail = user?.email.isNotEmpty == true
          ? user!.email
          : (activeBusiness?.displayPersonalEmail ?? 'darshan@gmail.com');

      final displayBusinessName = activeBusiness?.displayBusinessName.isNotEmpty == true
          ? activeBusiness!.displayBusinessName
          : displayName;

      final displayBusinessPhone = activeBusiness?.displayBusinessPhone.isNotEmpty == true
          ? activeBusiness!.displayBusinessPhone
          : displayPersonalPhone;

      final displayBusinessEmail = activeBusiness?.displayBusinessEmail.isNotEmpty == true
          ? activeBusiness!.displayBusinessEmail
          : displayPersonalEmail;

      final displayAddress = activeBusiness?.address.isNotEmpty == true
          ? activeBusiness!.address
          : (activeBusiness?.city.isNotEmpty == true
              ? '${activeBusiness!.city}${activeBusiness.state.isNotEmpty ? ', ${activeBusiness.state}' : ''}'
              : '123, Royal arcet,\nsarthana jagatnaka surat');

      final displayImageUrl = (user?.avatarUrl != null && user!.avatarUrl.isNotEmpty)
          ? user.avatarUrl
          : (activeBusiness?.imageUrl.isNotEmpty == true
              ? activeBusiness!.imageUrl
              : 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800&auto=format&fit=crop&q=80');

      final initials = displayName.trim().isNotEmpty
          ? displayName.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
          : 'DP';

      final businessId = activeBusiness?.id ?? user?.id ?? 'usr_current';
      final isFav = favController?.isFavorite(businessId) ?? false;

      final double latitude = (activeBusiness?.latitude != null && activeBusiness!.latitude != 0.0)
          ? activeBusiness.latitude
          : 21.2334;
      final double longitude = (activeBusiness?.longitude != null && activeBusiness!.longitude != 0.0)
          ? activeBusiness.longitude
          : 72.8634;

      return Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: Column(
            children: [
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
                          onPressed: () {
                            favController?.toggleFavorite(
                              businessId,
                              businessName: displayName,
                            );
                          },
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
                            name: displayName,
                            specialty: displaySpecialty,
                            address: displayAddress,
                            phone: displayPersonalPhone,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
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
                    ),
                  ],
                ),
              ),

              // Scrollable Profile Detail Content
              Expanded(
                child: RefreshIndicator(
                  color: textPrimary,
                  backgroundColor: cardBg,
                  onRefresh: () async {
                    await authController.fetchUserProfile();
                    await _fetchUserBusiness();
                    if (businessController != null) {
                      await businessController.fetchBusinesses();
                    }
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
                              imageUrl: displayImageUrl,
                              initials: initials,
                              size: 110,
                              isCircle: true,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // User Name (Centered)
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
                          // Profession / Category Subtitle (Centered)
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
                                _selectedTab == 1 ? displayBusinessPhone : displayPersonalPhone,
                              ),
                            ),

                            // 2. WhatsApp Button
                            _buildDetailActionButton(
                              iconWidget: Image.asset(
                                "assets/image/whatsapp.png",
                                height: 25,
                                width: 25,
                                errorBuilder: (context, error, stackTrace) => const Icon(
                                  Icons.chat_bubble_rounded,
                                  color: Color(0xFF25D366),
                                  size: 22,
                                ),
                              ),
                              label: 'WhatsApp',
                              circleBg: circleBtnBg,
                              borderColor: circleBtnBorder,
                              textColor: textPrimary,
                              onTap: () => AppLauncher.openWhatsApp(
                                _selectedTab == 1 ? displayBusinessPhone : displayPersonalPhone,
                              ),
                            ),

                            // // 3. Directions Button
                            // _buildDetailActionButton(
                            //   iconWidget: Transform.rotate(
                            //     angle: -0.7,
                            //     child: Icon(
                            //       Icons.send_rounded,
                            //       color: textPrimary,
                            //       size: 20,
                            //     ),
                            //   ),
                            //   label: 'Directions',
                            //   circleBg: circleBtnBg,
                            //   borderColor: circleBtnBorder,
                            //   textColor: textPrimary,
                            //   onTap: () => AppLauncher.openMap(
                            //     latitude,
                            //     longitude,
                            //     displayName,
                            //   ),
                            // ),

                            // 4. Save Button
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
                              onTap: () {
                                favController?.toggleFavorite(
                                  businessId,
                                  businessName: displayName,
                                );
                              },
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
                                        color: _selectedTab == 0 ? selectedTabText : unselectedTabText,
                                        fontWeight: _selectedTab == 0 ? FontWeight.w600 : FontWeight.w500,
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
                                        color: _selectedTab == 1 ? selectedTabText : unselectedTabText,
                                        fontWeight: _selectedTab == 1 ? FontWeight.w600 : FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (_selectedTab == 1) ...[
                          const SizedBox(height: 14),
                          if (effectiveBusinesses.isNotEmpty)
                            _buildBusinessHorizontalSelector(
                              businesses: effectiveBusinesses,
                              selectedIndex: currentIndex,
                              onSelect: (index) {
                                setState(() {
                                  _selectedBusinessIndex = index;
                                  _apiUserBusiness = effectiveBusinesses[index];
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
                                    phone: displayPersonalPhone,
                                    email: displayPersonalEmail,
                                    textPrimary: textPrimary,
                                    textSecondary: textSecondary,
                                  )
                                : (activeBusiness != null
                                    ? _buildBusinessTab(
                                        key: ValueKey('biz_${activeBusiness.id}_$currentIndex'),
                                        businessName: displayBusinessName,
                                        phone: displayBusinessPhone,
                                        email: displayBusinessEmail,
                                        address: displayAddress,
                                        description: activeBusiness.description,
                                        specialty: activeBusiness.specialty,
                                        specializations: activeBusiness.specializations,
                                        latitude: latitude,
                                        longitude: longitude,
                                        textPrimary: textPrimary,
                                        textSecondary: textSecondary,
                                        border: border,
                                        isDark: isDark,
                                        onTapHeader: () {
                                          if (activeBusiness.id.isNotEmpty) {
                                            Get.toNamed(AppRoutes.businessDetail, arguments: activeBusiness.id);
                                          }
                                        },
                                      )
                                    : _buildEmptyBusinessState(
                                        textPrimary: textPrimary,
                                        textSecondary: textSecondary,
                                        cardBg: cardBg,
                                        border: border,
                                        isDark: isDark,
                                      )),
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

  // Personal Tab View
  Widget _buildPersonalTab({
    required String phone,
    required String email,
    required Color textPrimary,
    required Color textSecondary,
  }) {
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
          text: phone,
          onTap: () => AppLauncher.makePhoneCall(phone),
          textPrimary: textPrimary,
          textSecondary: textSecondary,
        ),
        const SizedBox(height: 16),

        // Email Row
        _buildContactRow(
          icon: Icons.mail_outline_rounded,
          text: email,
          onTap: () => AppLauncher.sendEmail(email),
          textPrimary: textPrimary,
          textSecondary: textSecondary,
        ),
      ],
    );
  }

  // Business Horizontal Selector Bar
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
            // InkWell(
            //   onTap: () async {
            //     await Get.toNamed(AppRoutes.createBusiness);
            //     _fetchUserBusiness();
            //   },
            //   borderRadius: BorderRadius.circular(8),
            //   child: Padding(
            //     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            //     child: Row(
            //       children: [
            //         Icon(
            //           Icons.add_circle_outline_rounded,
            //           size: 15,
            //           color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
            //         ),
            //         const SizedBox(width: 4),
            //         Text(
            //           'Add Business',
            //           style: TextStyle(
            //             fontSize: 12.5,
            //             fontWeight: FontWeight.w700,
            //             color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 66,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: businesses.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              if (index == businesses.length) {
                // "+ Add Business" quick card at the end
                return GestureDetector(
                  onTap: () async {
                    await Get.toNamed(AppRoutes.createBusiness);
                    _fetchUserBusiness();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF142032).withValues(alpha: 0.6)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? const Color(0xFF22354E) : const Color(0xFFCBD5E1),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_rounded,
                          size: 20,
                          color: textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Add Business',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

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

  Widget _buildEmptyBusinessState({
    required Color textPrimary,
    required Color textSecondary,
    required Color cardBg,
    required Color border,
    required bool isDark,
  }) {
    return Column(
      key: const ValueKey('empty_business_state'),
      children: [
        const SizedBox(height: 12),
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2D44) : const Color(0xFFEFF6FF),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.storefront_rounded,
            size: 32,
            color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'No Business Listed Yet',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Create a business listing to showcase your services, contact information, and address here.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: textSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () async {
            await Get.toNamed(AppRoutes.createBusiness);
            _fetchUserBusiness();
          },
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Create Business'),
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? const Color(0xFF2563EB) : const Color(0xFF0F172A),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // Business Tab View
  Widget _buildBusinessTab({
    Key? key,
    required String businessName,
    required String phone,
    required String email,
    required String address,
    required String description,
    String specialty = '',
    List<String> specializations = const [],
    required double latitude,
    required double longitude,
    required Color textPrimary,
    required Color textSecondary,
    required Color border,
    required bool isDark,
    VoidCallback? onTapHeader,
  }) {
    final bool hasDescription = description.trim().isNotEmpty;
    final String specialtyText = specialty.trim();
    final bool hasSpecialty = specialtyText.isNotEmpty;

    final List<String> cleanSpecializations = specializations
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
      key: key ?? const ValueKey('business_tab'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Business Name Row with Building Icon & Arrow
        InkWell(
          onTap: onTapHeader,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
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
                        businessName,
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
          ),
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
          text: phone,
          onTap: () => AppLauncher.makePhoneCall(phone),
          textPrimary: textPrimary,
          textSecondary: textSecondary,
        ),
        const SizedBox(height: 14),

        // Email Row
        _buildContactRow(
          icon: Icons.mail_outline_rounded,
          text: email,
          onTap: () => AppLauncher.sendEmail(email),
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
                      address,
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

            // Mini Map Preview
            GestureDetector(
              onTap: () => AppLauncher.openMap(latitude, longitude, businessName),
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
                      painter: _ProfileMiniMapPainter(isDark: isDark),
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
            ),
          ],
        ),

        // Description Section
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

class _ProfileMiniMapPainter extends CustomPainter {
  final bool isDark;
  _ProfileMiniMapPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..color = isDark ? const Color(0xFF1E2836) : const Color(0xFFE8EEF5);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final minorRoadPaint = Paint()
      ..color = isDark ? const Color(0xFF283648) : const Color(0xFFD4DFEE)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;

    final minorPath = Path();
    minorPath.moveTo(0, size.height * 0.75);
    minorPath.lineTo(size.width, size.height * 0.3);
    canvas.drawPath(minorPath, minorRoadPaint);

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
  bool shouldRepaint(covariant _ProfileMiniMapPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
