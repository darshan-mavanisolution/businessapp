import 'package:flutter/material.dart';

class OnboardingGraphic extends StatelessWidget {
  final int pageIndex;
  final bool isDark;

  const OnboardingGraphic({
    super.key,
    required this.pageIndex,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final imagePath = _getImagePath(pageIndex);

    return SizedBox(
      height: 300,
      width: double.infinity,
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.5)
                    : const Color(0xFF0F172A).withValues(alpha: 0.08),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Image.asset(
              imagePath,
              height: 290,
              width: 290,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      ),
    );
  }

  String _getImagePath(int index) {
    switch (index) {
      case 0:
        return 'assets/image/onboarding_1.png';
      case 1:
        return 'assets/image/onboarding_2.png';
      case 2:
      default:
        return 'assets/image/onboarding_3.png';
    }
  }
}
