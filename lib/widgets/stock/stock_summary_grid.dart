import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class StockSummaryGrid extends StatelessWidget {
  final String openPrice;
  final String highPrice;
  final String lowPrice;
  final String tradingVolume;
  final String marketCap;

  const StockSummaryGrid({
    super.key,
    required this.openPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.tradingVolume,
    required this.marketCap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _SummaryItem('시가', openPrice)),
              const SizedBox(width: 8),
              Expanded(child: _SummaryItem('고가', highPrice)),
              const SizedBox(width: 8),
              Expanded(child: _SummaryItem('저가', lowPrice)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(flex: 2, child: _SummaryItem('거래량', tradingVolume)),
              const SizedBox(width: 8),
              Expanded(flex: 2, child: _SummaryItem('시가총액', marketCap)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: EdgeInsets.fromLTRB(10, 8, 10, 7),
      decoration: BoxDecoration(
        color: context.colors.surfaceSunken,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: context.colors.textSecondary, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
