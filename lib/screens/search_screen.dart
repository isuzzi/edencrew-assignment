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

  // API 검색 결과
  List<Stock> _results = [];

  // 검색 중 여부
  bool _isSearching = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 검색 API 호출
  Future<void> _search(String query) async {
    final normalizedQuery = query.trim();

    setState(() {
      _query = query;
    });

    // 검색어가 없으면 초기 화면으로
    if (normalizedQuery.isEmpty) {
      setState(() {
        _results = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await widget.store.search(normalizedQuery);

      // 검색하는 동안 화면이 제거된 경우
      if (!mounted) return;

      // 이전 검색 요청의 결과라면 무시
      if (_query.trim() != normalizedQuery) return;

      setState(() {
        _results = results;
        _isSearching = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _results = [];
        _isSearching = false;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('검색 중 오류가 발생했습니다.')));
    }
  }

  /// 관심 종목 추가 / 삭제
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

  /// 검색어 초기화
  void _clearSearch() {
    _controller.clear();

    setState(() {
      _query = '';
      _results = [];
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SearchField(
              controller: _controller,
              onChanged: _search,
              onClear: _clearSearch,
            ),
            Expanded(
              child: _query.isEmpty
                  ? const SearchInitialState()
                  : _isSearching
                  ? const Center(child: CircularProgressIndicator())
                  : _results.isEmpty
                  ? SearchEmptyState(query: _query)
                  : SearchResultList(
                      stocks: _results,
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
