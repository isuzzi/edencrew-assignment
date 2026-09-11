class Stock {
  final String name;
  final String symbol;
  final String market;
  final String price;
  final String change;
  final String changeRate;

  bool isFavorite;

  Stock({
    required this.name,
    required this.symbol,
    required this.market,
    this.price = '',
    this.change = '',
    this.changeRate = '',
    this.isFavorite = false,
  });
}
