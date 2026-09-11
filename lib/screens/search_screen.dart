import 'package:flutter/material.dart';
import '../widgets/search/search_field.dart';
import '../widgets/search/search_initial_state.dart';
import '../widgets/search/search_empty_state.dart';
import '../widgets/search/search_result_list.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  final List<SearchStock> _stocks = const [
    SearchStock(name: '삼성전자', symbol: '005930', market: '코스피'),
    SearchStock(name: '삼성전자우', symbol: '005935', market: '코스피'),
    SearchStock(name: '삼성바이오로직스', symbol: '207940', market: '코스피'),
    SearchStock(name: '삼성에스디에스', symbol: '018260', market: '코스피'),
    SearchStock(name: '삼성중공업', symbol: '010140', market: '코스피'),
    SearchStock(name: '삼성물산', symbol: '028260', market: '코스피'),
  ];

  List<SearchStock> get _filteredStocks {
    final query = _controller.text.trim();

    if (query.isEmpty) {
      return [];
    }

    return _stocks.where((stock) {
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
                  : SearchResultList(stocks: results, searchQuery: query),
            ),
          ],
        ),
      ),
    );
  }
}
