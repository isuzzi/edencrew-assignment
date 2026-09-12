import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class WatchlistHeader extends StatelessWidget {
  final String sortType;
  final VoidCallback onSortTap;
  final VoidCallback onRefreshTap;

  const WatchlistHeader({
    super.key,
    required this.sortType,
    required this.onSortTap,
    required this.onRefreshTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const Text(
              '관심',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),

            const Spacer(),

            GestureDetector(
              onTap: onSortTap,
              child: Row(
                children: [
                  Text(
                    sortType,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.colors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_downward,
                    size: 18,
                    color: context.colors.textSecondary,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            GestureDetector(
              onTap: onRefreshTap,
              child: Icon(
                Icons.refresh,
                size: 20,
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
