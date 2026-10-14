import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/themes/app_colors.dart';
import '../../core/utils/app_launcher.dart';
import '../business_listing/business_controller.dart';

class LocationScreen extends StatelessWidget {
  const LocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final businessController = Get.find<BusinessController>();

    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Obx(() {
      final business = businessController.selectedBusiness.value;
      final name = business?.name ?? 'Dr. Jignesh Patel';
      final specialty = business?.specialty ?? 'General Physician';
      final address = business?.address ?? '123, City Light Road, Surat, Gujarat - 395007';
      final lat = business?.latitude ?? 21.1702;
      final lng = business?.longitude ?? 72.8311;

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
            'Location',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            // Full Screen Interactive Map Painter
            Positioned.fill(
              child: CustomPaint(
                painter: CityMapPainter(
                  isDark: isDark,
                  selectedName: name,
                  selectedSpecialty: specialty,
                ),
              ),
            ),

            // Bottom Floating Card
            Positioned(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).padding.bottom + 16,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: border, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Address Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF192536) : const Color(0xFFF1F3F6),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.location_on_rounded,
                            size: 20,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                address,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: textPrimary,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Open in Google Maps Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => AppLauncher.openMap(lat, lng, name),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? const Color(0xFF141F2E) : const Color(0xFF111111),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                            side: BorderSide(
                              color: isDark ? const Color(0xFF26374D) : Colors.transparent,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.map_rounded,
                              color: Color(0xFF4285F4),
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Open in Google Maps',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
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
      );
    });
  }
}

class CityMapPainter extends CustomPainter {
  final bool isDark;
  final String selectedName;
  final String selectedSpecialty;

  CityMapPainter({
    required this.isDark,
    required this.selectedName,
    required this.selectedSpecialty,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background land color
    final landPaint = Paint()
      ..color = isDark ? const Color(0xFF0F1823) : const Color(0xFFEDF1F5);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), landPaint);

    // City blocks / parks
    final blockPaint = Paint()
      ..color = isDark ? const Color(0xFF142030) : const Color(0xFFE5E9EE);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(20, 80, size.width * 0.38, 120),
        const Radius.circular(8),
      ),
      blockPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.55, 60, size.width * 0.38, 140),
        const Radius.circular(8),
      ),
      blockPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(30, 240, size.width * 0.3, 160),
        const Radius.circular(8),
      ),
      blockPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.45, 270, size.width * 0.45, 130),
        const Radius.circular(8),
      ),
      blockPaint,
    );

    // Main road networks
    final roadPaint = Paint()
      ..color = isDark ? const Color(0xFF223247) : const Color(0xFFFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final highwayPaint = Paint()
      ..color = isDark ? const Color(0xFF2C3E56) : const Color(0xFFFCFDFE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;

    // Highway diagonal
    final hwPath = Path();
    hwPath.moveTo(-20, size.height * 0.25);
    hwPath.lineTo(size.width + 20, size.height * 0.7);
    canvas.drawPath(hwPath, highwayPaint);

    // Cross arterial roads
    final road1 = Path();
    road1.moveTo(size.width * 0.35, -20);
    road1.lineTo(size.width * 0.32, size.height + 20);
    canvas.drawPath(road1, roadPaint);

    final road2 = Path();
    road2.moveTo(size.width * 0.75, -20);
    road2.lineTo(size.width * 0.68, size.height + 20);
    canvas.drawPath(road2, roadPaint);

    final road3 = Path();
    road3.moveTo(-20, size.height * 0.52);
    road3.lineTo(size.width + 20, size.height * 0.48);
    canvas.drawPath(road3, roadPaint);

    // Road label text: "City Light Rd", "Sarthana Jakatnaka"
    final textStyle = TextStyle(
      color: isDark ? const Color(0xFF6B7E98) : const Color(0xFF8A99AC),
      fontSize: 10,
      fontWeight: FontWeight.w600,
    );

    _drawText(canvas, 'City Light Rd', Offset(size.width * 0.15, size.height * 0.34), textStyle, angle: 0.38);
    _drawText(canvas, 'City Light Rd', Offset(size.width * 0.70, size.height * 0.58), textStyle, angle: 0.38);
    _drawText(canvas, 'Sarthana Jakatnaka', Offset(size.width * 0.35, 110), textStyle);

    // VR Surat Secondary Marker (Blue Pin)
    final vrPoint = Offset(size.width * 0.55, size.height * 0.52);
    _drawPin(canvas, vrPoint, const Color(0xFF3B82F6));
    _drawText(
      canvas,
      'VR Surat',
      Offset(vrPoint.dx + 16, vrPoint.dy - 6),
      TextStyle(
        color: isDark ? Colors.white : const Color(0xFF111111),
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    );

    // Primary Selected Business Marker (Red Pin with info callout)
    final mainPinPoint = Offset(size.width * 0.50, size.height * 0.40);

    // Pin pulse glow
    final pulsePaint = Paint()
      ..color = const Color(0xFFEF4444).withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(mainPinPoint, 18, pulsePaint);

    _drawPin(canvas, mainPinPoint, const Color(0xFFEF4444));

    // Callout Box for main pin
    final calloutX = mainPinPoint.dx + 16;
    final calloutY = mainPinPoint.dy - 20;

    _drawText(
      canvas,
      selectedName,
      Offset(calloutX, calloutY),
      TextStyle(
        color: isDark ? Colors.white : const Color(0xFF111111),
        fontSize: 12,
        fontWeight: FontWeight.w800,
      ),
    );
    _drawText(
      canvas,
      selectedSpecialty,
      Offset(calloutX, calloutY + 14),
      TextStyle(
        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  void _drawPin(Canvas canvas, Offset point, Color color) {
    final pinPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(point.dx, point.dy + 8);
    path.cubicTo(point.dx + 8, point.dy + 3, point.dx + 8, point.dy - 6, point.dx, point.dy - 10);
    path.cubicTo(point.dx - 8, point.dy - 6, point.dx - 8, point.dy + 3, point.dx, point.dy + 8);
    canvas.drawPath(path, pinPaint);

    final whiteCircle = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(point.dx, point.dy - 4), 3, whiteCircle);
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style, {double angle = 0}) {
    final span = TextSpan(text: text, style: style);
    final tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    if (angle != 0) {
      canvas.rotate(angle);
    }
    tp.paint(canvas, Offset.zero);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CityMapPainter oldDelegate) =>
      oldDelegate.isDark != isDark ||
      oldDelegate.selectedName != selectedName ||
      oldDelegate.selectedSpecialty != selectedSpecialty;
}
