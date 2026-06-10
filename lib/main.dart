import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'coins_system/coins_provider.dart';
import 'ads/ad_manager.dart';
import 'home/splash_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize AdMob
  await MobileAds.instance.initialize();

  // Set immersive mode
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppTheme.bgBlack,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(const RoyalGameApp());
}

class RoyalGameApp extends StatelessWidget {
  const RoyalGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CoinsProvider()),
        ChangeNotifierProvider(create: (_) => AdManager()),
      ],
      child: MaterialApp(
        title: 'Royal Game',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
