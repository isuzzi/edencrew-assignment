import 'package:flutter/material.dart';

import '../../models/stock.dart';
import '../../theme/theme.dart';
import '../stock/stock_list_tile.dart';

class SearchResultList extends StatelessWidget {
  final List<Stock> stocks;
  final String searchQuery;
  final void Function(Stock stock)? onFavoriteTap;
  final void Function(Stock stock)? onStockTap;

  const SearchResultList({
    super.key,
    required this.stocks,
    required this.searchQuery,
    this.onFavoriteTap,
    this.onStockTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.only(top: 14),
      itemCount: stocks.length,
      separatorBuilder: (_, __) =>
          Divider(height: 1, color: context.colors.borderStrong),
      itemBuilder: (context, index) {
        final stock = stocks[index];

        return StockListTile(
          stock: stock,
          searchQuery: searchQuery,
          onTap: () {
            onStockTap?.call(stock);
          },
          onFavoriteTap: () {
            onFavoriteTap?.call(stock);
          },
        );
      },
    );
  }
}
