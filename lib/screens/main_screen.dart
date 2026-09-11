import 'package:flutter/material.dart';

import '../models/stock_store.dart';
import '../widgets/bottom_nav_bar.dart';
import 'watchlist_screen.dart';
import 'search_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final StockStore _stockStore = StockStore();

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    _screens = [
      WatchlistScreen(store: _stockStore),
      SearchScreen(store: _stockStore),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
