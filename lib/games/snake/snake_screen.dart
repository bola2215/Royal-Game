import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../coins_system/coins_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_constants.dart';
import '../../widgets/game_app_bar.dart';
import '../../widgets/gold_button.dart';
import '../../ads/banner_ad_widget.dart';

enum Direction { up, down, left, right }

class SnakeScreen extends StatefulWidget {
  const SnakeScreen({super.key});

  @override
  State<SnakeScreen> createState() => _SnakeScreenState();
}

class _SnakeScreenState extends State<SnakeScreen> {
  static const int _cols = 20;
  static const int _rows = 24;
  static const Duration _speed = Duration(milliseconds: 130);

  List<Offset> _snake = [];
  Offset _food = Offset.zero;
  Direction _dir = Direction.right;
  Direction _nextDir = Direction.right;
  Timer? _timer;
  bool _running = false;
  bool _gameOver = false;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _initGame() {
    _snake = [
      const Offset(5, 10),
      const Offset(4, 10),
      const Offset(3, 10),
    ];
    _dir = Direction.right;
    _nextDir = Direction.right;
    _score = 0;
    _gameOver = false;
    _placeFood();
  }

  void _placeFood() {
    final rng = Random();
    Offset candidate;
    do {
      candidate = Offset(
        rng.nextInt(_cols).toDouble(),
        rng.nextInt(_rows).toDouble(),
      );
    } while (_snake.contains(candidate));
    _food = candidate;
  }

  void _startGame() {
    _timer?.cancel();
    _running = true;
    _timer = Timer.periodic(_speed, (_) => _tick());
    setState(() {});
  }

  void _pauseGame() {
    _timer?.cancel();
    setState(() => _running = false);
  }

  void _tick() {
    if (!mounted) return;
    setState(() {
      _dir = _nextDir;
      final head = _snake.first;
      Offset newHead;
      switch (_dir) {
        case Direction.up:
          newHead = Offset(head.dx, head.dy - 1);
          break;
        case Direction.down:
          newHead = Offset(head.dx, head.dy + 1);
          break;
        case Direction.left:
          newHead = Offset(head.dx - 1, head.dy);
          break;
        case Direction.right:
          newHead = Offset(head.dx + 1, head.dy);
          break;
      }

      // Wall collision
      if (newHead.dx < 0 ||
          newHead.dx >= _cols ||
          newHead.dy < 0 ||
          newHead.dy >= _rows) {
        _endGame();
        return;
      }

      // Self collision
      if (_snake.contains(newHead)) {
        _endGame();
        return;
      }

      _snake.insert(0, newHead);

      if (newHead == _food) {
        _score++;
        _placeFood();
        // Award coins
        context.read<CoinsProvider>().addCoins(AppConstants.snakePerFoodCoins);
      } else {
        _snake.removeLast();
      }
    });
  }

  void _endGame() {
    _timer?.cancel();
    _running = false;
    _gameOver = true;
    final coins = context.read<CoinsProvider>();
    coins.updateHighScoreSnake(_score);
    coins.recordGame();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _showGameOverDialog();
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
              const Text('💀', style: TextStyle(fontSize: 60)),
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
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                  'Best: ${context.read<CoinsProvider>().highScoreSnake}',
                  style: const TextStyle(
                      color: AppTheme.goldDark, fontSize: 14)),
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

