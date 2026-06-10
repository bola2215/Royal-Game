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

class Game2048Screen extends StatefulWidget {
  const Game2048Screen({super.key});

  @override
  State<Game2048Screen> createState() => _Game2048ScreenState();
}

class _Game2048ScreenState extends State<Game2048Screen> {
  static const int _size = 4;
  late List<List<int>> _grid;
  int _score = 0;
  bool _gameOver = false;
  bool _won = false;
  Offset? _dragStart;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    _grid = List.generate(_size, (_) => List.filled(_size, 0));
    _score = 0;
    _gameOver = false;
    _won = false;
    _addRandomTile();
    _addRandomTile();
  }

  void _addRandomTile() {
    final empties = <List<int>>[];
    for (int r = 0; r < _size; r++) {
      for (int c = 0; c < _size; c++) {
        if (_grid[r][c] == 0) empties.add([r, c]);
      }
    }
    if (empties.isEmpty) return;
    final pick = empties[Random().nextInt(empties.length)];
    _grid[pick[0]][pick[1]] = Random().nextDouble() < 0.9 ? 2 : 4;
  }

  List<List<int>> _copyGrid() =>
      _grid.map((r) => List<int>.from(r)).toList();

  bool _gridsEqual(List<List<int>> a, List<List<int>> b) {
    for (int r = 0; r < _size; r++) {
      for (int c = 0; c < _size; c++) {
        if (a[r][c] != b[r][c]) return false;
      }
    }
    return true;
  }

  List<int> _mergeRow(List<int> row) {
    final filtered = row.where((v) => v != 0).toList();
    final merged = <int>[];
    int i = 0;
    while (i < filtered.length) {
      if (i + 1 < filtered.length && filtered[i] == filtered[i + 1]) {
        final val = filtered[i] * 2;
        merged.add(val);
        _score += val;
        if (val == 2048 && !_won) {
          _won = true;
          _onWin();
        }
        i += 2;
      } else {
        merged.add(filtered[i]);
        i++;
      }
    }
    while (merged.length < _size) merged.add(0);
    return merged;
  }

  void _move(String dir) {
    if (_gameOver) return;
    final before = _copyGrid();

    if (dir == 'left') {
      for (int r = 0; r < _size; r++) {
        _grid[r] = _mergeRow(_grid[r]);
      }
    } else if (dir == 'right') {
      for (int r = 0; r < _size; r++) {
        _grid[r] = _mergeRow(_grid[r].reversed.toList()).reversed.toList();
      }
    } else if (dir == 'up') {
      for (int c = 0; c < _size; c++) {
        final col = List.generate(_size, (r) => _grid[r][c]);
        final merged = _mergeRow(col);
        for (int r = 0; r < _size; r++) {
          _grid[r][c] = merged[r];
        }
      }
    } else if (dir == 'down') {
      for (int c = 0; c < _size; c++) {
        final col =
            List.generate(_size, (r) => _grid[_size - 1 - r][c]);
        final merged = _mergeRow(col);
        for (int r = 0; r < _size; r++) {
          _grid[_size - 1 - r][c] = merged[r];
        }
      }
    }

    if (!_gridsEqual(before, _grid)) {
      _addRandomTile();
      context.read<CoinsProvider>().addCoins(AppConstants.game2048TileCoins);
    }

    if (_isGameOver()) {
      _gameOver = true;
      context.read<CoinsProvider>().updateHighScore2048(_score);
      context.read<CoinsProvider>().recordGame();
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _showGameOverDialog();
      });
    }

    setState(() {});
  }

  bool _isGameOver() {
    for (int r = 0; r < _size; r++) {
      for (int c = 0; c < _size; c++) {
        if (_grid[r][c] == 0) return false;
        if (r + 1 < _size && _grid[r][c] == _grid[r + 1][c]) return false;
        if (c + 1 < _size && _grid[r][c] == _grid[r][c + 1]) return false;
      }
    }
    return true;
  }

  void _onWin() {
    final coins = context.read<CoinsProvider>();
    coins.addCoins(50);
    coins.recordWin();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: AppTheme.cardGradient,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.goldPrimary, width: 2),
                boxShadow: [
                  BoxShadow(color: AppTheme.glowGoldBright, blurRadius: 40)
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('👑', style: TextStyle(fontSize: 70)),
                  const SizedBox(height: 12),
                  const Text('2048!',
                      style: TextStyle(
                          color: AppTheme.goldPrimary,
                          fontSize: 48,
                          fontWeight: FontWeight.bold)),
                  const Text('YOU DID IT!',
                      style: TextStyle(
                          color: AppTheme.textGrey,
                          fontSize: 14,
                          letterSpacing: 3)),
                  const SizedBox(height: 8),
                  const Text('+50 🪙 BONUS',
                      style: TextStyle(
                          color: AppTheme.goldLight,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  GoldButton(
                      label: 'KEEP PLAYING',
                      onTap: () => Navigator.pop(context)),
                ],
              ),
            ),
          ),
        );
      }
    });
  }

  void _showGameOverDialog() {
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
              const Text('🔢', style: TextStyle(fontSize: 60)),
              const SizedBox(height: 12),
              const Text('GAME OVER',
                  style: TextStyle(
                      color: AppTheme.goldPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3)),
              const SizedBox(height: 8),
              Text('Score: $_score',
                  style: const TextStyle(
                      color: AppTheme.textWhite,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GoldButton(
                      label: 'RETRY',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GameAppBar(
        title: '2048',
        scoreWidget: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Text('$_score',
              style: const TextStyle(
                  color: AppTheme.game2048Orange,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: Column(
          children: [
            // Score row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _ScoreBox(label: 'SCORE', value: _score),
                  _ScoreBox(
                      label: 'BEST',
                      value: context.watch<CoinsProvider>().highScore2048),
                  GoldButton(
                      label: 'NEW',
                      onTap: () => setState(() => _initGame())),
                ],
              ),
            ),

            // Board
            Expanded(
              child: Center(
                child: GestureDetector(
                  onPanStart: (d) => _dragStart = d.globalPosition,
                  onPanEnd: (d) {
                    if (_dragStart == null) return;
                    final dx = d.velocity.pixelsPerSecond.dx;
                    final dy = d.velocity.pixelsPerSecond.dy;
                    if (dx.abs() > dy.abs()) {
                      _move(dx > 0 ? 'right' : 'left');
                    } else {
                      _move(dy > 0 ? 'down' : 'up');
                    }
                    _dragStart = null;
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A24),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.cardBorder),
                        ),
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: _size,
                            crossAxisSpacing: 6,
                            mainAxisSpacing: 6,
                          ),
                          itemCount: _size * _size,
                          itemBuilder: (_, i) {
                            final r = i ~/ _size;
                            final c = i % _size;
                            return _TileWidget(value: _grid[r][c]);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Arrow controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 8),
              child: Column(
                children: [
                  IconButton(
                    onPressed: () => _move('up'),
                    icon: const Icon(Icons.keyboard_arrow_up,
                        color: AppTheme.game2048Orange, size: 36),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                          onPressed: () => _move('left'),
                          icon: const Icon(Icons.keyboard_arrow_left,
                              color: AppTheme.game2048Orange, size: 36)),
                      const SizedBox(width: 36),
                      IconButton(
                          onPressed: () => _move('right'),
                          icon: const Icon(Icons.keyboard_arrow_right,
                              color: AppTheme.game2048Orange, size: 36)),
                    ],
                  ),
                  IconButton(
                    onPressed: () => _move('down'),
                    icon: const Icon(Icons.keyboard_arrow_down,
                        color: AppTheme.game2048Orange, size: 36),
                  ),
                ],
              ),
            ),

            const BannerAdWidget(),
          ],
        ),
      ),
    );
  }
}

