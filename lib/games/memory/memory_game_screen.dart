import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../coins_system/coins_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_constants.dart';
import '../../widgets/game_app_bar.dart';
import '../../widgets/gold_button.dart';
import '../../ads/banner_ad_widget.dart';

class MemoryGameScreen extends StatefulWidget {
  const MemoryGameScreen({super.key});

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  static const List<String> _emojis = [
    '👑', '💎', '🏆', '⚡', '🌟', '🎯', '🔥', '💰'
  ];

  late List<String> _cards;
  late List<bool> _flipped;
  late List<bool> _matched;
  int _firstIndex = -1;
  int _secondIndex = -1;
  bool _canFlip = true;
  int _moves = 0;
  int _matchedPairs = 0;
  bool _gameOver = false;
  late Stopwatch _stopwatch;
  Timer? _timer;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    final pairs = [..._emojis, ..._emojis];
    pairs.shuffle(Random());
    _cards = pairs;
    _flipped = List.filled(16, false);
    _matched = List.filled(16, false);
    _firstIndex = -1;
    _secondIndex = -1;
    _canFlip = true;
    _moves = 0;
    _matchedPairs = 0;
    _gameOver = false;
    _stopwatch = Stopwatch()..start();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsedSeconds = _stopwatch.elapsed.inSeconds);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onCardTap(int index) {
    if (!_canFlip || _flipped[index] || _matched[index]) return;

    setState(() {
      _flipped[index] = true;
      if (_firstIndex == -1) {
        _firstIndex = index;
      } else {
        _secondIndex = index;
        _canFlip = false;
        _moves++;
        _checkMatch();
      }
    });
  }

  void _checkMatch() {
    Timer(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() {
        if (_cards[_firstIndex] == _cards[_secondIndex]) {
          _matched[_firstIndex] = true;
          _matched[_secondIndex] = true;
          _matchedPairs++;
          if (_matchedPairs == 8) _onGameOver();
        } else {
          _flipped[_firstIndex] = false;
          _flipped[_secondIndex] = false;
        }
        _firstIndex = -1;
        _secondIndex = -1;
        _canFlip = true;
      });
    });
  }

  void _onGameOver() {
    _stopwatch.stop();
    _timer?.cancel();
    _gameOver = true;
    final coins = context.read<CoinsProvider>();
    coins.addCoins(AppConstants.memoryWinCoins);
    coins.recordWin();
    coins.updateHighScoreMemory(_moves);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _showWinDialog();
    });
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: AppTheme.cardGradient,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.goldPrimary, width: 1.5),
            boxShadow: [BoxShadow(color: AppTheme.glowGold, blurRadius: 30)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🏆', style: TextStyle(fontSize: 60)),
              const SizedBox(height: 12),
              const Text('YOU WIN!',
                  style: TextStyle(
                      color: AppTheme.goldPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3)),
              const SizedBox(height: 12),
              Text('Moves: $_moves  |  Time: ${_elapsedSeconds}s',
                  style: const TextStyle(color: AppTheme.textGrey, fontSize: 14)),
              const SizedBox(height: 8),
              Text('+${AppConstants.memoryWinCoins} 🪙',
                  style: const TextStyle(
                      color: AppTheme.goldLight,
                      fontSize: 26,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GoldButton(
                      label: 'AGAIN',
                      onTap: () {
                        Navigator.pop(context);
                        setState(() => _initGame());
                      }),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text('HOME',
                          style: TextStyle(color: AppTheme.textGrey))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _timerText {
    final m = _elapsedSeconds ~/ 60;
    final s = _elapsedSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GameAppBar(
        title: 'MEMORY',
        scoreWidget: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Text('⏱ $_timerText',
                  style: const TextStyle(
                      color: AppTheme.goldDark, fontSize: 13)),
              const SizedBox(width: 8),
              Text('🎯 $_moves',
                  style: const TextStyle(
                      color: AppTheme.textGrey, fontSize: 13)),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: 16,
                  itemBuilder: (_, i) => _buildCard(i),
                ),
              ),
            ),
            const BannerAdWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(int index) {
    final isFlipped = _flipped[index];
    final isMatched = _matched[index];

    return GestureDetector(
      onTap: () => _onCardTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: isMatched
              ? const LinearGradient(
                  colors: [Color(0xFF1A3A1A), Color(0xFF0D2010)])
              : isFlipped
                  ? const LinearGradient(
                      colors: [Color(0xFF2A2010), Color(0xFF1A1508)])
                  : AppTheme.cardGradient,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isMatched
                ? AppTheme.snakeGreen.withOpacity(0.6)
                : isFlipped
                    ? AppTheme.goldDark.withOpacity(0.6)
                    : AppTheme.cardBorder,
            width: isMatched ? 2 : 1,
          ),
          boxShadow: isMatched
              ? [BoxShadow(
                  color: AppTheme.snakeGreen.withOpacity(0.2),
                  blurRadius: 8)]
              : null,
        ),
        child: Center(
          child: isFlipped || isMatched
              ? Text(_cards[index],
                  style: const TextStyle(fontSize: 26))
                  .animate()
                  .scale(duration: 200.ms, curve: Curves.elasticOut)
              : const Text('♛',
                  style: TextStyle(
                      color: AppTheme.goldDark,
                      fontSize: 22)),
        ),
      ),
    );
  }
}
