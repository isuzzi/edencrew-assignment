import 'package:flutter/material.dart';

import '../widgets/watchlist/watchlist_header.dart';
import '../widgets/watchlist/empty_watchlist.dart';
import '../widgets/watchlist/watchlist_item.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/watchlist/sort_bottom_sheet.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  bool isEmpty = false;

  String sortType = '가나다순';

  final stocks = const [
    {
      'name': '삼성전자',
      'code': '005930',
      'market': '코스피',
      'price': '179,700',
      'change': '-400 (-0.22%)',
    },
    {
      'name': 'SK하이닉스',
      'code': '000660',
      'market': '코스피',
      'price': '412,500',
      'change': '+9,500 (+2.36%)',
    },
    {
      'name': '카카오',
      'code': '035720',
      'market': '코스피',
      'price': '61,300',
      'change': '-800 (-1.29%)',
    },
    {
      'name': '에코프로비엠',
      'code': '247540',
      'market': '코스닥',
      'price': '195,400',
      'change': '0 (0.00%)',
    },
    {
      'name': 'LG에너지솔루션',
      'code': '373220',
      'market': '코스피',
      'price': '',
      'change': '',
    },
  ];

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SortBottomSheet(
          selectedSort: sortType,
          onSelected: (value) {
            setState(() {
              sortType = value;
            });

            Navigator.pop(context);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            WatchlistHeader(sortType: sortType, onSortTap: _showSortSheet),

            Expanded(
              child: isEmpty
                  ? const EmptyWatchlist()
                  : ListView.builder(
                      itemCount: stocks.length,
                      itemBuilder: (context, index) {
                        final stock = stocks[index];

                        return WatchlistItem(
                          name: stock['name']!,
                          code: stock['code']!,
                          market: stock['market']!,
                          price: stock['price']!,
                          change: stock['change']!,
                        );
                      },
                    ),
            ),

            const BottomNavBar(),
          ],
        ),
      ),
    );
  }
}
