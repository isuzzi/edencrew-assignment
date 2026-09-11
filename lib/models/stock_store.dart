import 'package:flutter/foundation.dart';
import 'stock.dart';

class StockStore extends ChangeNotifier {
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

  void toggleFavorite(Stock stock) {
    stock.isFavorite = !stock.isFavorite;
    notifyListeners();
  }
}
