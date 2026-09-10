import 'package:flutter/material.dart';

class SortBottomSheet extends StatelessWidget {
  final String selectedSort;
  final ValueChanged<String> onSelected;

  const SortBottomSheet({
    super.key,
    required this.selectedSort,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      decoration: const BoxDecoration(
        color: Color(0xFF242422),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '정렬',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 28),

          _SortItem(
            title: '현재가순',
            selected: selectedSort == '현재가순',
            onTap: () => onSelected('현재가순'),
          ),

          _SortItem(
            title: '등락률순',
            selected: selectedSort == '등락률순',
            onTap: () => onSelected('등락률순'),
          ),

          _SortItem(
            title: '가나다순',
            selected: selectedSort == '가나다순',
            onTap: () => onSelected('가나다순'),
          ),
        ],
      ),
    );
  }
}

class _SortItem extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _SortItem({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                color: selected ? Colors.white : Colors.grey,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),

            const Spacer(),

            // 체크 아이콘 자리
            if (selected) const SizedBox(width: 24, height: 24),
          ],
        ),
      ),
    );
  }
}
