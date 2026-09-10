import 'package:flutter/material.dart';

class WatchlistBottomNavigation extends StatelessWidget {
  const WatchlistBottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      onTap: (index) {
        // TODO: 검색 화면 연결
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.star), label: '관심'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: '검색'),
      ],
    );
  }
}
