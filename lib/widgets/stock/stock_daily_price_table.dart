import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class StockDailyPriceTable extends StatelessWidget {
  const StockDailyPriceTable({super.key});

  static const rows = [
    _DailyPrice(
      date: '03.27',
      close: '179,700',
      change: '-400',
      volume: '29,113,466',
      isDown: true,
    ),
    _DailyPrice(
      date: '03.26',
      close: '180,100',
      change: '+1,200',
      volume: '32,074,131',
      isUp: true,
    ),
    _DailyPrice(
      date: '03.25',
      close: '178,900',
      change: '+900',
      volume: '27,441,209',
      isUp: true,
    ),
    _DailyPrice(
      date: '03.24',
      close: '178,000',
      change: '0',
      volume: '31,882,540',
    ),
    _DailyPrice(
      date: '03.23',
      close: '178,000',
      change: '0',
      volume: '29,780,397',
    ),
  ];

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

          ...rows.map((row) => _TableRow(data: row)),
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
        SizedBox(height: 10),
        Divider(height: 1, thickness: 1, color: context.colors.borderSubtle),
      ],
    );
  }
}

class _TableRow extends StatelessWidget {
  final _DailyPrice data;

  const _TableRow({required this.data});

  @override
  Widget build(BuildContext context) {
    Color changeColor;

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
              data.date,
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 11,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              data.close,
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
              data.volume,
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

class _DailyPrice {
  final String date;
  final String close;
  final String change;
  final String volume;
  final bool isUp;
  final bool isDown;

  const _DailyPrice({
    required this.date,
    required this.close,
    required this.change,
    required this.volume,
    this.isUp = false,
    this.isDown = false,
  });
}
