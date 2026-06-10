import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../coins_system/coins_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_constants.dart';
import '../../widgets/game_app_bar.dart';
import '../../widgets/gold_button.dart';
import '../../ads/banner_ad_widget.dart';

class TicTacToeScreen extends StatefulWidget {
  const TicTacToeScreen({super.key});

  @override
  State<TicTacToeScreen> createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen> {
  List<String> _board = List.filled(9, '');
  bool _xTurn = true;
  String _status = '';
  bool _gameOver = false;
  int _xWins = 0;
  int _oWins = 0;
  int _draws = 0;
  List<int> _winLine = [];

  static const List<List<int>> _winCombos = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8],
    [0, 3, 6], [1, 4, 7], [2, 5, 8],
    [0, 4, 8], [2, 4, 6],
  ];

  @override
  void initState() {
    super.initState();
    _status = "Player X's Turn";
  }

  void _onTap(int index) {
    if (_gameOver || _board[index].isNotEmpty) return;
    setState(() {
      _board[index] = _xTurn ? 'X' : 'O';
      _xTurn = !_xTurn;
      _checkResult();
    });
  }

  void _checkResult() {
    for (final combo in _winCombos) {
      final a = combo[0], b = combo[1], c = combo[2];
      if (_board[a].isNotEmpty &&
          _board[a] == _board[b] &&
          _board[b] == _board[c]) {
        _winLine = combo;
        _gameOver = true;
        final winner = _board[a];
        _status = '$winner Wins! 🎉';
        if (winner == 'X') {
          _xWins++;
          _onWin();
        } else {
          _oWins++;
        }
        return;
      }
    }
    if (!_board.contains('')) {
      _draws++;
      _gameOver = true;
      _status = "It's a Draw! 🤝";
      context.read<CoinsProvider>().recordGame();
    } else {
      _status = "${_xTurn ? 'X' : 'O'}'s Turn";
    }
  }

  void _onWin() {
    final coins = context.read<CoinsProvider>();
    coins.addCoins(AppConstants.tictactoeWinCoins);
    coins.recordWin();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _showResultDialog('X WINS! 🏆', AppConstants.tictactoeWinCoins);
    });
  }

  void _showResultDialog(String title, int earned) {
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
              Text(earned > 0 ? '🏆' : '🤝',
                  style: const TextStyle(fontSize: 60)),
              const SizedBox(height: 12),
              Text(title,
                  style: const TextStyle(
                      color: AppTheme.goldPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2)),
              if (earned > 0) ...[
                const SizedBox(height: 8),
                Text('+$earned 🪙',
                    style: const TextStyle(
                        color: AppTheme.goldLight,
                        fontSize: 26,
                        fontWeight: FontWeight.bold)),
              ],
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GoldButton(
                      label: 'PLAY AGAIN',
                      onTap: () {
                        Navigator.pop(context);
                        _resetBoard();
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

  void _resetBoard() {
    setState(() {
      _board = List.filled(9, '');
      _xTurn = true;
      _gameOver = false;
      _winLine = [];
      _status = "Player X's Turn";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GameAppBar(title: 'TIC TAC TOE'),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: Column(
          children: [
            // Score Board
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ScoreBadge(label: 'X', value: _xWins,
                      color: AppTheme.tttBlue),
                  _ScoreBadge(label: 'DRAW', value: _draws,
                      color: AppTheme.textGrey),
                  _ScoreBadge(label: 'O', value: _oWins,
                      color: AppTheme.memoryPurple),
                ],
              ),
            ),

            // Status
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _status,
                key: ValueKey(_status),
                style: TextStyle(
                  color: _gameOver ? AppTheme.goldPrimary : AppTheme.textWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Board
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: AspectRatio(
                aspectRatio: 1,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: 9,
                  itemBuilder: (_, i) => _buildCell(i),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Reset Button
            GoldButton(label: 'NEW GAME', onTap: _resetBoard),

            const Spacer(),
            const BannerAdWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildCell(int index) {
    final value = _board[index];
    final isWinCell = _winLine.contains(index);

    return GestureDetector(
      onTap: () => _onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: isWinCell
              ? const LinearGradient(
                  colors: [Color(0xFF2A2200), Color(0xFF1A1500)])
              : AppTheme.cardGradient,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isWinCell
                ? AppTheme.goldPrimary
                : AppTheme.cardBorder,
            width: isWinCell ? 2 : 1,
          ),
          boxShadow: isWinCell
              ? [BoxShadow(
                  color: AppTheme.glowGold, blurRadius: 12, spreadRadius: 1)]
              : null,
        ),
        child: Center(
          child: value.isEmpty
              ? null
              : Text(
                  value,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: value == 'X'
                        ? AppTheme.tttBlue
                        : AppTheme.memoryPurple,
                    shadows: [
                      Shadow(
                          color: (value == 'X'
                                  ? AppTheme.tttBlue
                                  : AppTheme.memoryPurple)
                              .withOpacity(0.5),
                          blurRadius: 12),
                    ],
                  ),
                )
                    .animate()
                    .scale(
                        duration: 250.ms,
                        curve: Curves.elasticOut,
                        begin: const Offset(0.3, 0.3))
                    .fadeIn(duration: 150.ms),
        ),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _ScoreBadge(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(label,
              style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2)),
          const SizedBox(height: 4),
          Text('$value',
              style: TextStyle(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
