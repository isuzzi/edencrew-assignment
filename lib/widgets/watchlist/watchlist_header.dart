import 'package:flutter/material.dart';

class WatchlistHeader extends StatelessWidget {
  final String sortType;
  final VoidCallback onSortTap;

  const WatchlistHeader({
    super.key,
    required this.sortType,
    required this.onSortTap,
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
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),

                  // 정렬 아이콘 자리
                  const SizedBox(width: 20),

                  // 새로고침 아이콘 자리
                  const SizedBox(width: 28),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
