import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class SearchInitialState extends StatelessWidget {
  const SearchInitialState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search, size: 40, color: context.colors.textTertiary),
          const SizedBox(height: 16),
          Text(
            '종목을 검색해 보세요',
            style: TextStyle(
              color: context.colors.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '종목명 또는 종목코드 6자리로\n검색하실 수 있습니다.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.colors.textTertiary,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
