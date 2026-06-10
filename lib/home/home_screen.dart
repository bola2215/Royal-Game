import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../coins_system/coins_provider.dart';
import '../ads/ad_manager.dart';
import '../ads/banner_ad_widget.dart';
import '../utils/app_theme.dart';
import '../utils/app_constants.dart';
import '../widgets/gold_button.dart';
import '../games/memory/memory_game_screen.dart';
import '../games/tictactoe/tictactoe_screen.dart';
import '../games/snake/snake_screen.dart';
import '../games/game2048/game2048_screen.dart';
import 'leaderboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedTab = 0;
  late AnimationController _glowController;

  final List<_GameCardData> _games = [
    _GameCardData(title: 'Memory Cards', emoji: '🃏',
        color: const Color(0xFF9B59B6), screen: const MemoryGameScreen()),
    _GameCardData(title: 'Tic Tac Toe', emoji: '❌',
        color: const Color(0xFF3498DB), screen: const TicTacToeScreen()),
    _GameCardData(title: 'Snake', emoji: '🐍',
        color: const Color(0xFF2ECC71), screen: const SnakeScreen()),
    _GameCardData(title: '2048', emoji: '🔢',
        color: const Color(0xFFE67E22), screen: const Game2048Screen()),
  ];

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _navigateToGame(Widget screen) async {
    final adManager = context.read<AdManager>();
    if (adManager.isInterstitialReady) await adManager.showInterstitialAd();
    if (!mounted) return;
    Navigator.push(context, PageRouteBuilder(
      pageBuilder: (_, __, ___) => screen,
      transitionsBuilder: (_, anim, __, child) =>
          FadeTransition(opacity: anim, child: child),
      transitionDuration: const Duration(milliseconds: 400),
    ));
  }

  void _showRewardedAdDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => _RewardedAdDialog(
        onWatch: () async {
          Navigator.pop(context);
          final adManager = context.read<AdManager>();
          final coins = context.read<CoinsProvider>();
          if (!adManager.isRewardedReady) {
            _showSnack('Ad not ready, try again later', isError: true);
            return;
          }
          await adManager.showRewardedAd(onRewarded: (earned) async {
            await coins.addCoins(earned);
            if (mounted) _showSnack('+$earned coins earned! 🪙');
          });
        },
      ),
    );
  }

  void _showDailyBonus() async {
    final coins = context.read<CoinsProvider>();
    if (!coins.canClaimDailyBonus) {
      final r = coins.timeUntilNextBonus;
      _showSnack('⏰ Next bonus in ${r.inHours}h ${r.inMinutes % 60}m', isError: true);
      return;
    }
    final earned = await coins.claimDailyBonus();
    if (mounted) _showBonusDialog(earned);
  }

  void _showBonusDialog(int earned) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: _OrnateDialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎁', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 12),
              const Text('DAILY BONUS!',
                  style: TextStyle(color: AppTheme.goldPrimary,
                      fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 3)),
              const SizedBox(height: 8),
              Text('+$earned 🪙',
                  style: const TextStyle(color: AppTheme.goldLight,
                      fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              GoldButton(label: 'CLAIM', onTap: () => Navigator.pop(context)),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white, fontFamily: 'RoyalFont')),
      backgroundColor: isError ? Colors.red.shade800 : AppTheme.goldDark,
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080604),
      body: Stack(
        children: [
          // Background radial glow
          AnimatedBuilder(
            animation: _glowController,
            builder: (_, __) => Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.6),
                  radius: 0.8,
                  colors: [
                    AppTheme.goldDark.withOpacity(0.06 + _glowController.value * 0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                _buildCoinsBar(),
                Expanded(child: _buildBody()),
                _buildWatchAdButton(),
                const BannerAdWidget(),
                _buildBottomNav(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Top Bar ───────────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: _OrnateContainer(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Crown + Title
              Row(
                children: [
                  const Text('♛',
                      style: TextStyle(color: AppTheme.goldPrimary, fontSize: 22,
                          shadows: [Shadow(color: AppTheme.glowGold, blurRadius: 10)])),
                  const SizedBox(width: 8),
                  ShaderMask(
                    shaderCallback: (b) => AppTheme.goldGradient.createShader(b),
                    child: const Text('ROYAL GAME',
                        style: TextStyle(color: Colors.white, fontSize: 20,
                            fontWeight: FontWeight.bold, letterSpacing: 3)),
                  ),
                ],
              ),
              // Coins + leaderboard
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const LeaderboardScreen())),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.goldPrimary.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.goldDark.withOpacity(0.4)),
                      ),
                      child: const Text('🏆', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildCoinsBadge(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoinsBadge() {
    final coins = context.watch<CoinsProvider>().coins;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1200),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.goldDark.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: AppTheme.glowGold.withOpacity(0.2), blurRadius: 8)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16, height: 16,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [AppTheme.goldLight, AppTheme.goldPrimary, AppTheme.goldDark],
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text('$coins',
              style: const TextStyle(color: AppTheme.goldPrimary,
                  fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ── Sub-coins bar ─────────────────────────────────────────────────────────
  Widget _buildCoinsBar() {
    final coins = context.watch<CoinsProvider>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Coin count with + button
          Row(
            children: [
              Container(
                width: 20, height: 20,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [AppTheme.goldLight, AppTheme.goldPrimary, AppTheme.goldDark],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text('${coins.coins}',
                  style: const TextStyle(color: AppTheme.goldPrimary,
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: _showRewardedAdDialog,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.goldPrimary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.goldDark.withOpacity(0.5)),
                  ),
                  child: const Text('+',
                      style: TextStyle(color: AppTheme.goldPrimary,
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          // Daily bonus
          GestureDetector(
            onTap: _showDailyBonus,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: coins.canClaimDailyBonus
                    ? AppTheme.goldPrimary.withOpacity(0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: coins.canClaimDailyBonus
                      ? AppTheme.goldDark
                      : AppTheme.cardBorder,
                ),
              ),
              child: Text(
                coins.canClaimDailyBonus ? '🎁 Daily Bonus' : '⏳ Daily Bonus',
                style: TextStyle(
                  color: coins.canClaimDailyBonus
                      ? AppTheme.goldPrimary
                      : AppTheme.textGrey,
                  fontSize: 12, fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Body (Home tab or Coins tab) ──────────────────────────────────────────
  Widget _buildBody() {
    if (_selectedTab == 1) return _buildCoinsTab();
    return _buildHomeTab();
  }

  Widget _buildHomeTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.88,
        ),
        itemCount: _games.length,
        itemBuilder: (_, i) => _GameCard(
          data: _games[i],
          onTap: () => _navigateToGame(_games[i].screen),
        )
            .animate(delay: Duration(milliseconds: 80 * i))
            .fadeIn(duration: 400.ms)
            .scale(begin: const Offset(0.85, 0.85), duration: 400.ms,
                curve: Curves.easeOut),
      ),
    );
  }

  Widget _buildCoinsTab() {
    final coins = context.watch<CoinsProvider>();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _OrnateContainer(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text('YOUR COINS',
                      style: TextStyle(color: AppTheme.goldDark,
                          fontSize: 12, letterSpacing: 3)),
                  const SizedBox(height: 8),
                  Text('${coins.coins}',
                      style: const TextStyle(color: AppTheme.goldPrimary,
                          fontSize: 52, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  GoldButton(
                    label: '▶  Watch Ad  +${AppConstants.rewardedAdCoins}',
                    onTap: _showRewardedAdDialog,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _OrnateContainer(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _CoinRow(icon: '🏆', label: 'Total Wins', value: '${coins.totalWins}'),
                  _CoinRow(icon: '🎮', label: 'Games Played', value: '${coins.gamesPlayed}'),
                  _CoinRow(icon: '🐍', label: 'Snake High Score', value: '${coins.highScoreSnake}'),
                  _CoinRow(icon: '🔢', label: '2048 High Score', value: '${coins.highScore2048}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Watch Ad button (bottom strip) ───────────────────────────────────────
  Widget _buildWatchAdButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: GestureDetector(
        onTap: _showRewardedAdDialog,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A1200), Color(0xFF2A1E00), Color(0xFF1A1200)],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppTheme.goldDark.withOpacity(0.7), width: 1.5),
            boxShadow: [
              BoxShadow(color: AppTheme.goldPrimary.withOpacity(0.15),
                  blurRadius: 12, spreadRadius: 1),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.goldPrimary,
                ),
                child: const Icon(Icons.play_arrow, color: Color(0xFF0A0805), size: 14),
              ),
              const SizedBox(width: 10),
              const Text('Watch Ad',
                  style: TextStyle(color: AppTheme.goldPrimary,
                      fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1)),
              const SizedBox(width: 6),
              ShaderMask(
                shaderCallback: (b) => AppTheme.goldGradient.createShader(b),
                child: const Text('+10',
                    style: TextStyle(color: Colors.white,
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Bottom Navigation ─────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D0A06),
        border: Border(top: BorderSide(color: AppTheme.goldDark.withOpacity(0.3), width: 1)),
      ),
      child: Row(
        children: [
          _NavItem(icon: '⌂', label: 'Home', selected: _selectedTab == 0,
              onTap: () => setState(() => _selectedTab = 0)),
          _NavItem(icon: '🪙', label: 'Coins', selected: _selectedTab == 1,
              onTap: () => setState(() => _selectedTab = 1)),
        ],
      ),
    );
  }
}

// ── Ornate Container (golden border frame) ────────────────────────────────
class _OrnateContainer extends StatelessWidget {
  final Widget child;
  const _OrnateContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF151005), Color(0xFF0D0A04)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.goldDark.withOpacity(0.55), width: 1.5),
        boxShadow: [
          BoxShadow(color: AppTheme.goldPrimary.withOpacity(0.06),
              blurRadius: 16, spreadRadius: 1),
        ],
      ),
      child: child,
    );
  }
}

// ── Ornate Dialog wrapper ─────────────────────────────────────────────────
class _OrnateDialog extends StatelessWidget {
  final Widget child;
  const _OrnateDialog({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1400), Color(0xFF0D0A04)],
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.goldPrimary, width: 1.5),
        boxShadow: [
          BoxShadow(color: AppTheme.glowGold, blurRadius: 40, spreadRadius: 4),
          BoxShadow(color: AppTheme.goldDark.withOpacity(0.3), blurRadius: 80),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Corner ornaments
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('✦', style: TextStyle(color: AppTheme.goldDark, fontSize: 10)),
              const Text('✦', style: TextStyle(color: AppTheme.goldDark, fontSize: 10)),
            ],
          ),
          child,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('✦', style: TextStyle(color: AppTheme.goldDark, fontSize: 10)),
              const Text('✦', style: TextStyle(color: AppTheme.goldDark, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Rewarded Ad Dialog ────────────────────────────────────────────────────
class _RewardedAdDialog extends StatelessWidget {
  final VoidCallback onWatch;
  const _RewardedAdDialog({required this.onWatch});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: _OrnateDialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Watch a short video ad to earn coins!',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textWhite, fontSize: 14)),
            const SizedBox(height: 20),
            // Gold coin circle
            Container(
              width: 80, height: 80,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppTheme.goldLight, AppTheme.goldPrimary, AppTheme.goldDark],
                ),
                boxShadow: [BoxShadow(color: AppTheme.glowGold, blurRadius: 20, spreadRadius: 2)],
              ),
              child: const Center(
                child: Text('10',
                    style: TextStyle(color: Color(0xFF3A2800),
                        fontSize: 28, fontWeight: FontWeight.bold)),
              ),
            )
                .animate()
                .scale(duration: 500.ms, curve: Curves.elasticOut),
            const SizedBox(height: 8),
            const Text('COINS',
                style: TextStyle(color: AppTheme.goldPrimary,
                    fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 4)),
            const SizedBox(height: 20),
            GoldButton(label: 'WATCH AD', onTap: onWatch, width: double.infinity),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Maybe later',
                  style: TextStyle(color: AppTheme.textGrey, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Game Card ─────────────────────────────────────────────────────────────
class _GameCardData {
  final String title;
  final String emoji;
  final Color color;
  final Widget screen;
  const _GameCardData({required this.title, required this.emoji,
      required this.color, required this.screen});
}

class _GameCard extends StatefulWidget {
  final _GameCardData data;
  final VoidCallback onTap;
  const _GameCard({required this.data, required this.onTap});
  @override
  State<_GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<_GameCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.lerp(const Color(0xFF151005), widget.data.color, 0.12)!,
                const Color(0xFF0D0A04),
              ],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.goldDark.withOpacity(0.55), width: 1.5),
            boxShadow: [
              BoxShadow(color: widget.data.color.withOpacity(0.12),
                  blurRadius: 12, spreadRadius: 1),
              BoxShadow(color: AppTheme.goldPrimary.withOpacity(0.04),
                  blurRadius: 20),
            ],
          ),
          child: Stack(
            children: [
              // Corner crown ornament
              const Positioned(
                top: 8, right: 8,
                child: Text('♛',
                    style: TextStyle(color: AppTheme.goldDark,
                        fontSize: 10, shadows: [Shadow(color: AppTheme.glowGold, blurRadius: 6)])),
              ),

              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Game emoji in ornate box
                    Container(
                      width: 60, height: 60,
                      decoration: BoxDecoration(
                        color: widget.data.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: widget.data.color.withOpacity(0.35), width: 1.5),
                        boxShadow: [BoxShadow(
                            color: widget.data.color.withOpacity(0.2), blurRadius: 10)],
                      ),
                      child: Center(
                          child: Text(widget.data.emoji,
                              style: const TextStyle(fontSize: 30))),
                    ),
                    const Spacer(),

                    // Title
                    Text(widget.data.title,
                        style: const TextStyle(color: AppTheme.textWhite,
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),

                    // Play button
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: AppTheme.goldGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(
                            color: AppTheme.goldPrimary.withOpacity(0.3), blurRadius: 8)],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_arrow, color: Color(0xFF0A0805), size: 14),
                          SizedBox(width: 4),
                          Text('PLAY',
                              style: TextStyle(color: Color(0xFF0A0805),
                                  fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Bottom Nav Item ───────────────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final String icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _NavItem({required this.icon, required this.label,
      required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(icon,
                  style: TextStyle(
                    fontSize: selected ? 22 : 18,
                    shadows: selected ? [const Shadow(
                        color: AppTheme.glowGold, blurRadius: 10)] : null,
                  )),
              const SizedBox(height: 3),
              Text(label,
                  style: TextStyle(
                    color: selected ? AppTheme.goldPrimary : AppTheme.textGrey,
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    letterSpacing: 1,
                  )),
              if (selected)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: 20, height: 2,
                  decoration: BoxDecoration(
                    color: AppTheme.goldPrimary,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [BoxShadow(
                        color: AppTheme.glowGold, blurRadius: 6)],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoinRow extends StatelessWidget {
  final String icon, label, value;
  const _CoinRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(child: Text(label,
              style: const TextStyle(color: AppTheme.textGrey, fontSize: 14))),
          Text(value, style: const TextStyle(color: AppTheme.goldPrimary,
              fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
