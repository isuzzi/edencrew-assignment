class NaverSearchResult {
  final String id;
  final String symbol;
  final String name;
  final String typeCode;
  final String typeName;
  final String nationCode;
  final String category;

  const NaverSearchResult({
    required this.id,
    required this.symbol,
    required this.name,
    required this.typeCode,
    required this.typeName,
    required this.nationCode,
    required this.category,
  });

  factory NaverSearchResult.fromJson(Map<String, dynamic> json) {
    final symbol = json['code']?.toString() ?? '';

    return NaverSearchResult(
      id: 'domestic:$symbol',
      symbol: symbol,
      name: json['name']?.toString() ?? '',
      typeCode: json['typeCode']?.toString() ?? '',
      typeName: json['typeName']?.toString() ?? '',
      nationCode: json['nationCode']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
    );
  }
}
