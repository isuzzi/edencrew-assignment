import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../models/stock.dart';
import '../models/stock_store.dart';
import '../widgets/search/search_empty_state.dart';
import '../widgets/search/search_field.dart';
import '../widgets/search/search_initial_state.dart';
import '../widgets/search/search_result_list.dart';

class SearchScreen extends StatefulWidget {
  final StockStore store;

  const SearchScreen({super.key, required this.store});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();

  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleFavorite(Stock stock) {
    widget.store.toggleFavorite(stock);

    final isFavorite = stock.isFavorite;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isFavorite ? Icons.star : Icons.star_border,
                color: isFavorite
                    ? context.colors.favoriteActive
                    : context.colors.favoriteInactive,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isFavorite ? '관심이 등록되었습니다' : '관심이 해제되었습니다',
                style: TextStyle(color: context.colors.textPrimary),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,

          // 표시 시간
          duration: const Duration(seconds: 2),

          // BottomNavigationBar와 간격
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 40),

          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),

          backgroundColor: context.colors.surfaceOverlay,
          elevation: 0,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

    setState(() {});
  }

  void _clearSearch() {
    _controller.clear();

    setState(() {
      _query = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final results = widget.store.search(_query);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SearchField(
              controller: _controller,
              onChanged: (value) {
                setState(() {
                  _query = value;
                });
              },
              onClear: _clearSearch,
            ),
            Expanded(
              child: _query.isEmpty
                  ? const SearchInitialState()
                  : results.isEmpty
                  ? SearchEmptyState(query: _query)
                  : SearchResultList(
                      stocks: results,
                      searchQuery: _query,
                      onFavoriteTap: _toggleFavorite,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
