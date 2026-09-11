import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class StockDetailHeader extends StatelessWidget {
  final String stockName;
  final String symbol;
  final String market;
  final bool isFavorite;
  final VoidCallback onBackTap;
  final VoidCallback onFavoriteTap;

  const StockDetailHeader({
    super.key,
    required this.stockName,
    required this.symbol,
    required this.market,
    required this.isFavorite,
    required this.onBackTap,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.colors.borderSubtle, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBackTap,
            child: Icon(
              Icons.arrow_back,
              size: 18,
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stockName,
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$symbol · $market',
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onFavoriteTap,
            child: Icon(
              isFavorite ? Icons.star : Icons.star_border,
              size: 24,
              color: isFavorite
                  ? context.colors.favoriteActive
                  : context.colors.favoriteInactive,
            ),
          ),
        ],
      ),
    );
  }
}
