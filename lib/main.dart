import 'package:flutter/material.dart';
import 'theme/theme.dart';
import 'screens/watchlist_screen.dart';
import 'widgets/watchlist_header.dart';
import 'widgets/empty_watchlist.dart';
import 'widgets/bottom_nav_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const WatchlistScreen(),
    );
  }
}
