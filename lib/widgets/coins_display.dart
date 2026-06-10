import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../coins_system/coins_provider.dart';
import '../utils/app_theme.dart';

class CoinsDisplay extends StatelessWidget {
  final bool large;
  const CoinsDisplay({super.key, this.large = false});

  @override
  Widget build(BuildContext context) {
    final coins = context.watch<CoinsProvider>().coins;
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: large ? 16 : 10, vertical: large ? 8 : 6),
      decoration: BoxDecoration(
        color: AppTheme.goldPrimary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.goldDark.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
              color: AppTheme.glowGold.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 0),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🪙', style: TextStyle(fontSize: large ? 20 : 16)),
          const SizedBox(width: 6),
          Text(
            '$coins',
            style: TextStyle(
              color: AppTheme.goldPrimary,
              fontSize: large ? 20 : 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
