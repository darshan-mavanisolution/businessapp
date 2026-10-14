import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/themes/app_colors.dart';
import '../home/home_controller.dart';

import '../../core/services/remote_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'New Specialist in Surat!',
      'subtitle': 'Dr. Mehul Desai (Cardiologist) is now available for appointments on Ghod Dod Road.',
      'time': '10 mins ago',
      'unread': true,
    },
    {
      'title': 'Exclusive Dining Discount',
      'subtitle': 'Enjoy 20% off your next dinner at The Grand Heritage this weekend.',
      'time': '2 hours ago',
      'unread': true,
    },
    {
      'title': 'Welcome to BizFinder',
      'subtitle': 'Discover trusted doctors, salons, gyms, and local services near you.',
      'time': 'Yesterday',
      'unread': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future _fetchNotifications() async {
    var res = await RemoteService.getNotifications();
    print("getNotifications in UI Res--------->>>> $res");
    if (res != null && (res['success'] == true || res['status'] == 200)) {
      final list = (res['data'] ?? res['notifications'] ?? res) as List?;
      if (list != null && list.isNotEmpty) {
        setState(() {
          _notifications.clear();
          _notifications.addAll(list.map((item) => Map<String, dynamic>.from(item)));
        });
      }
    }
  }

  void _markAllRead() async {
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().markNotificationsAsRead();
    }
    await RemoteService.markNotificationsRead();
    setState(() {
      for (final n in _notifications) {
        n['unread'] = false;
        n['isRead'] = true;
      }
    });
    Get.snackbar(
      'Updated',
      'All notifications marked as read',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _markAllRead,
            child: Text(
              'Mark all read',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: _notifications.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = _notifications[index];
            final unread = item['unread'] == true;

            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: unread
                      ? (isDark
                          ? Colors.white.withValues(alpha: 0.6)
                          : Colors.black.withValues(alpha: 0.4))
                      : border,
                  width: unread ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF222224) : const Color(0xFFF1F3F6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.notifications_active_outlined,
                      color: isDark ? Colors.white : Colors.black,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item['title']?.toString() ?? 'Notification',
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: textPrimary,
                                ),
                              ),
                            ),
                            Text(
                              item['time']?.toString() ?? 'Just now',
                              style: TextStyle(
                                fontSize: 11,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          item['subtitle']?.toString() ?? '',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: textSecondary,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
