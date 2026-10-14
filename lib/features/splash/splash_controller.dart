import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../app/routes/app_routes.dart';

class SplashController extends GetxController with GetSingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> progressAnimation;

  @override
  void onInit() {
    super.onInit();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
    );

    animationController.forward();

    Timer(const Duration(milliseconds: 2600), () {
      final storage = GetStorage();
      final isLoggedIn = storage.read<bool>('isLoggedIn') ?? false;
      final hasSeenOnboarding = storage.read<bool>('hasSeenOnboarding') ?? false;
      if (isLoggedIn) {
        Get.offAllNamed(AppRoutes.mainNav);
      } else if (!hasSeenOnboarding) {
        Get.offAllNamed(AppRoutes.onboarding);
      } else {
        Get.offAllNamed(AppRoutes.login);
      }
    });
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }
}
