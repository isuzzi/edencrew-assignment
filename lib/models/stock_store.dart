import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'stock.dart';
import 'naver_search_result.dart';
import 'daily_price.dart';
import '../services/naver_api_service.dart';

class StockStore extends ChangeNotifier {
  final NaverApiService _apiService;

  static const String _favoritesKey = 'favorite_stocks';

  StockStore({NaverApiService? apiService})
    : _apiService = apiService ?? NaverApiService() {
    _initialize();
  }

  final List<Stock> stocks = [
    Stock(
      name: '삼성전자',
      symbol: '005930',
      market: '코스피',
      price: '179,700',
      change: '-400',
      changeRate: '-0.22%',
    ),
    Stock(
      name: 'SK하이닉스',
      symbol: '000660',
      market: '코스피',
      price: '412,500',
      change: '+9,500',
      changeRate: '+2.36%',
    ),
    Stock(
      name: '카카오',
      symbol: '035720',
      market: '코스피',
      price: '61,300',
      change: '-800',
      changeRate: '-1.29%',
    ),
    Stock(
      name: '에코프로비엠',
      symbol: '247540',
      market: '코스닥',
      price: '195,400',
      change: '0',
      changeRate: '0.00%',
    ),
    Stock(
      name: 'LG에너지솔루션',
      symbol: '373220',
      market: '코스피',
      price: '',
      change: '',
      changeRate: '',
    ),
  ];

  List<Stock> get favoriteStocks =>
      stocks.where((stock) => stock.isFavorite).toList();

  /*
   * 종목별 페이지 캐시
   *
   * {
   *   '005930': {
   *      1: [DailyPrice, ...],
   *      2: [DailyPrice, ...],
   *   }
   * }
   */
  final Map<String, Map<int, List<DailyPrice>>> _dailyPriceCache = {};

  /*
   * 종목별 마지막 페이지
   *
   * 네이버 응답의 lastPage를 저장한다.
   */
  final Map<String, int> _dailyPriceLastPage = {};

  /// 앱 시작
  Future<void> _initialize() async {
    await _loadFavorites();
    await _refreshFavorites();

    notifyListeners();
  }

  /// 관심 종목 추가 / 삭제
  void toggleFavorite(Stock stock) {
    if (!stocks.contains(stock)) {
      stocks.add(stock);
    }

    stock.isFavorite = !stock.isFavorite;

    _saveFavorites();

    notifyListeners();
  }

  /// 관심 종목 저장
  Future<void> _saveFavorites() async {
    try {
      final preferences = await SharedPreferences.getInstance();

      final favoriteData = favoriteStocks
          .map((stock) => stock.toJson())
          .toList();

      await preferences.setString(_favoritesKey, jsonEncode(favoriteData));

      debugPrint(
        '관심 종목 저장 완료: '
        '${favoriteStocks.length}개',
      );
    } catch (e) {
      debugPrint('관심 종목 저장 실패: $e');
    }
  }

  /// 관심 종목 복원
  Future<void> _loadFavorites() async {
    try {
      final preferences = await SharedPreferences.getInstance();

      final savedData = preferences.getString(_favoritesKey);

      if (savedData == null || savedData.isEmpty) {
        debugPrint('저장된 관심 종목이 없습니다.');
        return;
      }

      final List<dynamic> decodedData = jsonDecode(savedData);

      for (final item in decodedData) {
        final savedStock = Stock.fromJson(Map<String, dynamic>.from(item));

        Stock? existingStock;

        for (final stock in stocks) {
          if (stock.symbol == savedStock.symbol) {
            existingStock = stock;
            break;
          }
        }

        if (existingStock != null) {
          existingStock.isFavorite = true;
        } else {
          savedStock.isFavorite = true;
          stocks.add(savedStock);
        }
      }

      debugPrint(
        '관심 종목 복원 완료: '
        '${favoriteStocks.length}개',
      );

      notifyListeners();
    } catch (e) {
      debugPrint('관심 종목 복원 실패: $e');
    }
  }

  /// 관심 종목 새로고침
  Future<void> refreshFavorites() async {
    await _refreshFavorites();

    notifyListeners();
  }

  /// 실제 관심 종목 시세 및 메타데이터 업데이트
  Future<void> _refreshFavorites() async {
    final favorites = favoriteStocks;

    if (favorites.isEmpty) {
      return;
    }

    for (final stock in favorites) {
      try {
        final metadataResult = await _apiService.getStockMetadata(stock.symbol);

        stock.name = metadataResult.name;
        stock.market = metadataResult.exchangeName;

        debugPrint(
          '관심 종목 메타데이터 적용: '
          '${stock.symbol} / '
          '${stock.name} / '
          '${stock.market}',
        );
      } catch (e) {
        debugPrint(
          '관심 종목 메타데이터 조회 실패 '
          '${stock.symbol}: $e',
        );
      }

      try {
        final priceResult = await _apiService.getStockPrice(stock.symbol);

        stock.price = priceResult.price;
        stock.change = priceResult.change;
        stock.changeRate = priceResult.changeRate;

        stock.openPrice = priceResult.openPrice;
        stock.highPrice = priceResult.highPrice;
        stock.lowPrice = priceResult.lowPrice;
        stock.tradingVolume = priceResult.tradingVolume;
        stock.marketCap = priceResult.marketCap;

        debugPrint(
          '시세 업데이트: '
          '${stock.name}(${stock.symbol}) '
          '${stock.price} '
          '${stock.changeRate}',
        );
      } catch (e) {
        debugPrint(
          '관심 종목 시세 조회 실패 '
          '${stock.name}(${stock.symbol}): $e',
        );
      }
    }
  }

