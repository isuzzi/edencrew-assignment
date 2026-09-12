class DailyPrice {
  final String date;
  final String closePrice;
  final String change;
  final String openPrice;
  final String highPrice;
  final String lowPrice;
  final String tradingVolume;

  const DailyPrice({
    required this.date,
    required this.closePrice,
    required this.change,
    required this.openPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.tradingVolume,
  });

  bool get isUp => change.startsWith('+');

  bool get isDown => change.startsWith('-');

  bool get isFlat => !isUp && !isDown;

  /// yyyyMMdd → MM.DD
  String get displayDate {
    if (date.length != 8) {
      return date;
    }

    return '${date.substring(4, 6)}.${date.substring(6, 8)}';
  }
}
