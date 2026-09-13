import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:charset/charset.dart';

import '../models/naver_search_result.dart';
import '../models/daily_price.dart';

class NaverApiService {
  static const String _autocompleteUrl = 'https://ac.stock.naver.com/ac';

  static const String _stockApiBaseUrl = 'https://m.stock.naver.com/api/stock';

  static const String _metadataApiBaseUrl =
      'https://stock.naver.com/api/securityFe/api/fchart/domestic/stock';

  static const String _realtimeApiBaseUrl =
      'https://polling.finance.naver.com/api/realtime';

  static const String _dailyPriceApiUrl =
      'https://finance.naver.com/item/sise_day.naver';

  String _addComma(String value) {
    final number = int.tryParse(value.replaceAll(',', ''));

    if (number == null) {
      return value;
    }

    return number.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }

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

  /// 실시간 시세 조회
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

    final decoded = jsonDecode(eucKr.decode(response.bodyBytes));

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Naver 실시간 시세 API 응답 형식이 올바르지 않습니다.');
    }

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
        'Naver 메타데이터 API 요청 실패 '
        '($normalizedSymbol): ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Naver 메타데이터 API 응답 형식이 올바르지 않습니다.');
    }

    return StockMetadataResult.fromJson(decoded);
  }

  /// 일별 시세 조회
  ///
  /// Naver finance의 sise_day.naver는 JSON이 아니라
  /// HTML을 반환한다.
  Future<DailyPricePageResult> getDailyPrices(String symbol, int page) async {
    final normalizedSymbol = symbol.trim();

    if (!RegExp(r'^\d{6}$').hasMatch(normalizedSymbol)) {
      throw ArgumentError('잘못된 종목 코드입니다: $symbol');
    }

    if (page < 1) {
      throw ArgumentError('페이지는 1 이상이어야 합니다: $page');
    }

    final uri = Uri.parse(_dailyPriceApiUrl).replace(
      queryParameters: {'code': normalizedSymbol, 'page': page.toString()},
    );

    final response = await _client.get(
      uri,
      headers: {'User-Agent': 'Mozilla/5.0'},
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Naver 일별 시세 API 요청 실패 '
        '($normalizedSymbol, page=$page): '
        '${response.statusCode}',
      );
    }

    /*
     * sise_day.naver는 UTF-8이 아닌 EUC-KR 계열의
     * HTML 응답을 반환한다.
     *
     * response.body를 바로 사용하지 않고
     * bodyBytes를 EUC-KR로 직접 디코딩한다.
     */
    final html = eucKr.decode(response.bodyBytes);

    final prices = _parseDailyPrices(html);

    final lastPage = _parseLastPage(html);

    if (prices.isEmpty) {
      throw Exception(
        'Naver 일별 시세 데이터가 없습니다. '
        '($normalizedSymbol, page=$page)',
      );
    }

    debugPrint(
      '일별 시세 조회: '
      '$normalizedSymbol / '
      'page=$page / '
      '${prices.length}개 / '
      'lastPage=$lastPage',
    );

    debugPrint('===== 일별 시세 실제 데이터 =====');
    debugPrint(
      '종목코드: $normalizedSymbol / '
      '페이지: $page / '
      '데이터: ${prices.length}개 / '
      '마지막 페이지: $lastPage',
    );

    for (var i = 0; i < prices.length; i++) {
      final price = prices[i];

      debugPrint(
        '[${i + 1}] '
        '날짜=${price.date} '
        '종가=${price.closePrice} '
        '전일비=${price.change} '
        '시가=${price.openPrice} '
        '고가=${price.highPrice} '
        '저가=${price.lowPrice} '
        '거래량=${price.tradingVolume}',
      );
    }

    debugPrint('==============================');

    return DailyPricePageResult(prices: prices, lastPage: lastPage);
  }

  /// 일별 시세 HTML 파싱
  List<DailyPrice> _parseDailyPrices(String html) {
    final prices = <DailyPrice>[];

    /*
     * 네이버 일별 시세 표의 각 행을 찾는다.
     */
    final rowMatches = RegExp(
      r'<tr[^>]*>(.*?)</tr>',
      caseSensitive: false,
      dotAll: true,
    ).allMatches(html);

    for (final rowMatch in rowMatches) {
      final rowHtml = rowMatch.group(1) ?? '';

      /*
       * td HTML 원본을 먼저 가져온다.
       *
       * 기존 코드처럼 바로 cleanHtmlText()를 적용하면
       * 전일비의 상승/하락 정보를 가지고 있는 img 태그까지
       * 제거되어 방향 정보를 잃을 수 있다.
       */
      final rawCells = RegExp(
        r'<td[^>]*>(.*?)</td>',
        caseSensitive: false,
        dotAll: true,
      ).allMatches(rowHtml).map((match) => match.group(1) ?? '').toList();

      /*
       * 날짜 / 종가 / 전일비 / 시가 / 고가 / 저가 / 거래량
       *
       * 실제 데이터 행은 최소 7개의 td를 가진다.
       */
      if (rawCells.length < 7) {
        continue;
      }

      /*
       * 날짜
       */
      final date = _normalizeDate(_cleanHtmlText(rawCells[0]));

      /*
       * 날짜가 아닌 행은 헤더/불필요한 행이므로 제외
       */
      if (date.isEmpty) {
        continue;
      }

      /*
       * 종가
       */
      final closePrice = _normalizeNumber(_cleanHtmlText(rawCells[1]));

      /*
       * 전일비
       *
       * 중요:
       * 여기서는 cleanHtmlText() 결과가 아니라
       * HTML 원본을 넘긴다.
       *
       * 상승/하락 방향을 img alt 및 텍스트에서
       * 직접 판단한다.
       */
      final change = _parseChangeCell(rawCells[2]);

      /*
       * 시가
       */
      final openPrice = _normalizeNumber(_cleanHtmlText(rawCells[3]));

      /*
       * 고가
       */
      final highPrice = _normalizeNumber(_cleanHtmlText(rawCells[4]));

      /*
       * 저가
       */
      final lowPrice = _normalizeNumber(_cleanHtmlText(rawCells[5]));

      /*
       * 거래량
       */
      final tradingVolume = _normalizeNumber(_cleanHtmlText(rawCells[6]));

      /*
       * 필수 숫자 데이터가 없는 행은 제외
       */
      if (closePrice.isEmpty ||
          openPrice.isEmpty ||
          highPrice.isEmpty ||
          lowPrice.isEmpty ||
          tradingVolume.isEmpty) {
        continue;
      }

      prices.add(
        DailyPrice(
          date: date,
          closePrice: _addComma(closePrice),
          change: change,
          openPrice: _addComma(openPrice),
          highPrice: _addComma(highPrice),
          lowPrice: _addComma(lowPrice),
          tradingVolume: _addComma(tradingVolume),
        ),
      );
    }

    return prices;
  }

  /// 일별 시세의 전일비 HTML 파싱
  String _parseChangeCell(String html) {
    // 네이버 금융은 전일비 방향을 class로 표현한다.
    //
    // bu_pup = 상승
    // bu_pdn = 하락
    // bu_pn  = 보합

    String direction = '';

    if (html.contains('bu_pup')) {
      direction = '+';
    } else if (html.contains('bu_pdn')) {
      direction = '-';
    } else if (html.contains('bu_pn')) {
      direction = '0';
    }

    // 전일비 숫자 추출
    final text = _cleanHtmlText(html);

    final numberMatch = RegExp(r'\d[\d,]*').firstMatch(text);

    if (numberMatch == null) {
      return '0';
    }

    final number = int.tryParse(numberMatch.group(0)!.replaceAll(',', ''));

    if (number == null || number == 0) {
      return '0';
    }

    final formattedNumber = _addComma(number.abs().toString());

    if (direction == '+') {
      return '+$formattedNumber';
    }

    if (direction == '-') {
      return '-$formattedNumber';
    }

    if (direction == '0') {
      return '0';
    }

    // 방향을 찾지 못한 경우
    debugPrint('전일비 방향을 확인하지 못했습니다: $html');

    return formattedNumber;
  }

  /// 마지막 페이지 번호 추출
  int _parseLastPage(String html) {
    final pageNavigationMatch = RegExp(
      r'<td[^>]*pgRR[^>]*>(.*?)</td>',
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(html);

    if (pageNavigationMatch == null) {
      return 1;
    }

    final navigationHtml = pageNavigationMatch.group(1) ?? '';

    final pageNumbers = RegExp(
      r'(?:[?&]|&amp;)page=(\d+)',
      caseSensitive: false,
    ).allMatches(navigationHtml);

    var lastPage = 1;

    for (final match in pageNumbers) {
      final page = int.tryParse(match.group(1) ?? '');

      if (page != null && page > lastPage) {
        lastPage = page;
      }
    }

    return lastPage;
  }

  /// HTML 태그 및 공백 제거
  String _cleanHtmlText(String value) {
    var text = value;

    text = text.replaceAll(RegExp(r'<[^>]+>'), '');

    text = text
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');

    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// 날짜를 yyyyMMdd로 정규화
  String _normalizeDate(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.length != 8) {
      return '';
    }

    return digits;
  }

  /// 숫자 문자열 정리
  String _normalizeNumber(String value) {
    return value.replaceAll(',', '').trim();
  }

  /// 전일비 부호 정리
  ///
  /// 기존 코드와의 호환성을 위해 유지한다.
  String _normalizeChange(String value) {
    final normalized = value
        .replaceAll(',', '')
        .replaceAll('▲', '+')
        .replaceAll('▼', '-')
        .trim();

    if (normalized.isEmpty || normalized == '0') {
      return '0';
    }

    if (normalized.startsWith('+') || normalized.startsWith('-')) {
      return normalized;
    }

    return normalized;
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

      if (nationCode != 'KOR') {
        continue;
      }

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

/// 일별 시세 페이지 조회 결과
class DailyPricePageResult {
  final List<DailyPrice> prices;
  final int lastPage;

  const DailyPricePageResult({required this.prices, required this.lastPage});
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

    final change = _calculateChange(
      price: json['nv'],
      previousClose: json['pcv'],
    );

    final changeRate = _formatChangeRate(
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

  static String _formatChangeRate({
    required dynamic price,
    required dynamic previousClose,
  }) {
    final current = _toDouble(price);
    final previous = _toDouble(previousClose);

    if (current == null || previous == null || previous == 0) {
      return '';
    }

    final calculated = ((current - previous) / previous) * 100;

    if (calculated == 0) {
      return '0.00%';
    }

    return calculated > 0
        ? '+${calculated.toStringAsFixed(2)}%'
        : '${calculated.toStringAsFixed(2)}%';
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
