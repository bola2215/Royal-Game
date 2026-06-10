class AppConstants {
  // App Info
  static const String appName = 'Royal Game';
  static const String appVersion = '1.0.0';

  // Ad Unit IDs (Production)
  static const String bannerAdId = 'ca-app-pub-5058824160138099/9172293682';
  static const String interstitialAdId = 'ca-app-pub-5058824160138099/3992119193';
  static const String rewardedAdId = 'ca-app-pub-5058824160138099/6225183256';

  // Test Ad Unit IDs (use during development)
  static const String testBannerAdId = 'ca-app-pub-3940256099942544/6300978111';
  static const String testInterstitialAdId = 'ca-app-pub-3940256099942544/1033173712';
  static const String testRewardedAdId = 'ca-app-pub-3940256099942544/5224354917';

  // Set to false for production
  static const bool useTestAds = false;

  static String get activeBannerAdId => useTestAds ? testBannerAdId : bannerAdId;
  static String get activeInterstitialAdId =>
      useTestAds ? testInterstitialAdId : interstitialAdId;
  static String get activeRewardedAdId => useTestAds ? testRewardedAdId : rewardedAdId;

  // Coins
  static const int startingCoins = 100;
  static const int dailyBonusCoins = 50;
  static const int rewardedAdCoins = 30;
  static const int memoryWinCoins = 20;
  static const int tictactoeWinCoins = 15;
  static const int snakePerFoodCoins = 2;
  static const int game2048TileCoins = 5;

  // SharedPreferences Keys
  static const String keyCoins = 'royal_coins';
  static const String keyLastDailyBonus = 'last_daily_bonus';
  static const String keyHighScoreSnake = 'high_score_snake';
  static const String keyHighScore2048 = 'high_score_2048';
  static const String keyHighScoreMemory = 'high_score_memory';
  static const String keyTotalWins = 'total_wins';
  static const String keyGamesPlayed = 'games_played';

  // Daily Bonus Duration
  static const Duration dailyBonusDuration = Duration(hours: 24);
}
