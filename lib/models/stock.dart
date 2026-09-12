class Stock {
  String name;
  final String symbol;
  String market;
  String price;
  String change;
  String changeRate;
  String openPrice;
  String highPrice;
  String lowPrice;
  String tradingVolume;
  String marketCap;

  bool isFavorite;

  Stock({
    required this.name,
    required this.symbol,
    required this.market,
    this.price = '',
    this.change = '',
    this.changeRate = '',
    this.isFavorite = false,
    this.openPrice = '',
    this.highPrice = '',
    this.lowPrice = '',
    this.tradingVolume = '',
    this.marketCap = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'symbol': symbol,
      'market': market,
      'isFavorite': isFavorite,
    };
  }

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      name: json['name'] as String,
      symbol: json['symbol'] as String,
      market: json['market'] as String,
      isFavorite: json['isFavorite'] as bool? ?? true,
    );
  }
}
