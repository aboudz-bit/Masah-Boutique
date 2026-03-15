import 'package:flutter/material.dart';
import '../main.dart';

// ---------------------------------------------------------------------------
// AbayaIcon -- flowing abaya silhouette
// ---------------------------------------------------------------------------
class AbayaIcon extends StatelessWidget {
  final double size;
  final Color color;

  const AbayaIcon({
    super.key,
    this.size = 32,
    this.color = kGoldPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _AbayaPainter(color),
    );
  }
}

class _AbayaPainter extends CustomPainter {
  final Color color;
  _AbayaPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.06
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    final path = Path()
      // Neckline
      ..moveTo(w * 0.42, h * 0.12)
      ..quadraticBezierTo(w * 0.5, h * 0.08, w * 0.58, h * 0.12)
      // Right shoulder & sleeve
      ..lineTo(w * 0.72, h * 0.22)
      ..quadraticBezierTo(w * 0.82, h * 0.35, w * 0.78, h * 0.45)
      // Right side flowing down
      ..quadraticBezierTo(w * 0.76, h * 0.6, w * 0.8, h * 0.88)
      // Hem
      ..quadraticBezierTo(w * 0.7, h * 0.92, w * 0.5, h * 0.92)
      ..quadraticBezierTo(w * 0.3, h * 0.92, w * 0.2, h * 0.88)
      // Left side flowing up
      ..quadraticBezierTo(w * 0.24, h * 0.6, w * 0.22, h * 0.45)
      ..quadraticBezierTo(w * 0.18, h * 0.35, w * 0.28, h * 0.22)
      // Left shoulder back to neck
      ..lineTo(w * 0.42, h * 0.12);

    canvas.drawPath(path, paint);

    // Waist line accent
    final waist = Path()
      ..moveTo(w * 0.32, h * 0.42)
      ..quadraticBezierTo(w * 0.5, h * 0.38, w * 0.68, h * 0.42);
    canvas.drawPath(waist, paint..strokeWidth = size.width * 0.04);
  }

  @override
  bool shouldRepaint(covariant _AbayaPainter old) => old.color != color;
}

// ---------------------------------------------------------------------------
// KaftanIcon -- kaftan / jalabiya silhouette (for jalabiyas)
// ---------------------------------------------------------------------------
class KaftanIcon extends StatelessWidget {
  final double size;
  final Color color;

  const KaftanIcon({
    super.key,
    this.size = 32,
    this.color = kGoldPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _KaftanPainter(color),
    );
  }
}

class _KaftanPainter extends CustomPainter {
  final Color color;
  _KaftanPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.06
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // V-neck kaftan with wide sleeves
    final body = Path()
      // V-neckline
      ..moveTo(w * 0.38, h * 0.1)
      ..lineTo(w * 0.5, h * 0.22)
      ..lineTo(w * 0.62, h * 0.1)
      // Right shoulder & wide sleeve
      ..lineTo(w * 0.85, h * 0.2)
      ..lineTo(w * 0.88, h * 0.38)
      ..lineTo(w * 0.72, h * 0.35)
      // Right side body
      ..lineTo(w * 0.72, h * 0.9)
      // Bottom hem
      ..lineTo(w * 0.28, h * 0.9)
      // Left side body
      ..lineTo(w * 0.28, h * 0.35)
      ..lineTo(w * 0.12, h * 0.38)
      ..lineTo(w * 0.15, h * 0.2)
      ..lineTo(w * 0.38, h * 0.1);

    canvas.drawPath(body, paint);

    // Centre embroidery accent
    final detail = Path()
      ..moveTo(w * 0.5, h * 0.22)
      ..lineTo(w * 0.5, h * 0.5);
    canvas.drawPath(detail, paint..strokeWidth = size.width * 0.04);

    // Small diamond embroidery motif
    final diamond = Path()
      ..moveTo(w * 0.5, h * 0.52)
      ..lineTo(w * 0.54, h * 0.56)
      ..lineTo(w * 0.5, h * 0.60)
      ..lineTo(w * 0.46, h * 0.56)
      ..close();
    canvas.drawPath(diamond, paint..strokeWidth = size.width * 0.035);
  }

  @override
  bool shouldRepaint(covariant _KaftanPainter old) => old.color != color;
}

