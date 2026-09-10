import 'package:flutter/material.dart';

class EmptyWatchlist extends StatelessWidget {
  const EmptyWatchlist({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('관심종목이 없습니다'));
  }
}
