import 'package:flutter/material.dart';

import '../models/stock.dart';
import '../models/stock_store.dart';
import '../widgets/search/search_field.dart';
import '../widgets/search/search_initial_state.dart';
import '../widgets/search/search_empty_state.dart';
import '../widgets/search/search_result_list.dart';

class SearchScreen extends StatefulWidget {
  final StockStore store;

  const SearchScreen({super.key, required this.store});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  List<Stock> get _filteredStocks {
    final query = _controller.text.trim();

    if (query.isEmpty) {
      return [];
    }

    return widget.store.stocks.where((stock) {
      return stock.name.contains(query) || stock.symbol.contains(query);
    }).toList();
  }

  void _onSearchChanged(String value) {
    setState(() {});
  }

  void _clearSearch() {
    _controller.clear();
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _controller.text.trim();
    final results = _filteredStocks;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SearchField(
              controller: _controller,
              onChanged: _onSearchChanged,
              onClear: _clearSearch,
            ),
            Expanded(
              child: query.isEmpty
                  ? const SearchInitialState()
                  : results.isEmpty
                  ? SearchEmptyState(query: query)
                  : SearchResultList(
                      stocks: results,
                      searchQuery: query,
                      onFavoriteTap: (stock) {
                        widget.store.toggleFavorite(stock);
                        setState(() {});
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