// ---------------------------------------------------------------------------
// DressIcon -- elegant dress silhouette
// ---------------------------------------------------------------------------
class DressIcon extends StatelessWidget {
  final double size;
  final Color color;

  const DressIcon({
    super.key,
    this.size = 32,
    this.color = kGoldPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _DressPainter(color),
    );
  }
}

class _DressPainter extends CustomPainter {
  final Color color;
  _DressPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.06
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    final path = Path()
      // Left strap
      ..moveTo(w * 0.38, h * 0.08)
      ..lineTo(w * 0.35, h * 0.2)
      // Sweetheart neckline
      ..quadraticBezierTo(w * 0.35, h * 0.25, w * 0.42, h * 0.24)
      ..quadraticBezierTo(w * 0.5, h * 0.2, w * 0.58, h * 0.24)
      ..quadraticBezierTo(w * 0.65, h * 0.25, w * 0.65, h * 0.2)
      // Right strap
      ..lineTo(w * 0.62, h * 0.08)

      // Continue from right bodice
      ..moveTo(w * 0.65, h * 0.2)
      // Right side - fitted bodice
      ..lineTo(w * 0.62, h * 0.42)
      // Flared skirt
      ..quadraticBezierTo(w * 0.7, h * 0.65, w * 0.82, h * 0.9)
      // Hem
      ..quadraticBezierTo(w * 0.5, h * 0.94, w * 0.18, h * 0.9)
      // Left side skirt
      ..quadraticBezierTo(w * 0.3, h * 0.65, w * 0.38, h * 0.42)
      ..lineTo(w * 0.35, h * 0.2);

    canvas.drawPath(path, paint);

    // Waistline accent
    final waist = Path()
      ..moveTo(w * 0.38, h * 0.42)
      ..quadraticBezierTo(w * 0.5, h * 0.39, w * 0.62, h * 0.42);
    canvas.drawPath(waist, paint..strokeWidth = size.width * 0.04);
  }

  @override
  bool shouldRepaint(covariant _DressPainter old) => old.color != color;
}

// ---------------------------------------------------------------------------
// BridalIcon -- bridal veil / gown with heart
// ---------------------------------------------------------------------------
class BridalIcon extends StatelessWidget {
  final double size;
  final Color color;

  const BridalIcon({
    super.key,
    this.size = 32,
    this.color = kGoldPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _BridalPainter(color),
    );
  }
}

class _BridalPainter extends CustomPainter {
  final Color color;
  _BridalPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.06
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // Veil / tiara crown
    final crown = Path()
      ..moveTo(w * 0.25, h * 0.18)
      ..lineTo(w * 0.3, h * 0.08)
      ..lineTo(w * 0.4, h * 0.15)
      ..lineTo(w * 0.5, h * 0.05)
      ..lineTo(w * 0.6, h * 0.15)
      ..lineTo(w * 0.7, h * 0.08)
      ..lineTo(w * 0.75, h * 0.18);
    canvas.drawPath(crown, paint);

    // Veil drape
    final veil = Path()
      ..moveTo(w * 0.25, h * 0.18)
      ..quadraticBezierTo(w * 0.15, h * 0.55, w * 0.2, h * 0.75)
      ..quadraticBezierTo(w * 0.5, h * 0.85, w * 0.8, h * 0.75)
      ..quadraticBezierTo(w * 0.85, h * 0.55, w * 0.75, h * 0.18);
    canvas.drawPath(veil, paint..strokeWidth = size.width * 0.04);

    // Small heart at centre
    final heartPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final heartPath = Path()
      ..moveTo(w * 0.5, h * 0.52)
      ..cubicTo(w * 0.5, h * 0.48, w * 0.42, h * 0.42, w * 0.42, h * 0.47)
      ..cubicTo(w * 0.42, h * 0.50, w * 0.5, h * 0.56, w * 0.5, h * 0.56)
      ..cubicTo(w * 0.5, h * 0.56, w * 0.58, h * 0.50, w * 0.58, h * 0.47)
      ..cubicTo(w * 0.58, h * 0.42, w * 0.5, h * 0.48, w * 0.5, h * 0.52);
    canvas.drawPath(heartPath, heartPaint);
  }

  @override
  bool shouldRepaint(covariant _BridalPainter old) => old.color != color;
}

