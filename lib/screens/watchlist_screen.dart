import 'package:flutter/material.dart';

import '../models/stock.dart';
import '../models/stock_store.dart';
import '../widgets/stock/stock_list_tile.dart';
import '../widgets/watchlist/watchlist_header.dart';
import '../widgets/watchlist/empty_watchlist.dart';
import '../widgets/watchlist/sort_bottom_sheet.dart';

class WatchlistScreen extends StatefulWidget {
  final StockStore store;

  const WatchlistScreen({super.key, required this.store});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  String sortType = '가나다순';

  @override
  void initState() {
    super.initState();

    widget.store.addListener(_onStoreChanged);
  }

  void _onStoreChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    widget.store.removeListener(_onStoreChanged);

    super.dispose();
  }

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

  List<Stock> _getSortedStocks() {
    final stocks = [...widget.store.favoriteStocks];

    if (sortType == '가나다순') {
      stocks.sort((a, b) => a.name.compareTo(b.name));
    }

    return stocks;
  }

  @override
  Widget build(BuildContext context) {
    final stocks = _getSortedStocks();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            WatchlistHeader(sortType: sortType, onSortTap: _showSortSheet),

            Expanded(
              child: stocks.isEmpty
                  ? const EmptyWatchlist()
                  : ListView.builder(
                      itemCount: stocks.length,
                      itemBuilder: (context, index) {
                        final stock = stocks[index];

                        return StockListTile(
                          stock: stock,
                          onFavoriteTap: () {
                            widget.store.toggleFavorite(stock);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
