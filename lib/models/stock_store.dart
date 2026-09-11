import 'package:flutter/foundation.dart';

import 'stock.dart';
import 'naver_search_result.dart';
import '../services/naver_api_service.dart';

class StockStore extends ChangeNotifier {
  final NaverApiService _apiService;

  StockStore({NaverApiService? apiService})
    : _apiService = apiService ?? NaverApiService();

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

  /// 관심 종목 추가 / 삭제
  void toggleFavorite(Stock stock) {
    // 검색 결과로 새롭게 생성된 Stock이라면
    // 관심 목록에서 사용할 수 있도록 stocks에 추가한다.
    if (!stocks.contains(stock)) {
      stocks.add(stock);
    }

    stock.isFavorite = !stock.isFavorite;

    notifyListeners();
  }

  /// 관심 종목 새로고침
  // TODO: 실시간 시세 API 연결 후 구현
  Future<void> refreshFavorites() async {
    await Future.delayed(const Duration(milliseconds: 500));

    notifyListeners();
  }

  /// 종목 검색
  Future<List<Stock>> search(String query) async {
    final normalizedQuery = query.trim();

    if (normalizedQuery.isEmpty) {
      return [];
    }

    final results = await _apiService.searchStocks(normalizedQuery);

    return results.map(_toStock).toList();
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
