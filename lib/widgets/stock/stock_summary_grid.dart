import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class StockSummaryGrid extends StatelessWidget {
  const StockSummaryGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _SummaryItem('시가', '172,100')),
              const SizedBox(width: 8),
              Expanded(child: _SummaryItem('고가', '181,700')),
              const SizedBox(width: 8),
              Expanded(child: _SummaryItem('저가', '172,000')),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(flex: 2, child: _SummaryItem('거래량', '29,113천')),
              const SizedBox(width: 8),
              Expanded(flex: 2, child: _SummaryItem('시가총액', '1,063조')),
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
