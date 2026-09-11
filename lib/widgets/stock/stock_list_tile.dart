import 'package:flutter/material.dart';

class StockListTile extends StatelessWidget {
  final String stockName;
  final String symbol;
  final String market;
  final String price;
  final String change;
  final String changeRate;

  /// 검색어
  final String searchQuery;

  /// 가격 정보를 불러오는 중인지 여부
  final bool isLoading;

  final VoidCallback? onTap;

  const StockListTile({
    super.key,
    required this.stockName,
    required this.symbol,
    required this.market,
    required this.price,
    required this.change,
    required this.changeRate,
    this.searchQuery = '',
    this.isLoading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final changeValue = double.tryParse(
      change.replaceAll(',', '').replaceAll('+', ''),
    );

    final isUp = (changeValue ?? 0) > 0;
    final isDown = (changeValue ?? 0) < 0;

    final changeColor = isUp
        ? const Color(0xFFFF453A)
        : isDown
        ? const Color(0xFF3B9EFF)
        : const Color(0xFF888888);

    return InkWell(
      onTap: onTap,
      child: Container(
        height: 59,
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFF242424), width: 1),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // 종목 정보
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStockName(),
                  const SizedBox(height: 3),
                  Text(
                    '$symbol · $market',
                    style: const TextStyle(
                      color: Color(0xFF777777),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            // 가격 정보
            if (isLoading)
              const SizedBox(
                width: 64,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _LoadingBox(width: 64, height: 15),
                    SizedBox(height: 3),
                    _LoadingBox(width: 48, height: 13),
                  ],
                ),
              )
            else
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$change ($changeRate)',
                    style: TextStyle(
                      color: changeColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  /// 검색어와 일치하는 부분만 보라색으로 표시
  Widget _buildStockName() {
    // 검색어가 없으면 기존처럼 전체를 흰색으로 표시
    if (searchQuery.isEmpty) {
      return Text(
        stockName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    final lowerStockName = stockName.toLowerCase();
    final lowerQuery = searchQuery.toLowerCase();

    final matchIndex = lowerStockName.indexOf(lowerQuery);

    // 검색어가 종목명에 없으면 전체를 흰색으로 표시
    if (matchIndex == -1) {
      return Text(
        stockName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    final matchEnd = matchIndex + searchQuery.length;

    return Text.rich(
      TextSpan(
        children: [
          // 검색어 앞부분
          if (matchIndex > 0)
            TextSpan(
              text: stockName.substring(0, matchIndex),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),

          // 검색어와 일치하는 부분
          TextSpan(
            text: stockName.substring(matchIndex, matchEnd),
            style: const TextStyle(
              color: Color(0xFF8B5CF6),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),

          // 검색어 뒷부분
          if (matchEnd < stockName.length)
            TextSpan(
              text: stockName.substring(matchEnd),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _LoadingBox extends StatelessWidget {
  final double width;
  final double height;

  const _LoadingBox({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF282827),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
