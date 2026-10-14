import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/themes/app_colors.dart';
import 'splash_controller.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),

            // Visual Logos matching the uploaded brand assets
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/image/rotary_logo.png',
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 16),
                  Image.asset(
                    'assets/image/rotaract_logo.png',
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // App Name with Rotary Blue & Rotaract Pink
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'Rotary ',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.rotaryBlue,
                      letterSpacing: -0.5,
                    ),
                  ),
                  TextSpan(
                    text: '& Rotaract',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.rotaractPink,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Tagline
            Text(
              'Find Trusted Professionals\nNear You',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: textSecondary,
                height: 1.35,
              ),
            ),

            const Spacer(flex: 3),

            // Bottom loading indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100),
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.lightBorder,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: AnimatedBuilder(
                  animation: controller.progressAnimation,
                  builder: (context, child) {
                    return FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: controller.progressAnimation.value,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.rotaryBlue,
                              AppColors.rotaractPink,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class SplashLogoPainter extends CustomPainter {
  final bool isDark;
  SplashLogoPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 - 10);

    // Draw perspective isometric grid mesh
    final gridPaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.12)
          : const Color(0xFF111111).withValues(alpha: 0.08)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final planeY = center.dy + 45;
    // Horizontal lines
    for (int i = 0; i <= 5; i++) {
      final y = planeY + i * 14.0;
      final xSpan = 40.0 + i * 22.0;
      canvas.drawLine(
        Offset(center.dx - xSpan, y),
        Offset(center.dx + xSpan, y),
        gridPaint,
      );
    }
    // Radial perspective lines
    for (int i = -4; i <= 4; i++) {
      final startX = center.dx + i * 12.0;
      final endX = center.dx + i * 35.0;
      canvas.drawLine(
        Offset(startX, planeY),
        Offset(endX, planeY + 70),
        gridPaint,
      );
    }

    // Glow effect behind the pin
    if (isDark) {
      final glowPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 36);
      canvas.drawCircle(Offset(center.dx, center.dy - 10), 55, glowPaint);
    }

    // Outer Pin Gradient Path
    final pinWidth = 84.0;
    final pinHeight = 110.0;
    final pinTop = center.dy - 68;

    final pinPath = Path();
    pinPath.moveTo(center.dx, pinTop + pinHeight); // bottom point
    // Right curve up to head
    pinPath.cubicTo(
      center.dx + pinWidth * 0.45,
      pinTop + pinHeight * 0.65,
      center.dx + pinWidth * 0.55,
      pinTop + pinHeight * 0.35,
      center.dx + pinWidth * 0.5,
      pinTop + pinHeight * 0.25,
    );
    // Arc round top
    pinPath.arcToPoint(
      Offset(center.dx - pinWidth * 0.5, pinTop + pinHeight * 0.25),
      radius: Radius.circular(pinWidth * 0.5),
      clockwise: false,
    );
    // Left curve back to point
    pinPath.cubicTo(
      center.dx - pinWidth * 0.55,
      pinTop + pinHeight * 0.35,
      center.dx - pinWidth * 0.45,
      pinTop + pinHeight * 0.65,
      center.dx,
      pinTop + pinHeight,
    );
    pinPath.close();

    final pinPaint = Paint()
      ..shader = LinearGradient(
        colors: isDark
            ? [
                const Color(0xFFFFFFFF),
                const Color(0xFFD4D4D8),
                const Color(0xFFA1A1AA),
              ]
            : [
                const Color(0xFF2A2A2A),
                const Color(0xFF111111),
                const Color(0xFF000000),
              ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(center.dx - 50, pinTop, 100, pinHeight));

    canvas.drawPath(pinPath, pinPaint);

    // Inner Circle cutout / core
    final innerCircleCenter = Offset(center.dx, pinTop + 38);
    final innerCirclePaint = Paint()
      ..color = isDark ? const Color(0xFF121214) : Colors.white;
    canvas.drawCircle(innerCircleCenter, 24, innerCirclePaint);

    // Business / Storefront icon inside the pin
    final storePaint = Paint()
      ..color = isDark ? Colors.white : const Color(0xFF111111)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final storeFill = Paint()
      ..color = isDark ? Colors.white : const Color(0xFF111111)
      ..style = PaintingStyle.fill;

    // Awning Roof
    final roofPath = Path();
    roofPath.moveTo(innerCircleCenter.dx - 12, innerCircleCenter.dy - 3);
    roofPath.lineTo(innerCircleCenter.dx + 12, innerCircleCenter.dy - 3);
    roofPath.lineTo(innerCircleCenter.dx + 15, innerCircleCenter.dy + 3);
    roofPath.lineTo(innerCircleCenter.dx - 15, innerCircleCenter.dy + 3);
    roofPath.close();
    canvas.drawPath(roofPath, storeFill);

    // Store Walls & Door
    final wallPath = Path();
    wallPath.moveTo(innerCircleCenter.dx - 11, innerCircleCenter.dy + 3);
    wallPath.lineTo(innerCircleCenter.dx - 11, innerCircleCenter.dy + 12);
    wallPath.lineTo(innerCircleCenter.dx + 11, innerCircleCenter.dy + 12);
    wallPath.lineTo(innerCircleCenter.dx + 11, innerCircleCenter.dy + 3);
    canvas.drawPath(wallPath, storePaint);

    // Center Door
    canvas.drawRect(
      Rect.fromLTWH(innerCircleCenter.dx - 3.5, innerCircleCenter.dy + 5, 7, 7),
      storePaint,
    );
  }

  @override
  bool shouldRepaint(covariant SplashLogoPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