// ---------------------------------------------------------------------------
// RibbonBowIcon -- cute ribbon bow for Kids category
// ---------------------------------------------------------------------------
class RibbonBowIcon extends StatelessWidget {
  final double size;
  final Color color;

  const RibbonBowIcon({
    super.key,
    this.size = 32,
    this.color = kGoldPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _RibbonBowPainter(color),
    );
  }
}

class _RibbonBowPainter extends CustomPainter {
  final Color color;
  _RibbonBowPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.06
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // Left bow loop
    final leftLoop = Path()
      ..moveTo(w * 0.5, h * 0.45)
      ..cubicTo(w * 0.3, h * 0.2, w * 0.08, h * 0.25, w * 0.15, h * 0.45)
      ..cubicTo(w * 0.2, h * 0.58, w * 0.4, h * 0.52, w * 0.5, h * 0.45);
    canvas.drawPath(leftLoop, paint);

    // Right bow loop
    final rightLoop = Path()
      ..moveTo(w * 0.5, h * 0.45)
      ..cubicTo(w * 0.7, h * 0.2, w * 0.92, h * 0.25, w * 0.85, h * 0.45)
      ..cubicTo(w * 0.8, h * 0.58, w * 0.6, h * 0.52, w * 0.5, h * 0.45);
    canvas.drawPath(rightLoop, paint);

    // Centre knot
    final knotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.5, h * 0.45), w * 0.06, knotPaint);

    // Ribbon tails
    final leftTail = Path()
      ..moveTo(w * 0.5, h * 0.50)
      ..quadraticBezierTo(w * 0.35, h * 0.7, w * 0.28, h * 0.88);
    canvas.drawPath(leftTail, paint);

    final rightTail = Path()
      ..moveTo(w * 0.5, h * 0.50)
      ..quadraticBezierTo(w * 0.65, h * 0.7, w * 0.72, h * 0.88);
    canvas.drawPath(rightTail, paint);
  }

  @override
  bool shouldRepaint(covariant _RibbonBowPainter old) => old.color != color;
}

// ---------------------------------------------------------------------------
// GiftBoxIcon -- gift box with bow
// ---------------------------------------------------------------------------
class GiftBoxIcon extends StatelessWidget {
  final double size;
  final Color color;

  const GiftBoxIcon({
    super.key,
    this.size = 32,
    this.color = kGoldPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _GiftBoxPainter(color),
    );
  }
}

class _GiftBoxPainter extends CustomPainter {
  final Color color;
  _GiftBoxPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.06
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // Box lid (slightly wider)
    final lid = RRect.fromLTRBR(
      w * 0.12, h * 0.35,
      w * 0.88, h * 0.50,
      Radius.circular(w * 0.04),
    );
    canvas.drawRRect(lid, paint);

    // Box body
    final body = RRect.fromLTRBR(
      w * 0.15, h * 0.50,
      w * 0.85, h * 0.88,
      Radius.circular(w * 0.04),
    );
    canvas.drawRRect(body, paint);

    // Vertical ribbon
    canvas.drawLine(
      Offset(w * 0.5, h * 0.35),
      Offset(w * 0.5, h * 0.88),
      paint..strokeWidth = size.width * 0.045,
    );

    // Horizontal ribbon on lid
    canvas.drawLine(
      Offset(w * 0.12, h * 0.425),
      Offset(w * 0.88, h * 0.425),
      paint,
    );

    // Bow on top
    paint.strokeWidth = size.width * 0.05;

    // Left bow loop
    final leftBow = Path()
      ..moveTo(w * 0.5, h * 0.35)
      ..cubicTo(w * 0.38, h * 0.18, w * 0.22, h * 0.18, w * 0.3, h * 0.32)
      ..lineTo(w * 0.5, h * 0.35);
    canvas.drawPath(leftBow, paint);

    // Right bow loop
    final rightBow = Path()
      ..moveTo(w * 0.5, h * 0.35)
      ..cubicTo(w * 0.62, h * 0.18, w * 0.78, h * 0.18, w * 0.7, h * 0.32)
      ..lineTo(w * 0.5, h * 0.35);
    canvas.drawPath(rightBow, paint);
  }

  @override
  bool shouldRepaint(covariant _GiftBoxPainter old) => old.color != color;
}
