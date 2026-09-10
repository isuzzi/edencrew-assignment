import 'package:flutter/material.dart';

class WatchlistItem extends StatelessWidget {
  final String name;
  final String code;
  final String market;
  final String price;
  final String change;

  const WatchlistItem({
    super.key,
    required this.name,
    required this.code,
    required this.market,
    required this.price,
    required this.change,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = change.startsWith('+');
    final isNegative = change.startsWith('-');

    Color changeColor = Colors.grey;

    if (isPositive) {
      changeColor = Colors.red;
    } else if (isNegative) {
      changeColor = Colors.blue;
    }

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF242424), width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$code · $market',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (price.isNotEmpty)
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                )
              else
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 16,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 3),

              if (change.isNotEmpty)
                Text(change, style: TextStyle(fontSize: 11, color: changeColor))
              else
                Container(
                  width: 48,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