  /// 종목 검색
  Future<List<Stock>> search(String query) async {
    final normalizedQuery = query.trim();

    if (normalizedQuery.isEmpty) {
      return [];
    }

    final results = await _apiService.searchStocks(normalizedQuery);

    final searchStocks = <Stock>[];

    for (final result in results) {
      final stock = _toStock(result);

      try {
        final metadataResult = await _apiService.getStockMetadata(stock.symbol);

        stock.name = metadataResult.name;
        stock.market = metadataResult.exchangeName;

        debugPrint(
          '메타데이터 적용: '
          '${stock.symbol} / '
          '${stock.name} / '
          '${stock.market}',
        );
      } catch (e) {
        debugPrint(
          '메타데이터 조회 실패 '
          '${stock.symbol}: $e',
        );
      }

      try {
        final priceResult = await _apiService.getStockPrice(stock.symbol);

        stock.price = priceResult.price;
        stock.change = priceResult.change;
        stock.changeRate = priceResult.changeRate;

        stock.openPrice = priceResult.openPrice;
        stock.highPrice = priceResult.highPrice;
        stock.lowPrice = priceResult.lowPrice;
        stock.tradingVolume = priceResult.tradingVolume;
        stock.marketCap = priceResult.marketCap;
      } catch (e) {
        debugPrint(
          '검색 종목 시세 조회 실패 '
          '${stock.name}(${stock.symbol}): $e',
        );
      }

      searchStocks.add(stock);
    }

    return searchStocks;
  }

  /// 기간에 필요한 일별 시세 조회
  Future<List<DailyPrice>> getDailyPricesForPeriod(
    String symbol,
    String period,
  ) async {
    final requiredPages = _requiredPages(period);

    final cachedPages = _dailyPriceCache[symbol] ??= {};

    var lastPage = _dailyPriceLastPage[symbol];

    /*
     * 필요한 페이지까지만 요청한다.
     *
     * 이미 캐시된 페이지는 절대 다시 요청하지 않는다.
     */
    for (var page = 1; page <= requiredPages; page++) {
      if (cachedPages.containsKey(page)) {
        continue;
      }

      /*
       * 이미 확인한 lastPage보다 큰 페이지라면
       * 더 이상 요청하지 않는다.
       */
      if (lastPage != null && page > lastPage) {
        break;
      }

      try {
        final result = await _apiService.getDailyPrices(symbol, page);

        cachedPages[page] = result.prices;

        lastPage = result.lastPage;

        _dailyPriceLastPage[symbol] = result.lastPage;

        debugPrint(
          '일별 시세 캐시 저장: '
          '$symbol / page=$page',
        );

        /*
         * 현재 페이지 자체가 마지막 페이지라면
         * 이후 페이지는 요청할 필요가 없다.
         */
        if (page >= result.lastPage) {
          break;
        }
      } catch (e) {
        debugPrint(
          '일별 시세 조회 실패: '
          '$symbol / page=$page / $e',
        );

        rethrow;
      }
    }

    final prices = <DailyPrice>[];

    for (var page = 1; page <= requiredPages; page++) {
      final pagePrices = cachedPages[page];

      if (pagePrices == null) {
        continue;
      }

      prices.addAll(pagePrices);
    }

    /*
     * 네이버 데이터는 최신 날짜부터 내려오므로
     * 필요한 기간만큼 잘라낸다.
     */
    return prices.take(_requiredTradingDays(period)).toList();
  }

  /// 기간별 필요한 페이지 수
  int _requiredPages(String period) {
    switch (period) {
      case '1개월':
        return 2;

      case '3개월':
        return 6;

      case '6개월':
        return 12;

      case '1년':
        return 25;

      default:
        return 2;
    }
  }

  /// 기간별 필요한 거래일 수
  int _requiredTradingDays(String period) {
    switch (period) {
      case '1개월':
        return 20;

      case '3개월':
        return 60;

      case '6개월':
        return 120;

      case '1년':
        return 245;

      default:
        return 20;
    }
  }

  /// 특정 종목의 일별 시세 캐시 초기화
  void clearDailyPriceCache(String symbol) {
    _dailyPriceCache.remove(symbol);
    _dailyPriceLastPage.remove(symbol);
  }

  /// 검색 결과 → Stock
  Stock _toStock(NaverSearchResult result) {
    for (final stock in stocks) {
      if (stock.symbol == result.symbol) {
        return stock;
      }
    }

    return Stock(
      name: result.name,
      symbol: result.symbol,
      market: _marketName(result),
    );
  }

  /// 시장명 변환
  String _marketName(NaverSearchResult result) {
    if (result.typeName.contains('코스닥')) {
      return '코스닥';
    }

    if (result.typeName.contains('코스피')) {
      return '코스피';
    }

    return result.typeName;
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
}
