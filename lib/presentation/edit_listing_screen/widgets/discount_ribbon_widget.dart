import 'package:flutter/material.dart';


class DiscountRibbonWidget extends StatelessWidget {
  final String style;
  final int percentage;
  final double? width;
  final double? height;

  const DiscountRibbonWidget({
    super.key,
    required this.style,
    required this.percentage,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    switch (style) {
      case 'SALE':
        return _buildSaleRibbon(context);
      case 'DISCOUNT':
        return _buildDiscountRibbon(context);
      case 'LIMITED_TIME':
        return _buildLimitedTimeRibbon(context);
      case 'BEST_PRICE':
        return _buildBestPriceRibbon(context);
      case 'HOT_DEAL':
        return _buildHotDealRibbon(context);
      default:
        return _buildSaleRibbon(context);
    }
  }

  Widget _buildSaleRibbon(BuildContext context) {
    return Positioned(
      top: 0,
      right: 0,
      child: SizedBox(
        width: width ?? 70,
        height: height ?? 70,
        child: CustomPaint(
          painter: DiagonalRibbonPainter(
            text: '$percentage%',
            backgroundColor: Color(0xFFE53935),
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDiscountRibbon(BuildContext context) {
    return Positioned(
      top: 10,
      left: 0,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Color(0xFFFFC107),
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(4),
            bottomRight: Radius.circular(4),
          ),
        ),
        child: Text(
          'DISCOUNT $percentage%',
          style: TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLimitedTimeRibbon(BuildContext context) {
    return Positioned(
      top: 10,
      right: 10,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Color(0xFFFF9800),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(51),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.flash_on,
              color: Colors.white,
              size: 16,
            ),
            SizedBox(width: 4),
            Text(
              '$percentage% OFF',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBestPriceRibbon(BuildContext context) {
    return Positioned(
      bottom: 10,
      left: 10,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Color(0xFF4CAF50),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 16,
            ),
            SizedBox(width: 4),
            Text(
              'SAVE $percentage%',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotDealRibbon(BuildContext context) {
    return Positioned(
      top: 15,
      right: 15,
      child: Transform.rotate(
        angle: 0.1,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Color(0xFFFF5722),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(77),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.local_fire_department,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 4),
              Text(
                'HOT $percentage%',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DiagonalRibbonPainter extends CustomPainter {
  final String text;
  final Color backgroundColor;
  final TextStyle textStyle;

  DiagonalRibbonPainter({
    required this.text,
    required this.backgroundColor,
    required this.textStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    Path path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);

    // Draw text
    TextSpan span = TextSpan(
      text: text,
      style: textStyle,
    );
    TextPainter tp = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    tp.layout();

    // Position the text along the diagonal
    canvas.save();
    canvas.translate(size.width / 2, size.height / 4);
    canvas.rotate(0.785398); // 45 degrees in radians
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
