import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/naver_search_result.dart';

class NaverApiService {
  static const String _autocompleteUrl = 'https://ac.stock.naver.com/ac';

  final http.Client _client;

  NaverApiService({http.Client? client}) : _client = client ?? http.Client();

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
