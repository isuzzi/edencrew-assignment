import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'stock.dart';
import 'naver_search_result.dart';
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

  /// 앱 시작 시 로컬 관심 종목을 불러온다.
  Future<void> _initialize() async {
    await _loadFavorites();

    // 로컬에서 복원한 관심 종목의 최신 시세를 가져온다.
    await _refreshFavorites();

    notifyListeners();
  }

  /// 관심 종목 추가 / 삭제
  void toggleFavorite(Stock stock) {
    // 검색 결과로 새롭게 생성된 Stock이라면
    // 관심 목록에서 사용할 수 있도록 stocks에 추가한다.
    if (!stocks.contains(stock)) {
      stocks.add(stock);
    }

    stock.isFavorite = !stock.isFavorite;

    // 관심 목록이 변경될 때마다 로컬에 저장한다.
    _saveFavorites();

    notifyListeners();
  }

  /// 관심 종목을 로컬에 저장한다.
  Future<void> _saveFavorites() async {
    try {
      final preferences = await SharedPreferences.getInstance();

      final favoriteData = favoriteStocks
          .map((stock) => stock.toJson())
          .toList();

      await preferences.setString(_favoritesKey, jsonEncode(favoriteData));

      debugPrint('관심 종목 저장 완료: ${favoriteStocks.length}개');
    } catch (e) {
      debugPrint('관심 종목 저장 실패: $e');
    }
  }

  /// 로컬에 저장된 관심 종목을 불러온다.
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

        // 기본 stocks에 이미 존재하는 종목이라면
        // 기존 Stock 객체를 사용한다.
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
          // 검색을 통해 새롭게 추가했던 종목이라면
          // 로컬 데이터로 Stock을 새로 생성한다.
          savedStock.isFavorite = true;
          stocks.add(savedStock);
        }
      }

      debugPrint('관심 종목 복원 완료: ${favoriteStocks.length}개');

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
      // 메타데이터 API
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

      // 시세 API
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

  /// API 검색 결과를 앱의 Stock 모델로 변환
  Stock _toStock(NaverSearchResult result) {
    // 이미 Store에 존재하는 종목이라면
    // 기존 Stock 객체를 그대로 사용한다.
    //
    // 이렇게 해야 기존 isFavorite 상태가 유지된다.
    for (final stock in stocks) {
      if (stock.symbol == result.symbol) {
        return stock;
      }
    }

    // 처음 검색된 종목은 새로운 Stock 객체를 만든다.
    return Stock(
      name: result.name,
      symbol: result.symbol,
      market: _marketName(result),
    );
  }

  /// Naver API의 시장 정보를 앱에서 사용하는 시장명으로 변환
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
