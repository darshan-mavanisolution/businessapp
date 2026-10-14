import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/themes/app_colors.dart';
import 'auth_controller.dart';

class OtpVerificationScreen extends GetView<AuthController> {
  const OtpVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final boxBg = isDark ? AppColors.darkSecondary : AppColors.lightSecondary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final keypadBtnBg = isDark ? const Color(0xFF0F1824) : const Color(0xFFF7F8FA);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Back Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_rounded,
                        color: textPrimary, size: 20),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Email illustration with verification badge
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 90,
                      height: 100,
                      child: CustomPaint(
                        painter: OtpEmailPainter(isDark: isDark),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Verify OTP Title
                    Text(
                      'Verify OTP',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Destination info
                    Column(
                      children: [
                        Text(
                          'We have sent a 6-digit code to',
                          style: TextStyle(
                            fontSize: 13.5,
                            color: textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          controller.emailController.text.trim().isNotEmpty
                              ? controller.emailController.text.trim()
                              : 'your email address',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // 6 OTP Input Boxes
                    Obx(() {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (index) {
                          final digit = controller.otpDigits[index];
                          final isFilled = digit.isNotEmpty;
                          final isCurrent = index == controller.currentOtpIndex.value;

                          return Container(
                            width: 46,
                            height: 52,
                            decoration: BoxDecoration(
                              color: boxBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isFilled || isCurrent
                                    ? (isDark ? Colors.white : Colors.black)
                                    : borderColor,
                                width: isFilled || isCurrent ? 1.5 : 1.0,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              digit,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: textPrimary,
                              ),
                            ),
                          );
                        }),
                      );
                    }),

                    const SizedBox(height: 22),

                    // Resend Code Countdown
                    Obx(() {
                      final count = controller.resendCountdown.value;
                      final canResend = controller.canResend.value;
                      final minStr = (count ~/ 60).toString().padLeft(2, '0');
                      final secStr = (count % 60).toString().padLeft(2, '0');

                      return GestureDetector(
                        onTap: canResend ? () => controller.startResendTimer() : null,
                        child: Text.rich(
                          TextSpan(
                            text: "Didn't receive code? ",
                            style: TextStyle(
                              fontSize: 13,
                              color: textSecondary,
                            ),
                            children: [
                              TextSpan(
                                text: canResend
                                    ? 'Resend'
                                    : 'Resend ($minStr:$secStr)',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: canResend
                                      ? (isDark ? Colors.white : Colors.black)
                                      : textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Custom Numeric Keypad
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                children: [
                  _buildKeypadRow(['1', '2', '3'], keypadBtnBg, textPrimary),
                  const SizedBox(height: 10),
                  _buildKeypadRow(['4', '5', '6'], keypadBtnBg, textPrimary),
                  const SizedBox(height: 10),
                  _buildKeypadRow(['7', '8', '9'], keypadBtnBg, textPrimary),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // Empty placeholder
                      const Expanded(child: SizedBox(height: 54)),
                      const SizedBox(width: 14),
                      // Digit 0
                      Expanded(
                        child: _buildKeypadButton('0', keypadBtnBg, textPrimary, () {
                          controller.enterDigit('0');
                        }),
                      ),
                      const SizedBox(width: 14),
                      // Backspace Button
                      Expanded(
                        child: _buildKeypadIconButton(
                          Icons.backspace_outlined,
                          keypadBtnBg,
                          textPrimary,
                          () => controller.deleteDigit(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypadRow(
      List<String> digits, Color bg, Color textColor) {
    return Row(
      children: digits.map((d) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7),
            child: _buildKeypadButton(d, bg, textColor, () {
              controller.enterDigit(d);
            }),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildKeypadButton(
      String label, Color bg, Color textColor, VoidCallback onTap) {
    return SizedBox(
      height: 54,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeypadIconButton(
      IconData icon, Color bg, Color textColor, VoidCallback onTap) {
    return SizedBox(
      height: 54,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Center(
            child: Icon(icon, color: textColor, size: 22),
          ),
        ),
      ),
    );
  }
}

class OtpEmailPainter extends CustomPainter {
  final bool isDark;
  OtpEmailPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final mailPaint = Paint()
      ..color = isDark ? Colors.white : const Color(0xFF111111)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    // Envelope outline
    final mailRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(center.dx, center.dy - 2), width: 62, height: 44),
      const Radius.circular(8),
    );
    canvas.drawRRect(mailRect, mailPaint);

    // Flap lines
    final flapPath = Path()
      ..moveTo(center.dx - 31, center.dy - 24)
      ..lineTo(center.dx, center.dy + 1)
      ..lineTo(center.dx + 31, center.dy - 24);
    canvas.drawPath(flapPath, mailPaint);

    // Subtle bottom fold lines
    final foldPaint = Paint()
      ..color = (isDark ? Colors.white : const Color(0xFF111111)).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    final foldPath = Path()
      ..moveTo(center.dx - 31, center.dy + 20)
      ..lineTo(center.dx - 10, center.dy - 2)
      ..moveTo(center.dx + 31, center.dy + 20)
      ..lineTo(center.dx + 10, center.dy - 2);
    canvas.drawPath(foldPath, foldPaint);

    // Verified badge on bottom right
    final badgeCenter = Offset(center.dx + 23, center.dy + 16);
    final badgePaint = Paint()
      ..color = isDark ? const Color(0xFF1E1E20) : Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(badgeCenter, 11, badgePaint);

    final badgeBorder = Paint()
      ..color = isDark ? Colors.white : const Color(0xFF111111)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(badgeCenter, 11, badgeBorder);

    // Checkmark inside badge
    final checkPaint = Paint()
      ..color = isDark ? Colors.white : const Color(0xFF111111)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(badgeCenter.dx - 4, badgeCenter.dy),
        Offset(badgeCenter.dx - 1, badgeCenter.dy + 3), checkPaint);
    canvas.drawLine(Offset(badgeCenter.dx - 1, badgeCenter.dy + 3),
        Offset(badgeCenter.dx + 4, badgeCenter.dy - 3), checkPaint);
  }

  @override
  bool shouldRepaint(covariant OtpEmailPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
