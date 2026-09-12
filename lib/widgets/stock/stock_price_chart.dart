import 'package:flutter/material.dart';

import '../../models/daily_price.dart';
import '../../theme/theme.dart';

class StockPriceChart extends StatelessWidget {
  final String period;
  final List<DailyPrice> prices;

  const StockPriceChart({
    super.key,
    required this.period,
    required this.prices,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      width: double.infinity,
      child: CustomPaint(
        painter: _StockCandlePainter(
          prices: prices,
          gridColor: context.colors.surfaceBase,
          upColor: context.colors.chartLineUp,
          downColor: context.colors.chartLineDown,
        ),
      ),
    );
  }
}

class _CandleData {
  final double open;
  final double close;
  final double high;
  final double low;

  const _CandleData({
    required this.open,
    required this.close,
    required this.high,
    required this.low,
  });

  bool get isDoji => open == close && open == high && open == low;
}

class _StockCandlePainter extends CustomPainter {
  final List<DailyPrice> prices;
  final Color gridColor;
  final Color upColor;
  final Color downColor;

  _StockCandlePainter({
    required this.prices,
    required this.gridColor,
    required this.upColor,
    required this.downColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (prices.isEmpty) {
      return;
    }

    final chartLeft = 16.0;
    final chartRight = size.width - 16.0;
    final chartTop = 14.0;
    final chartBottom = size.height - 18.0;

    final chartWidth = chartRight - chartLeft;
    final chartHeight = chartBottom - chartTop;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0;

    // 가로 그리드
    for (int i = 0; i < 5; i++) {
      final y = chartTop + chartHeight * i / 4;

      canvas.drawLine(Offset(chartLeft, y), Offset(chartRight, y), gridPaint);
    }

    // 네이버 일별 시세는 최신 날짜부터 내려온다.
    // 오래된 날짜 -> 최신 날짜 순으로 변경한다.
    final reversedPrices = prices.reversed.toList();

    final candles = <_CandleData>[];

    for (final price in reversedPrices) {
      /*
       * 거래량이 없는 날짜는 차트에서 제외한다.
       *
       * 네이버 HTML에서는 거래량이 '-'로 내려오는 경우가 있다.
       * 이런 데이터는 실제 거래 캔들이 아니므로 차트에 그리지 않는다.
       */
      final tradingVolume = price.tradingVolume.replaceAll(',', '').trim();

      if (tradingVolume.isEmpty ||
          tradingVolume == '-' ||
          tradingVolume == '0') {
        continue;
      }

      final open = _parsePrice(price.openPrice);
      final close = _parsePrice(price.closePrice);
      final high = _parsePrice(price.highPrice);
      final low = _parsePrice(price.lowPrice);

      if (open == null || close == null || high == null || low == null) {
        continue;
      }

      /*
       * OHLC 관계가 잘못된 데이터가 들어오는 경우를 보정한다.
       *
       * high >= open, close
       * low  <= open, close
       */
      final normalizedHigh = [
        open,
        close,
        high,
      ].reduce((a, b) => a > b ? a : b);

      final normalizedLow = [open, close, low].reduce((a, b) => a < b ? a : b);

      candles.add(
        _CandleData(
          open: open,
          close: close,
          high: normalizedHigh,
          low: normalizedLow,
        ),
      );
    }

    if (candles.isEmpty) {
      return;
    }

    // ------------------------------------------------------------
    // 전체 가격 범위
    // ------------------------------------------------------------

    final values = <double>[];

    for (final candle in candles) {
      values.add(candle.open);
      values.add(candle.close);
      values.add(candle.high);
      values.add(candle.low);
    }

    var minValue = values.reduce((a, b) => a < b ? a : b);

    var maxValue = values.reduce((a, b) => a > b ? a : b);

    if (minValue == maxValue) {
      minValue -= 1;
      maxValue += 1;
    } else {
      final padding = (maxValue - minValue) * 0.08;

      minValue -= padding;
      maxValue += padding;
    }

    double yFor(double value) {
      return chartBottom -
          ((value - minValue) / (maxValue - minValue)) * chartHeight;
    }

    // ------------------------------------------------------------
    // 캔들 크기
    // ------------------------------------------------------------

    final step = chartWidth / candles.length;

    final candleWidth = (step * 0.55).clamp(0.8, 12.0).toDouble();

    // ------------------------------------------------------------
    // 캔들 그리기
    // ------------------------------------------------------------

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

      /*
       * 시가 = 종가 = 고가 = 저가
       *
       * 몸통을 그리지 않고 "-" 하나만 표시한다.
       */
      if (candle.isDoji) {
        final dojiPaint = Paint()
          ..color = downColor
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.square;

        canvas.drawLine(
          Offset(x - candleWidth / 2, openY),
          Offset(x + candleWidth / 2, openY),
          dojiPaint,
        );

        continue;
      }

      // 고가 ~ 저가 심지
      canvas.drawLine(Offset(x, highY), Offset(x, lowY), candlePaint);

      // 시가 ~ 종가 몸통
      final top = openY < closeY ? openY : closeY;

      final bottom = openY > closeY ? openY : closeY;

      final bodyBottom = bottom < top + 2.0 ? top + 2.0 : bottom;

      final rect = Rect.fromLTRB(
        x - candleWidth / 2,
        top,
        x + candleWidth / 2,
        bodyBottom,
      );

      canvas.drawRect(rect, candlePaint);
    }
  }

  double? _parsePrice(String value) {
    final normalized = value.replaceAll(',', '').trim();

    if (normalized.isEmpty) {
      return null;
    }

    return double.tryParse(normalized);
  }

  @override
  bool shouldRepaint(covariant _StockCandlePainter oldDelegate) {
    return oldDelegate.prices != prices ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.upColor != upColor ||
        oldDelegate.downColor != downColor;
  }
}
