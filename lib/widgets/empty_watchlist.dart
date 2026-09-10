import 'package:flutter/material.dart';

class EmptyWatchlist extends StatelessWidget {
  const EmptyWatchlist({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 별 아이콘 자리
          const SizedBox(width: 48, height: 48),

          const SizedBox(height: 16),

          const Text(
            '관심 종목이 없습니다',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 8),

          const Text(
            '검색 탭에서 종목을 찾아\n별 아이콘을 눌러 추가해 주세요.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, height: 1.5, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
