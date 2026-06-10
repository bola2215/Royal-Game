import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../coins_system/coins_provider.dart';
import '../utils/app_theme.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final coins = context.watch<CoinsProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios,
                          color: AppTheme.goldPrimary),
                    ),
                    const Expanded(
                      child: Text('LEADERBOARD',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: AppTheme.goldPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4)),
                    ),
                    const SizedBox(width: 44),
                  ],
                ),
              ),

              // Stats Cards
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _StatCard(
                          icon: '🪙',
                          label: 'Total Coins',
                          value: '${coins.coins}'),
                      const SizedBox(height: 12),
                      _StatCard(
                          icon: '🏆',
                          label: 'Total Wins',
                          value: '${coins.totalWins}'),
                      const SizedBox(height: 12),
                      _StatCard(
                          icon: '🎮',
                          label: 'Games Played',
                          value: '${coins.gamesPlayed}'),
                      const SizedBox(height: 24),
                      const Divider(color: AppTheme.cardBorder),
                      const SizedBox(height: 16),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('HIGH SCORES',
                            style: TextStyle(
                                color: AppTheme.goldDark,
                                fontSize: 11,
                                letterSpacing: 3)),
                      ),
                      const SizedBox(height: 12),
                      _StatCard(
                          icon: '🐍',
                          label: 'Snake Best',
                          value: '${coins.highScoreSnake}'),
                      const SizedBox(height: 12),
                      _StatCard(
                          icon: '🔢',
                          label: '2048 Best',
                          value: '${coins.highScore2048}'),
                      const SizedBox(height: 12),
                      _StatCard(
                          icon: '🃏',
                          label: 'Memory Best (moves)',
                          value: coins.highScoreMemory == 0
                              ? '-'
                              : '${coins.highScoreMemory}'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _StatCard(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    color: AppTheme.textGrey, fontSize: 14)),
          ),
          Text(value,
              style: const TextStyle(
                  color: AppTheme.goldPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
