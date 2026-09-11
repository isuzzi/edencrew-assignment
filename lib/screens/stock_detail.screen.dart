import 'package:flutter/material.dart';
import '../theme/theme.dart';

import '../widgets/stock/stock_detail_header.dart';
import '../widgets/stock/stock_period_selector.dart';
import '../widgets/stock/stock_price_chart.dart';
import '../widgets/stock/stock_summary_grid.dart';
import '../widgets/stock/stock_daily_price_table.dart';

class StockDetailScreen extends StatefulWidget {
  final String stockName;
  final String symbol;
  final String market;

  const StockDetailScreen({
    super.key,
    this.stockName = '삼성전자',
    this.symbol = '005930',
    this.market = '코스피',
  });

  @override
  State<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  String selectedPeriod = '1개월';
  bool isFavorite = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surfaceBase,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: StockDetailHeader(
                stockName: widget.stockName,
                symbol: widget.symbol,
                market: widget.market,
                isFavorite: isFavorite,
                onBackTap: () => Navigator.of(context).pop(),
                onFavoriteTap: () {
                  setState(() {
                    isFavorite = !isFavorite;
                  });
                },
              ),
            ),

            SliverToBoxAdapter(child: _CurrentPrice()),

            SliverToBoxAdapter(
              child: StockPeriodSelector(
                selectedPeriod: selectedPeriod,
                onChanged: (period) {
                  setState(() {
                    selectedPeriod = period;
                  });
                },
              ),
            ),

            SliverToBoxAdapter(child: StockPriceChart(period: selectedPeriod)),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            const SliverToBoxAdapter(child: StockSummaryGrid()),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            const SliverToBoxAdapter(child: StockDailyPriceTable()),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

class _CurrentPrice extends StatelessWidget {
  const _CurrentPrice();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '179,700',
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 32,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Row(
              children: [
                Icon(
                  Icons.arrow_drop_down,
                  size: 22,
                  color: context.colors.chartLineDown,
                ),
                Text(
                  '400',
                  style: TextStyle(
                    color: context.colors.chartLineDown,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '(-0.22%)',
                  style: TextStyle(
                    color: context.colors.chartLineDown,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
