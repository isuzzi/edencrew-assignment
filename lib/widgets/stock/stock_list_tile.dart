import 'package:flutter/material.dart';

import '../../models/stock.dart';
import '../../theme/theme.dart';

class StockListTile extends StatelessWidget {
  final Stock stock;

  /// 검색 화면에서만 사용
  final String searchQuery;

  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;

  const StockListTile({
    super.key,
    required this.stock,
    this.searchQuery = '',
    this.onTap,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    final changeValue = double.tryParse(
      stock.change.replaceAll(',', '').replaceAll('+', ''),
    );

    final isUp = (changeValue ?? 0) > 0;
    final isDown = (changeValue ?? 0) < 0;

    final changeColor = isUp
        ? const Color(0xFFFF453A)
        : isDown
        ? const Color(0xFF3B9EFF)
        : const Color(0xFF888888);

    return InkWell(
      onTap: onTap,
      child: Container(
        height: 59,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: context.colors.borderStrong, width: 1),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // 종목 정보
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStockName(context),
                  const SizedBox(height: 3),
                  Text(
                    '${stock.symbol} · ${stock.market}',
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            // 가격 정보
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  stock.price,
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${stock.change} (${stock.changeRate})',
                  style: TextStyle(
                    color: changeColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),

            const SizedBox(width: 12),

            // 관심 종목 버튼
            GestureDetector(
              onTap: onFavoriteTap,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  stock.isFavorite ? Icons.star : Icons.star_border,
                  size: 22,
                  color: stock.isFavorite
                      ? context.colors.favoriteActive
                      : context.colors.favoriteInactive,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 검색어와 일치하는 부분을 강조합니다.
  Widget _buildStockName(BuildContext context) {
    if (searchQuery.isEmpty) {
      return Text(
        stock.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: context.colors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    final spans = <TextSpan>[];

    final query = searchQuery.toLowerCase();
    final name = stock.name.toLowerCase();

    int currentIndex = 0;

    while (true) {
      final matchIndex = name.indexOf(query, currentIndex);

      if (matchIndex == -1) {
        if (currentIndex < stock.name.length) {
          spans.add(
            TextSpan(
              text: stock.name.substring(currentIndex),
              style: TextStyle(color: context.colors.textPrimary),
            ),
          );
        }
        break;
      }

      if (matchIndex > currentIndex) {
        spans.add(
          TextSpan(
            text: stock.name.substring(currentIndex, matchIndex),
            style: TextStyle(color: context.colors.textPrimary),
          ),
        );
      }

      spans.add(
        TextSpan(
          text: stock.name.substring(
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

    return Text.rich(
      TextSpan(children: spans),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: context.colors.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
