import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../app/routes/app_routes.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;

  final List<OnboardingItem> items = const [
    OnboardingItem(
      badge: 'LOCAL DISCOVERY',
      title: 'Discover Trusted\nProfessionals & Services',
      description:
          'Find top-rated doctors, advocates, retailers, and certified business experts near your area with smart location & sector filtering.',
      tag: 'Surat & Gujarat Directory',
    ),
    OnboardingItem(
      badge: 'INSTANT CONNECT',
      title: 'Connect Directly\nWith One Tap',
      description:
          'Get instant access to phone calls, WhatsApp chat, office directions, and business portfolios with zero middlemen.',
      tag: 'Call & WhatsApp Direct',
    ),
    OnboardingItem(
      badge: 'GROW NETWORK',
      title: 'Promote & Grow\nYour Own Enterprise',
      description:
          'List your businesses, showcase multiple services, gain trusted reviews, and expand your reach across thriving business communities.',
      tag: 'Multi-Business Profiles',
    ),
  ];

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void nextPage() {
    if (currentPage.value < items.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    } else {
      completeOnboarding();
    }
  }

  void skip() {
    completeOnboarding();
  }

  void completeOnboarding() {
    final storage = GetStorage();
    storage.write('hasSeenOnboarding', true);
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}

class OnboardingItem {
  final String badge;
  final String title;
  final String description;
  final String tag;

  const OnboardingItem({
    required this.badge,
    required this.title,
    required this.description,
    required this.tag,
  });
}
