import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const SearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: SizedBox(
        height: 40,
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          style: TextStyle(color: context.colors.textPrimary, fontSize: 14),
          cursorColor: context.colors.textPrimary,
          decoration: InputDecoration(
            filled: true,
            fillColor: context.colors.surfaceSunken,
            hintText: '종목명 또는 종목코드',
            hintStyle: TextStyle(
              color: context.colors.textTertiary,
              fontSize: 14,
            ),
            prefixIcon: Icon(
              Icons.search,
              size: 19,
              color: context.colors.textTertiary,
            ),
            suffixIcon: controller.text.isEmpty
                ? null
                : IconButton(
                    onPressed: onClear,
                    icon: Icon(
                      Icons.close,
                      size: 18,
                      color: context.colors.textTertiary,
                    ),
                  ),
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: context.colors.borderStrong),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: context.colors.borderStrong),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: context.colors.borderStrong),
            ),
          ),
        ),
      ),
    );
  }
}
