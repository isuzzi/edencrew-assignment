import 'package:flutter/material.dart';
import '../theme/theme.dart';

import '../models/stock.dart';
import '../models/stock_store.dart';

import '../widgets/stock/stock_detail_header.dart';
import '../widgets/stock/stock_period_selector.dart';
import '../widgets/stock/stock_price_chart.dart';
import '../widgets/stock/stock_summary_grid.dart';
import '../widgets/stock/stock_daily_price_table.dart';

class StockDetailScreen extends StatefulWidget {
  final StockStore store;
  final Stock stock;

  const StockDetailScreen({
    super.key,
    required this.store,
    required this.stock,
  });

  @override
  State<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  String selectedPeriod = '1개월';

  @override
  Widget build(BuildContext context) {
    final stock = widget.stock;

    return Scaffold(
      backgroundColor: context.colors.surfaceBase,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: StockDetailHeader(
                stockName: stock.name,
                symbol: stock.symbol,
                market: stock.market,
                onBackTap: () => Navigator.of(context).pop(),
                isFavorite: stock.isFavorite,
              ),
            ),

            SliverToBoxAdapter(
              child: _CurrentPrice(
                price: stock.price,
                change: stock.change,
                changeRate: stock.changeRate,
              ),
            ),

            SliverToBoxAdapter(
              child: StockPeriodSelector(
                selectedPeriod: selectedPeriod,
                onChanged: (period) {
                  setState(() {
                    selectedPeriod = period;
                  });
                },
                onFavoriteTap: () {
                  widget.store.toggleFavorite(stock);
                  setState(() {});
                },
              ),
            ),

            SliverToBoxAdapter(child: StockPriceChart(period: selectedPeriod)),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            SliverToBoxAdapter(
              child: StockSummaryGrid(
                openPrice: stock.openPrice,
                highPrice: stock.highPrice,
                lowPrice: stock.lowPrice,
                tradingVolume: stock.tradingVolume,
                marketCap: stock.marketCap,
              ),
            ),
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
  final String price;
  final String change;
  final String changeRate;

  const _CurrentPrice({
    required this.price,
    required this.change,
    required this.changeRate,
  });

  @override
  Widget build(BuildContext context) {
    final isDown = change.startsWith('-');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            price,
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
                  isDown ? Icons.arrow_drop_down : Icons.arrow_drop_up,
                  size: 22,
                  color: isDown
                      ? context.colors.chartLineDown
                      : context.colors.chartLineUp,
                ),
                Text(
                  change,
                  style: TextStyle(
                    color: isDown
                        ? context.colors.chartLineDown
                        : context.colors.chartLineUp,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '($changeRate)',
                  style: TextStyle(
                    color: isDown
                        ? context.colors.chartLineDown
                        : context.colors.chartLineUp,
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
