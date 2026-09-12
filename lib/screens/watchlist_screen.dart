import 'package:flutter/material.dart';

import '../models/stock.dart';
import '../models/stock_store.dart';
import '../widgets/stock/stock_list_tile.dart';
import '../widgets/watchlist/watchlist_header.dart';
import '../widgets/watchlist/empty_watchlist.dart';
import '../widgets/watchlist/sort_bottom_sheet.dart';
import '../screens/stock_detail.screen.dart';

class WatchlistScreen extends StatefulWidget {
  final StockStore store;

  const WatchlistScreen({super.key, required this.store});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  String _sortType = '현재가순';

  @override
  void initState() {
    super.initState();

    widget.store.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    widget.store.removeListener(_onStoreChanged);

    super.dispose();
  }

  void _onStoreChanged() {
    if (!mounted) return;

    setState(() {});
  }

  List<Stock> _getSortedStocks() {
    final stocks = List<Stock>.from(widget.store.favoriteStocks);

    switch (_sortType) {
      case '현재가순':
        stocks.sort((a, b) {
          final priceA = _parsePrice(a.price);
          final priceB = _parsePrice(b.price);

          return priceB.compareTo(priceA);
        });
        break;

      case '등락률순':
        stocks.sort((a, b) {
          final rateA = _parseChangeRate(a.changeRate);
          final rateB = _parseChangeRate(b.changeRate);

          return rateB.compareTo(rateA);
        });
        break;

      case '가나다순':
        stocks.sort((a, b) {
          return a.name.compareTo(b.name);
        });
        break;
    }

    return stocks;
  }

  double _parsePrice(String price) {
    final value = price.replaceAll(',', '').replaceAll('원', '').trim();

    return double.tryParse(value) ?? 0;
  }

  double _parseChangeRate(String changeRate) {
    final value = changeRate.replaceAll('%', '').replaceAll('+', '').trim();

    return double.tryParse(value) ?? 0;
  }

  /// 종목 상세 화면으로 이동
  void _openStockDetail(Stock stock) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StockDetailScreen(store: widget.store, stock: stock),
      ),
    );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return SortBottomSheet(
          selectedSort: _sortType,
          onSelected: (value) {
            setState(() {
              _sortType = value;
            });

            Navigator.pop(sheetContext);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final stocks = _getSortedStocks();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            WatchlistHeader(
              sortType: _sortType,
              onSortTap: _showSortSheet,
              onRefreshTap: () async {
                debugPrint('관심 목록 새로고침 시작');

                await widget.store.refreshFavorites();

                debugPrint('관심 목록 새로고침 완료');
              },
            ),
            Expanded(
              child: stocks.isEmpty
                  ? const EmptyWatchlist()
                  : RefreshIndicator(
                      onRefresh: () async {
                        debugPrint('관심 목록 새로고침 시작');

                        await widget.store.refreshFavorites();
                      },
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: stocks.length,
                        itemBuilder: (context, index) {
                          final stock = stocks[index];

                          return StockListTile(
                            stock: stock,
                            onTap: () {
                              _openStockDetail(stock);
                            },
                            onFavoriteTap: () {
                              widget.store.toggleFavorite(stock);
                            },
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
