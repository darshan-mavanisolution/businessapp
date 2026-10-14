import 'package:flutter/material.dart';

class CategoryIllustration extends StatelessWidget {
  final String categoryId;
  final String imageUrl;
  final double size;

  const CategoryIllustration({
    super.key,
    required this.categoryId,
    required this.imageUrl,
    this.size = 76,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildCustomVectorFallback(categoryId, size),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildCustomVectorFallback(categoryId, size);
        },
      ),
    );
  }

  Widget _buildCustomVectorFallback(String id, double s) {
    return CustomPaint(
      size: Size(s, s),
      painter: CategoryVectorPainter(categoryId: id),
    );
  }
}

class CategoryVectorPainter extends CustomPainter {
  final String categoryId;
  CategoryVectorPainter({required this.categoryId});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    switch (categoryId.toLowerCase()) {
      case 'advocate':
        _drawScalesOfJustice(canvas, center, size);
        break;
      case 'hotel':
        _drawHotelBuilding(canvas, center, size);
        break;
      case 'restaurant':
        _drawPastaDish(canvas, center, size);
        break;
      case 'electronics':
        _drawElectronics(canvas, center, size);
        break;
      case 'education':
        _drawGraduationBooks(canvas, center, size);
        break;
      case 'doctor':
        _drawDoctorIcon(canvas, center, size);
        break;
      case 'salon':
        _drawSalonIcon(canvas, center, size);
        break;
      case 'gym':
        _drawGymIcon(canvas, center, size);
        break;
      default:
        _drawDefaultIcon(canvas, center, size);
    }
  }

  void _drawScalesOfJustice(Canvas canvas, Offset center, Size size) {
    final goldPaint = Paint()
      ..color = const Color(0xFFC89332)
      ..style = PaintingStyle.fill;
    final goldStroke = Paint()
      ..color = const Color(0xFF9E701C)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Pillar
    canvas.drawLine(
      Offset(center.dx, center.dy - 18),
      Offset(center.dx, center.dy + 16),
      goldStroke..strokeWidth = 3,
    );
    // Base
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx, center.dy + 18), width: 24, height: 6),
      goldPaint,
    );
    // Crossbeam
    canvas.drawLine(
      Offset(center.dx - 20, center.dy - 14),
      Offset(center.dx + 20, center.dy - 14),
      goldStroke..strokeWidth = 2.5,
    );
    // Left scale pan
    canvas.drawLine(Offset(center.dx - 20, center.dy - 14), Offset(center.dx - 26, center.dy), goldStroke..strokeWidth = 1.2);
    canvas.drawLine(Offset(center.dx - 20, center.dy - 14), Offset(center.dx - 14, center.dy), goldStroke..strokeWidth = 1.2);
    canvas.drawArc(Rect.fromCenter(center: Offset(center.dx - 20, center.dy), width: 14, height: 8), 0, 3.14, false, goldPaint);

    // Right scale pan
    canvas.drawLine(Offset(center.dx + 20, center.dy - 14), Offset(center.dx + 14, center.dy), goldStroke..strokeWidth = 1.2);
    canvas.drawLine(Offset(center.dx + 20, center.dy - 14), Offset(center.dx + 26, center.dy), goldStroke..strokeWidth = 1.2);
    canvas.drawArc(Rect.fromCenter(center: Offset(center.dx + 20, center.dy), width: 14, height: 8), 0, 3.14, false, goldPaint);
  }

  void _drawHotelBuilding(Canvas canvas, Offset center, Size size) {
    final buildingPaint = Paint()..color = const Color(0xFF5A728E);
    final windowPaint = Paint()..color = const Color(0xFFFDE68A);

    // Modern glass hotel tower
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 34, height: 42),
      const Radius.circular(3),
    );
    canvas.drawRRect(rect, buildingPaint);

    // Windows grid
    for (int r = 0; r < 4; r++) {
      for (int c = 0; c < 3; c++) {
        canvas.drawRect(
          Rect.fromLTWH(center.dx - 13 + c * 9.0, center.dy - 16 + r * 8.0, 6, 5),
          windowPaint,
        );
      }
    }
  }

  void _drawPastaDish(Canvas canvas, Offset center, Size size) {
    // Bowl
    final bowlPaint = Paint()..color = const Color(0xFFE2E8F0);
    canvas.drawCircle(center, 22, bowlPaint);

    // Pasta yellow
    final pastaPaint = Paint()..color = const Color(0xFFFBBF24);
    canvas.drawCircle(center, 18, pastaPaint);

    // Tomato sauce red
    final saucePaint = Paint()..color = const Color(0xFFDC2626);
    canvas.drawCircle(Offset(center.dx, center.dy - 1), 10, saucePaint);

    // Basil leaf green
    final leafPaint = Paint()..color = const Color(0xFF16A34A);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx, center.dy - 5), width: 6, height: 4),
      leafPaint,
    );
  }

  void _drawElectronics(Canvas canvas, Offset center, Size size) {
    // Laptop
    final laptopPaint = Paint()..color = const Color(0xFF334155);
    final screenPaint = Paint()..color = const Color(0xFF38BDF8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(center.dx + 2, center.dy - 2), width: 32, height: 20),
        const Radius.circular(2),
      ),
      laptopPaint,
    );
    canvas.drawRect(
      Rect.fromCenter(center: Offset(center.dx + 2, center.dy - 2), width: 26, height: 15),
      screenPaint,
    );
    // Base
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(center.dx + 2, center.dy + 10), width: 38, height: 4),
        const Radius.circular(2),
      ),
      laptopPaint,
    );

    // Smartphone on left
    final phonePaint = Paint()..color = const Color(0xFF0F172A);
    final phoneScreen = Paint()..color = const Color(0xFF818CF8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(center.dx - 12, center.dy + 4), width: 10, height: 18),
        const Radius.circular(2),
      ),
      phonePaint,
    );
    canvas.drawRect(
      Rect.fromCenter(center: Offset(center.dx - 12, center.dy + 4), width: 8, height: 15),
      phoneScreen,
    );
  }

  void _drawGraduationBooks(Canvas canvas, Offset center, Size size) {
    // Stack of 3 books
    final colors = [const Color(0xFF3B82F6), const Color(0xFFEF4444), const Color(0xFFF59E0B)];
    for (int i = 0; i < 3; i++) {
      final y = center.dy + 6 + i * 5.0;
      final bookPaint = Paint()..color = colors[i];
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(center.dx, y), width: 34 - i * 2.0, height: 5),
          const Radius.circular(1.5),
        ),
        bookPaint,
      );
    }

    // Mortarboard Cap (black diamond top)
    final capPaint = Paint()..color = const Color(0xFF1E293B);
    final path = Path();
    path.moveTo(center.dx, center.dy - 16);
    path.lineTo(center.dx + 18, center.dy - 7);
    path.lineTo(center.dx, center.dy + 2);
    path.lineTo(center.dx - 18, center.dy - 7);
    path.close();
    canvas.drawPath(path, capPaint);

    // Tassel
    final tasselPaint = Paint()
      ..color = const Color(0xFFEAB308)
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(center.dx, center.dy - 7), Offset(center.dx + 14, center.dy + 1), tasselPaint);
  }

  void _drawDoctorIcon(Canvas canvas, Offset center, Size size) {
    final coatPaint = Paint()..color = const Color(0xFFE2E8F0);
    final tiePaint = Paint()..color = const Color(0xFF2563EB);
    final stethPaint = Paint()
      ..color = const Color(0xFF64748B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Body
    canvas.drawCircle(Offset(center.dx, center.dy - 7), 9, Paint()..color = const Color(0xFFFBCFE8));
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(center.dx - 14, center.dy + 4, 28, 20), const Radius.circular(8)),
      coatPaint,
    );
    // Tie
    canvas.drawRect(Rect.fromLTWH(center.dx - 2, center.dy + 4, 4, 8), tiePaint);
    // Stethoscope loop
    canvas.drawArc(Rect.fromCenter(center: Offset(center.dx, center.dy + 8), width: 14, height: 12), 0, 3.14, false, stethPaint);
  }

  void _drawSalonIcon(Canvas canvas, Offset center, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFEC4899)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    // Scissors
    canvas.drawLine(Offset(center.dx - 10, center.dy - 10), Offset(center.dx + 10, center.dy + 10), paint);
    canvas.drawLine(Offset(center.dx - 10, center.dy + 10), Offset(center.dx + 10, center.dy - 10), paint);
    canvas.drawCircle(Offset(center.dx - 10, center.dy - 10), 3.5, paint);
    canvas.drawCircle(Offset(center.dx - 10, center.dy + 10), 3.5, paint);
  }

  void _drawGymIcon(Canvas canvas, Offset center, Size size) {
    final paint = Paint()..color = const Color(0xFF10B981);
    // Dumbbell bar
    canvas.drawRect(Rect.fromCenter(center: center, width: 28, height: 4), paint);
    // Weights
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(center.dx - 12, center.dy), width: 6, height: 20), const Radius.circular(2)), paint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(center.dx + 12, center.dy), width: 6, height: 20), const Radius.circular(2)), paint);
  }

  void _drawDefaultIcon(Canvas canvas, Offset center, Size size) {
    canvas.drawCircle(center, 12, Paint()..color = Colors.blueGrey);
  }

  @override
  bool shouldRepaint(covariant CategoryVectorPainter oldDelegate) =>
      oldDelegate.categoryId != categoryId;
}
