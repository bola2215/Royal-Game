import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/app_theme.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 700),
        ));
      }
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFF0A0805),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // ── Dark background gradient ──────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.3),
                radius: 1.2,
                colors: [Color(0xFF1A1200), Color(0xFF0A0805), Color(0xFF050403)],
              ),
            ),
          ),

          // ── Light beam from top (like the design) ────────────
          Positioned(
            top: 0,
            child: AnimatedBuilder(
              animation: _glowController,
              builder: (_, __) => Opacity(
                opacity: 0.5 + _glowController.value * 0.3,
                child: Container(
                  width: size.width * 0.35,
                  height: size.height * 0.55,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFFFFD700).withOpacity(0.35),
                        const Color(0xFFFFAA00).withOpacity(0.15),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Secondary beam (slightly offset) ─────────────────
          Positioned(
            top: 0,
            child: AnimatedBuilder(
              animation: _glowController,
              builder: (_, __) => Opacity(
                opacity: 0.3 + _glowController.value * 0.2,
                child: Container(
                  width: size.width * 0.15,
                  height: size.height * 0.4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.25),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Floating sparkles ─────────────────────────────────
          ..._buildSparkles(size),

          // ── Ornate circle behind logo ─────────────────────────
          AnimatedBuilder(
            animation: _glowController,
            builder: (_, child) => Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.goldDark.withOpacity(0.25 + _glowController.value * 0.15),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.goldPrimary.withOpacity(0.08 + _glowController.value * 0.08),
                    blurRadius: 60,
                    spreadRadius: 20,
                  ),
                ],
              ),
              child: child,
            ),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0xFF1A1400), Color(0xFF0A0805)],
                ),
              ),
            ),
          ).animate().scale(
              begin: const Offset(0.6, 0.6),
              duration: 900.ms,
              curve: Curves.easeOut),

          // ── Decorative outer ring ─────────────────────────────
          AnimatedBuilder(
            animation: _glowController,
            builder: (_, __) => Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.goldDark.withOpacity(0.12 + _glowController.value * 0.08),
                  width: 0.5,
                ),
              ),
            ),
          ).animate(delay: 200.ms).fadeIn(duration: 800.ms),

          // ── Main content: Crown + Text ─────────────────────────
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Crown icon with glow
              AnimatedBuilder(
                animation: _glowController,
                builder: (_, child) => Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.goldPrimary.withOpacity(
                            0.25 + _glowController.value * 0.35),
                        blurRadius: 50 + _glowController.value * 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: child,
                ),
                child: const Text('♛',
                    style: TextStyle(
                      fontSize: 72,
                      color: AppTheme.goldPrimary,
                      shadows: [
                        Shadow(color: AppTheme.glowGold, blurRadius: 20),
                      ],
                    )),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.2, 0.2),
                    duration: 1000.ms,
                    curve: Curves.elasticOut,
                  )
                  .fadeIn(duration: 500.ms),

              const SizedBox(height: 12),

              // ROYAL — large ornate text
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppTheme.goldGradient.createShader(bounds),
                child: const Text(
                  'ROYAL',
                  style: TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 10,
                    height: 1.0,
                    shadows: [
                      Shadow(color: Color(0x80FFD700), blurRadius: 20),
                    ],
                  ),
                ),
              )
                  .animate(delay: 300.ms)
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: 0.3, end: 0),

              // Decorative divider line
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 30, height: 1, color: AppTheme.goldDark.withOpacity(0.6)),
                    const SizedBox(width: 6),
                    const Text('✦',
                        style: TextStyle(color: AppTheme.goldDark, fontSize: 10)),
                    const SizedBox(width: 6),
                    Container(width: 30, height: 1, color: AppTheme.goldDark.withOpacity(0.6)),
                  ],
                ),
              ).animate(delay: 500.ms).fadeIn(duration: 400.ms),

              // GAME text
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppTheme.goldGradient.createShader(bounds),
                child: const Text(
                  'GAME',
                  style: TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 14,
                    height: 1.0,
                  ),
                ),
              )
                  .animate(delay: 400.ms)
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: -0.3, end: 0),

              const SizedBox(height: 80),

              // Loading dots
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) =>
                  Container(
                    width: 6, height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: const BoxDecoration(
                      color: AppTheme.goldDark,
                      shape: BoxShape.circle,
                    ),
                  )
                  .animate(delay: Duration(milliseconds: 800 + i * 150))
                  .fadeIn(duration: 400.ms)
                  .then()
                  .shimmer(color: AppTheme.goldPrimary, duration: 1200.ms)
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSparkles(Size size) {
    final positions = [
      [0.15, 0.2], [0.85, 0.15], [0.1, 0.6], [0.9, 0.55],
      [0.3, 0.12], [0.7, 0.18], [0.05, 0.4], [0.95, 0.38],
      [0.2, 0.75], [0.8, 0.7],
    ];
    return positions.asMap().entries.map((e) {
      final i = e.key;
      final pos = e.value;
      return Positioned(
        left: size.width * pos[0],
        top: size.height * pos[1],
        child: Text('✦',
            style: TextStyle(
              color: AppTheme.goldPrimary.withOpacity(0.4),
              fontSize: i % 3 == 0 ? 10 : 6,
            ))
            .animate(delay: Duration(milliseconds: 600 + i * 100))
            .fadeIn(duration: 500.ms)
            .then()
            .shimmer(duration: 2000.ms, color: AppTheme.goldLight),
      );
    }).toList();
  }
}
