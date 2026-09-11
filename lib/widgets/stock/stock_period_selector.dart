import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class StockPeriodSelector extends StatelessWidget {
  final String selectedPeriod;
  final ValueChanged<String> onChanged;

  const StockPeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onChanged,
  });

  static const periods = ['1개월', '3개월', '6개월', '1년'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
      child: Row(
        children: periods.map((period) {
          final isSelected = period == selectedPeriod;

          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(period),
              child: Container(
                height: 29,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.colors.accentBg
                      : context.colors.surfaceBase,
                  borderRadius: BorderRadius.circular(7),
                ),
                alignment: Alignment.center,
                child: Text(
                  period,
                  style: TextStyle(
                    color: isSelected
                        ? context.colors.accentDefault
                        : context.colors.textSecondary,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
