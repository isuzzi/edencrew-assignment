import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:charset/charset.dart';

import '../models/naver_search_result.dart';

class NaverApiService {
  static const String _autocompleteUrl = 'https://ac.stock.naver.com/ac';
  static const String _stockApiBaseUrl = 'https://m.stock.naver.com/api/stock';
  static const String _metadataApiBaseUrl =
      'https://stock.naver.com/api/securityFe/api/fchart/domestic/stock';

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

    final decoded = jsonDecode(eucKr.decode(response.bodyBytes));

    return _parseSearchResults(decoded);
  }

  static const String _realtimeApiBaseUrl =
      'https://polling.finance.naver.com/api/realtime';

  Future<StockPriceResult> getStockPrice(String symbol) async {
    final normalizedSymbol = symbol.trim();

    if (!RegExp(r'^\d{6}$').hasMatch(normalizedSymbol)) {
      throw ArgumentError('잘못된 종목 코드입니다: $symbol');
    }

    final uri = Uri.parse(
      _realtimeApiBaseUrl,
    ).replace(queryParameters: {'query': 'SERVICE_ITEM:$normalizedSymbol'});

    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Naver 실시간 시세 API 요청 실패 '
        '($normalizedSymbol): ${response.statusCode}',
      );
    }

    /*
   * NAVER 실시간 시세 API는
   * Content-Type: text/plain;charset=EUC-KR
   * 로 응답한다.
   *
   * package:http의 response.body는 UTF-8 기준으로 처리될 수 있으므로
   * bodyBytes를 EUC-KR로 직접 디코딩한다.
   */
    final decoded = jsonDecode(eucKr.decode(response.bodyBytes));

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Naver 실시간 시세 API 응답 형식이 올바르지 않습니다.');
    }

    /*
   * 실제 NAVER 응답 구조:
   *
   * {
   *   "resultCode": "success",
   *   "result": {
   *     "pollingInterval": 70000,
   *     "areas": [...]
   *   }
   * }
   */
    final result = decoded['result'];

    if (result is! Map<String, dynamic>) {
      throw Exception('Naver 실시간 시세 result 데이터가 없습니다.');
    }

    final areas = result['areas'];

    if (areas is! List || areas.isEmpty) {
      throw Exception('Naver 실시간 시세 영역 데이터가 없습니다.');
    }

    final firstArea = areas.first;

    if (firstArea is! Map<String, dynamic>) {
      throw Exception('Naver 실시간 시세 영역 형식이 올바르지 않습니다.');
    }

    final datas = firstArea['datas'];

    if (datas is! List || datas.isEmpty) {
      throw Exception('Naver 실시간 시세 종목 데이터가 없습니다.');
    }

    final data = datas.first;

    if (data is! Map<String, dynamic>) {
      throw Exception('Naver 실시간 시세 종목 데이터 형식이 올바르지 않습니다.');
    }

    return StockPriceResult.fromJson(data);
  }

  /// 종목 메타데이터 조회
  Future<StockMetadataResult> getStockMetadata(String symbol) async {
    final normalizedSymbol = symbol.trim();

    if (!RegExp(r'^\d{6}$').hasMatch(normalizedSymbol)) {
      throw ArgumentError('잘못된 종목 코드입니다: $symbol');
    }

    final uri = Uri.parse('$_metadataApiBaseUrl/$normalizedSymbol');

    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Naver 실시간 시세 API 요청 실패 '
        '($normalizedSymbol): ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Naver 실시간 시세 API 응답 형식이 올바르지 않습니다.');
    }

    return StockMetadataResult.fromJson(decoded);
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

  final String openPrice;
  final String highPrice;
  final String lowPrice;
  final String tradingVolume;
  final String marketCap;

  const StockPriceResult({
    required this.price,
    required this.change,
    required this.changeRate,
    this.openPrice = '',
    this.highPrice = '',
    this.lowPrice = '',
    this.tradingVolume = '',
    this.marketCap = '',
  });

  factory StockPriceResult.fromJson(Map<String, dynamic> json) {
    final price = _formatNumber(json['nv']);
    final previousClose = _formatNumber(json['pcv']);

    final change = _calculateChange(
      price: json['nv'],
      previousClose: json['pcv'],
    );

    final changeRate = _formatChangeRate(
      json['cr'],
      price: json['nv'],
      previousClose: json['pcv'],
    );

    final listedStockCount = _toDouble(json['countOfListedStock']);
    final currentPrice = _toDouble(json['nv']);

    final marketCap = currentPrice != null && listedStockCount != null
        ? _formatMarketCap(currentPrice * listedStockCount)
        : '';

    return StockPriceResult(
      price: price,
      change: change,
      changeRate: changeRate,
      openPrice: _formatNumber(json['ov']),
      highPrice: _formatNumber(json['hv']),
      lowPrice: _formatNumber(json['lv']),
      tradingVolume: _formatVolume(json['aq']),
      marketCap: marketCap,
    );
  }

  static String _calculateChange({
    required dynamic price,
    required dynamic previousClose,
  }) {
    final current = _toDouble(price);
    final previous = _toDouble(previousClose);

    if (current == null || previous == null) {
      return '';
    }

    final change = current - previous;

    if (change == 0) {
      return '0';
    }

    return change > 0 ? '+${_formatNumber(change)}' : _formatNumber(change);
  }

  static String _formatChangeRate(
    dynamic value, {
    required dynamic price,
    required dynamic previousClose,
  }) {
    final number = _toDouble(value);

    if (number != null) {
      return '${number >= 0 ? '+' : ''}${number.toStringAsFixed(2)}%';
    }

    final current = _toDouble(price);
    final previous = _toDouble(previousClose);

    if (current == null || previous == null || previous == 0) {
      return '';
    }

    final calculated = ((current - previous) / previous) * 100;

    return '${calculated >= 0 ? '+' : ''}${calculated.toStringAsFixed(2)}%';
  }

  static String _formatNumber(dynamic value) {
    final number = _toDouble(value);

    if (number == null) {
      return value?.toString() ?? '';
    }

    return number.round().toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }

  static String _formatVolume(dynamic value) {
    final number = _toDouble(value);

    if (number == null) {
      return value?.toString() ?? '';
    }

    return number.round().toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }

  static String _formatMarketCap(double value) {
    if (value >= 1000000000000) {
      return '${(value / 1000000000000).toStringAsFixed(0)}조';
    }

    if (value >= 100000000) {
      return '${(value / 100000000).toStringAsFixed(0)}억';
    }

    return _formatNumber(value);
  }

  static double? _toDouble(dynamic value) {
    if (value == null) {
      return null;
    }

    return double.tryParse(value.toString().replaceAll(',', ''));
  }
}

/// NAVER 종목 메타데이터 응답
class StockMetadataResult {
  final String symbol;
  final String name;
  final String exchangeName;

  const StockMetadataResult({
    required this.symbol,
    required this.name,
    required this.exchangeName,
  });

  factory StockMetadataResult.fromJson(Map<String, dynamic> json) {
    return StockMetadataResult(
      symbol: json['symbolCode']?.toString() ?? '',
      name: json['stockName']?.toString() ?? '',
      exchangeName: json['stockExchangeNameKor']?.toString() ?? '',
    );
  }
}
