import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class StockPriceChart extends StatelessWidget {
  final String period;

  const StockPriceChart({super.key, required this.period});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      width: double.infinity,
      child: CustomPaint(
        painter: _StockCandlePainter(
          gridColor: context.colors.surfaceBase,
          upColor: context.colors.chartLineUp,
          downColor: context.colors.chartLineDown,
        ),
      ),
    );
  }
}

class _Candle {
  final double open;
  final double close;
  final double high;
  final double low;

  const _Candle({
    required this.open,
    required this.close,
    required this.high,
    required this.low,
  });
}

class _StockCandlePainter extends CustomPainter {
  final Color gridColor;
  final Color upColor;
  final Color downColor;

  _StockCandlePainter({
    required this.gridColor,
    required this.upColor,
    required this.downColor,
  });

  final candles = const [
    _Candle(open: 20, close: 28, high: 31, low: 16),
    _Candle(open: 28, close: 25, high: 34, low: 22),
    _Candle(open: 25, close: 39, high: 43, low: 21),
    _Candle(open: 39, close: 34, high: 45, low: 31),
    _Candle(open: 34, close: 37, high: 40, low: 28),
    _Candle(open: 37, close: 30, high: 42, low: 26),
    _Candle(open: 30, close: 46, high: 49, low: 28),
    _Candle(open: 46, close: 54, high: 58, low: 42),
    _Candle(open: 54, close: 49, high: 61, low: 46),
    _Candle(open: 49, close: 57, high: 60, low: 44),
    _Candle(open: 57, close: 51, high: 64, low: 48),
    _Candle(open: 51, close: 52, high: 55, low: 47),
    _Candle(open: 52, close: 62, high: 66, low: 49),
    _Candle(open: 62, close: 58, high: 65, low: 54),
    _Candle(open: 58, close: 63, high: 68, low: 55),
    _Candle(open: 63, close: 60, high: 65, low: 56),
    _Candle(open: 60, close: 68, high: 72, low: 58),
    _Candle(open: 68, close: 65, high: 70, low: 62),
    _Candle(open: 65, close: 71, high: 74, low: 63),
    _Candle(open: 71, close: 68, high: 76, low: 65),
    _Candle(open: 68, close: 76, high: 79, low: 66),
    _Candle(open: 76, close: 72, high: 80, low: 70),
    _Candle(open: 72, close: 78, high: 82, low: 70),
    _Candle(open: 78, close: 84, high: 88, low: 75),
    _Candle(open: 84, close: 80, high: 91, low: 77),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final chartLeft = 16.0;
    final chartRight = size.width - 16;
    final chartTop = 14.0;
    final chartBottom = size.height - 18;

    final chartWidth = chartRight - chartLeft;
    final chartHeight = chartBottom - chartTop;

    // Grid
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    for (int i = 0; i < 5; i++) {
      final y = chartTop + chartHeight * i / 4;

      canvas.drawLine(Offset(chartLeft, y), Offset(chartRight, y), gridPaint);
    }

    const minValue = 10.0;
    const maxValue = 95.0;

    double yFor(double value) {
      return chartBottom -
          ((value - minValue) / (maxValue - minValue)) * chartHeight;
    }

    final candleWidth = chartWidth / candles.length * 0.55;
    final step = chartWidth / candles.length;

    for (int i = 0; i < candles.length; i++) {
      final candle = candles[i];

      final x = chartLeft + step * i + step / 2;

      final openY = yFor(candle.open);
      final closeY = yFor(candle.close);
      final highY = yFor(candle.high);
      final lowY = yFor(candle.low);

      final isUp = candle.close > candle.open;

      final candlePaint = Paint()
        ..color = isUp ? upColor : downColor
        ..strokeWidth = 1.2
        ..style = PaintingStyle.fill;

      // 꼬리
      canvas.drawLine(Offset(x, highY), Offset(x, lowY), candlePaint);

      // 몸통
      final top = openY < closeY ? openY : closeY;
      final bottom = openY > closeY ? openY : closeY;

      final rect = Rect.fromLTRB(
        x - candleWidth / 2,
        top,
        x + candleWidth / 2,
        bottom < top + 2 ? top + 2 : bottom,
      );

      canvas.drawRect(rect, candlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _StockCandlePainter oldDelegate) {
    return oldDelegate.gridColor != gridColor ||
        oldDelegate.upColor != upColor ||
        oldDelegate.downColor != downColor;
  }
}