class _ScoreBox extends StatelessWidget {
  final String label;
  final int value;
  const _ScoreBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.game2048Orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: AppTheme.game2048Orange.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textGrey, fontSize: 10, letterSpacing: 2)),
          Text('$value',
              style: const TextStyle(
                  color: AppTheme.game2048Orange,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _TileWidget extends StatelessWidget {
  final int value;
  const _TileWidget({required this.value});

  static const Map<int, Color> _tileColors = {
    0: Color(0xFF1E1E28),
    2: Color(0xFF2D2A20),
    4: Color(0xFF3A3018),
    8: Color(0xFFCC6600),
    16: Color(0xFFCC4400),
    32: Color(0xFFCC2200),
    64: Color(0xFFBB1100),
    128: Color(0xFFDDA000),
    256: Color(0xFFCC9000),
    512: Color(0xFFBB7700),
    1024: Color(0xFFFFBB00),
    2048: Color(0xFFFFD700),
  };

  static const Map<int, Color> _textColors = {
    0: Colors.transparent,
    2: Color(0xFFDDCCAA),
    4: Color(0xFFEEDDBB),
    8: Colors.white,
    16: Colors.white,
    32: Colors.white,
    64: Colors.white,
    128: Colors.white,
    256: Colors.white,
    512: Colors.white,
    1024: Colors.white,
    2048: Color(0xFF0A0A0F),
  };

  @override
  Widget build(BuildContext context) {
    final color = _tileColors[value] ?? const Color(0xFFFFD700);
    final textColor = _textColors[value] ?? Colors.white;
    final fontSize = value >= 1000 ? 18.0 : value >= 100 ? 22.0 : 26.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: value >= 128
            ? [
                BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 1)
              ]
            : null,
      ),
      child: Center(
        child: value > 0
            ? Text(
                '$value',
                style: TextStyle(
                  color: textColor,
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ).animate(key: ValueKey(value)).scale(
                  duration: 200.ms,
                  curve: Curves.elasticOut,
                  begin: const Offset(0.7, 0.7))
            : null,
      ),
    );
  }
}
