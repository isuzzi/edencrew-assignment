import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class SearchStockListTile extends StatelessWidget {
  final String stockName;
  final String symbol;
  final String market;
  final String searchQuery;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;

  const SearchStockListTile({
    super.key,
    required this.stockName,
    required this.symbol,
    required this.market,
    required this.searchQuery,
    this.isFavorite = false,
    this.onTap,
    this.onFavoriteTap,
  });

  List<TextSpan> _buildHighlightedText(BuildContext context) {
    if (searchQuery.isEmpty) {
      return [
        TextSpan(
          text: stockName,
          style: TextStyle(color: context.colors.textPrimary),
        ),
      ];
    }

    final spans = <TextSpan>[];
    final query = searchQuery.toLowerCase();
    final name = stockName.toLowerCase();

    int currentIndex = 0;

    while (true) {
      final matchIndex = name.indexOf(query, currentIndex);

      if (matchIndex == -1) {
        if (currentIndex < stockName.length) {
          spans.add(
            TextSpan(
              text: stockName.substring(currentIndex),
              style: TextStyle(color: context.colors.textPrimary),
            ),
          );
        }
        break;
      }

      if (matchIndex > currentIndex) {
        spans.add(
          TextSpan(
            text: stockName.substring(currentIndex, matchIndex),
            style: TextStyle(color: context.colors.textPrimary),
          ),
        );
      }

      spans.add(
        TextSpan(
          text: stockName.substring(
            matchIndex,
            matchIndex + searchQuery.length,
          ),
          style: TextStyle(
            color: context.colors.searchHighlight,
            fontWeight: FontWeight.w700,
          ),
        ),
      );

      currentIndex = matchIndex + searchQuery.length;
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 60,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(children: _buildHighlightedText(context)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.colors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
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
                  size: 22,
                  color: isFavorite
                      ? context.colors.favoriteActive
                      : context.colors.favoriteInactive,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
