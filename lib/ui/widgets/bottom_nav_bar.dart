import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/constants/colors.dart';

/// Reusable bottom navigation bar widget.
class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget _item(IconData icon, int idx) {
      final bool active = idx == selectedIndex;
      return GestureDetector(
        onTap: () => onTap(idx),
        child: Container(
          width: 48,
          height: 48,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: active
                ? AppColors.primary20.withOpacity(0.35)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(
              color: active
                  ? AppColors.primary20.withOpacity(0.35)
                  : AppColors.neutral.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: active ? AppColors.primary60 : AppColors.neutral100,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.neutral20.withOpacity(0.2),
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: AppColors.neutral.withOpacity(0.5), width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _item(HugeIcons.strokeRoundedHome08, 0),
              _item(HugeIcons.strokeRoundedIrisScan, 1),
              _item(HugeIcons.strokeRoundedGem, 2),
            ],
          ),
        ),
      ),
    );
  }
}