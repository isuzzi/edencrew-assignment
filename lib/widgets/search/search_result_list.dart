import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import 'search_stock_list_tile.dart';

class SearchResultList extends StatelessWidget {
  final List<SearchStock> stocks;
  final String searchQuery;

  const SearchResultList({
    super.key,
    required this.stocks,
    required this.searchQuery,
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

        return SearchStockListTile(
          stockName: stock.name,
          symbol: stock.symbol,
          market: stock.market,
          searchQuery: searchQuery,
        );
      },
    );
  }
}

class SearchStock {
  final String name;
  final String symbol;
  final String market;

  const SearchStock({
    required this.name,
    required this.symbol,
    required this.market,
  });
}
