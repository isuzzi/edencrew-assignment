import 'package:flutter/material.dart';

import '../../models/daily_price.dart';
import '../../theme/theme.dart';

class StockDailyPriceTable extends StatelessWidget {
  final List<DailyPrice> prices;

  const StockDailyPriceTable({super.key, required this.prices});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '일별 시세',
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),

          const _TableHeader(),

          const SizedBox(height: 8),

          if (prices.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  '일별 시세를 불러오지 못했습니다.',
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            )
          else
            ...prices.map((price) => _TableRow(data: price)),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                '날짜',
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '종가',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '등락',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                '거래량',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Divider(height: 1, thickness: 1),
      ],
    );
  }
}

class _TableRow extends StatelessWidget {
  final DailyPrice data;

  const _TableRow({required this.data});

  @override
  Widget build(BuildContext context) {
    final Color changeColor;

    if (data.isUp) {
      changeColor = context.colors.chartLineUp;
    } else if (data.isDown) {
      changeColor = context.colors.chartLineDown;
    } else {
      changeColor = context.colors.priceFlatText;
    }

    return Container(
      height: 36,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.colors.borderSubtle)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              data.displayDate,
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 11,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              data.closePrice,
              textAlign: TextAlign.right,
              style: TextStyle(color: context.colors.textPrimary, fontSize: 11),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              data.change,
              textAlign: TextAlign.right,
              style: TextStyle(color: changeColor, fontSize: 11),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              data.tradingVolume,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