  void _changeDir(Direction d) {
    // Prevent 180-degree turns
    if (d == Direction.up && _dir == Direction.down) return;
    if (d == Direction.down && _dir == Direction.up) return;
    if (d == Direction.left && _dir == Direction.right) return;
    if (d == Direction.right && _dir == Direction.left) return;
    _nextDir = d;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GameAppBar(
        title: 'SNAKE',
        scoreWidget: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Text('🍎 $_score',
              style: const TextStyle(
                  color: AppTheme.snakeGreen,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: Column(
          children: [
            // Game Board
            Expanded(
              child: GestureDetector(
                onVerticalDragUpdate: (d) {
                  if (d.delta.dy < -5) _changeDir(Direction.up);
                  if (d.delta.dy > 5) _changeDir(Direction.down);
                },
                onHorizontalDragUpdate: (d) {
                  if (d.delta.dx < -5) _changeDir(Direction.left);
                  if (d.delta.dx > 5) _changeDir(Direction.right);
                },
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D0D14),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppTheme.snakeGreen.withOpacity(0.2)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CustomPaint(
                        painter: _SnakePainter(
                          snake: _snake,
                          food: _food,
                          cols: _cols,
                          rows: _rows,
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                children: [
                  // Up
                  _DirButton(
                      icon: Icons.keyboard_arrow_up,
                      onTap: () => _changeDir(Direction.up)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _DirButton(
                          icon: Icons.keyboard_arrow_left,
                          onTap: () => _changeDir(Direction.left)),
                      const SizedBox(width: 8),
                      // Play/Pause center button
                      GestureDetector(
                        onTap: _running ? _pauseGame : _startGame,
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: AppTheme.goldGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: AppTheme.glowGold, blurRadius: 12)
                            ],
                          ),
                          child: Icon(
                            _running ? Icons.pause : Icons.play_arrow,
                            color: AppTheme.bgBlack,
                            size: 30,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _DirButton(
                          icon: Icons.keyboard_arrow_right,
                          onTap: () => _changeDir(Direction.right)),
                    ],
                  ),
                  _DirButton(
                      icon: Icons.keyboard_arrow_down,
                      onTap: () => _changeDir(Direction.down)),
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

class _DirButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _DirButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.snakeGreen.withOpacity(0.3)),
        ),
        child: Icon(icon, color: AppTheme.snakeGreen, size: 28),
      ),
    );
  }
}

class _SnakePainter extends CustomPainter {
  final List<Offset> snake;
  final Offset food;
  final int cols;
  final int rows;

  const _SnakePainter({
    required this.snake,
    required this.food,
    required this.cols,
    required this.rows,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / cols;
    final cellH = size.height / rows;

    // Grid lines (subtle)
    final gridPaint = Paint()
      ..color = const Color(0xFF1A1A22)
      ..strokeWidth = 0.5;
    for (int i = 0; i <= cols; i++) {
      canvas.drawLine(
          Offset(i * cellW, 0), Offset(i * cellW, size.height), gridPaint);
    }
    for (int j = 0; j <= rows; j++) {
      canvas.drawLine(
          Offset(0, j * cellH), Offset(size.width, j * cellH), gridPaint);
    }

    // Food
    final foodPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    final foodGlow = Paint()
      ..color = Colors.red.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    final foodRect = Rect.fromLTWH(
        food.dx * cellW + 1, food.dy * cellH + 1, cellW - 2, cellH - 2);
    canvas.drawRRect(
        RRect.fromRectAndRadius(foodRect.inflate(3), const Radius.circular(6)),
        foodGlow);
    canvas.drawRRect(
        RRect.fromRectAndRadius(foodRect, const Radius.circular(4)), foodPaint);

    // Snake body
    for (int i = snake.length - 1; i >= 0; i--) {
      final s = snake[i];
      final t = 1.0 - (i / snake.length);
      final color = Color.lerp(
          AppTheme.snakeGreen.withOpacity(0.5), AppTheme.snakeGreen, t)!;
      final snakePaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      final rect = Rect.fromLTWH(
          s.dx * cellW + 1, s.dy * cellH + 1, cellW - 2, cellH - 2);
      canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(3)), snakePaint);
    }

    // Snake head (brighter + glow)
    if (snake.isNotEmpty) {
      final head = snake.first;
      final headGlow = Paint()
        ..color = AppTheme.snakeGreen.withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      final headPaint = Paint()
        ..color = AppTheme.snakeGreen
        ..style = PaintingStyle.fill;
      final headRect = Rect.fromLTWH(
          head.dx * cellW, head.dy * cellH, cellW, cellH);
      canvas.drawRRect(
          RRect.fromRectAndRadius(headRect, const Radius.circular(4)),
          headGlow);
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              headRect.deflate(1), const Radius.circular(4)),
          headPaint);
    }
  }

  @override
  bool shouldRepaint(_SnakePainter old) =>
      old.snake != snake || old.food != food;
}
