import 'package:flutter/material.dart';

import '../theme/theme.dart';

import '../models/stock.dart';
import '../models/stock_store.dart';
import '../models/daily_price.dart';

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

  List<DailyPrice> dailyPrices = [];

  bool isDailyPriceLoading = true;

  String? dailyPriceError;

  @override
  void initState() {
    super.initState();

    _loadDailyPrices(selectedPeriod);
  }

  Future<void> _loadDailyPrices(String period) async {
    setState(() {
      isDailyPriceLoading = true;
      dailyPriceError = null;
    });

    try {
      final prices = await widget.store.getDailyPricesForPeriod(
        widget.stock.symbol,
        period,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        dailyPrices = prices;
        isDailyPriceLoading = false;
      });
    } catch (e) {
      debugPrint(
        '일별 시세 화면 조회 실패: '
        '${widget.stock.symbol} / $period / $e',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        dailyPrices = [];
        isDailyPriceLoading = false;
        dailyPriceError = '일별 시세를 불러오지 못했습니다.';
      });
    }
  }

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

                  _loadDailyPrices(period);
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

            SliverToBoxAdapter(
              child: _DailyPriceSection(
                prices: dailyPrices,
                isLoading: isDailyPriceLoading,
                error: dailyPriceError,
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

class _DailyPriceSection extends StatelessWidget {
  final List<DailyPrice> prices;
  final bool isLoading;
  final String? error;

  const _DailyPriceSection({
    required this.prices,
    required this.isLoading,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '일별 시세',
              style: TextStyle(
                color: context.colors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ],
        ),
      );
    }

    if (error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '일별 시세',
              style: TextStyle(
                color: context.colors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                error!,
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return StockDailyPriceTable(prices: prices);
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

    final isFlat = change == '0' || change.isEmpty;

    final changeColor = isFlat
        ? context.colors.priceFlatText
        : isDown
        ? context.colors.chartLineDown
        : context.colors.chartLineUp;

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
                  isFlat
                      ? Icons.remove
                      : isDown
                      ? Icons.arrow_drop_down
                      : Icons.arrow_drop_up,
                  size: 22,
                  color: changeColor,
                ),
                Text(
                  change,
                  style: TextStyle(
                    color: changeColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '($changeRate)',
                  style: TextStyle(
                    color: changeColor,
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
