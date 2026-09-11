import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/naver_search_result.dart';

class NaverApiService {
  static const String _autocompleteUrl = 'https://ac.stock.naver.com/ac';
  static const String _stockApiBaseUrl = 'https://m.stock.naver.com/api/stock';

  final http.Client _client;

  NaverApiService({http.Client? client}) : _client = client ?? http.Client();

  /// 종목 검색
  Future<List<NaverSearchResult>> searchStocks(String query) async {
    final normalizedQuery = query.trim();

    if (normalizedQuery.isEmpty) {
      return [];
    }

    final uri = Uri.parse(_autocompleteUrl).replace(
      queryParameters: {
        'q': normalizedQuery,
        'target': 'stock,ipo,index,marketindicator',
      },
    );

    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Naver 검색 API 요청 실패: ${response.statusCode}');
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));

    return _parseSearchResults(decoded);
  }

  /// 종목 현재 시세 조회
  Future<StockPriceResult> getStockPrice(String symbol) async {
    final normalizedSymbol = symbol.trim();

    if (!RegExp(r'^\d{6}$').hasMatch(normalizedSymbol)) {
      throw ArgumentError('잘못된 종목 코드입니다: $symbol');
    }

    final uri = Uri.parse('$_stockApiBaseUrl/$normalizedSymbol/basic');

    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Naver 시세 API 요청 실패 '
        '($normalizedSymbol): ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Naver 시세 API 응답 형식이 올바르지 않습니다.');
    }

    return StockPriceResult.fromJson(decoded);
  }

  List<NaverSearchResult> _parseSearchResults(dynamic data) {
    if (data is! Map<String, dynamic>) {
      return [];
    }

    final items = data['items'];

    if (items is! List) {
      return [];
    }

    final results = <NaverSearchResult>[];

    for (final item in items) {
      if (item is! Map<String, dynamic>) {
        continue;
      }

      final code = item['code']?.toString() ?? '';
      final nationCode = item['nationCode']?.toString() ?? '';

      // 국내 주식만 허용
      if (nationCode != 'KOR') {
        continue;
      }

      // 6자리 종목코드만 허용
      if (!RegExp(r'^\d{6}$').hasMatch(code)) {
        continue;
      }

      results.add(NaverSearchResult.fromJson(item));
    }

    return results;
  }

  void dispose() {
    _client.close();
  }
}

/// NAVER 종목 시세 응답
class StockPriceResult {
  final String price;
  final String change;
  final String changeRate;

  const StockPriceResult({
    required this.price,
    required this.change,
    required this.changeRate,
  });

  factory StockPriceResult.fromJson(Map<String, dynamic> json) {
    return StockPriceResult(
      price: json['closePrice']?.toString() ?? '',
      change: json['compareToPreviousClosePrice']?.toString() ?? '',
      changeRate: _formatChangeRate(json['fluctuationsRatio']),
    );
  }

  static String _formatChangeRate(dynamic value) {
    if (value == null) {
      return '';
    }

    final text = value.toString().trim();

    if (text.isEmpty) {
      return '';
    }

    if (text.endsWith('%')) {
      return text;
    }

    final number = double.tryParse(text.replaceAll(',', ''));

    if (number == null) {
      return text;
    }

    return '${number >= 0 ? '+' : ''}${number.toStringAsFixed(2)}%';
  }
}
