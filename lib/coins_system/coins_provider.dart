import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_constants.dart';

class CoinsProvider extends ChangeNotifier {
  int _coins = 0;
  DateTime? _lastDailyBonus;
  int _highScoreSnake = 0;
  int _highScore2048 = 0;
  int _highScoreMemory = 0;
  int _totalWins = 0;
  int _gamesPlayed = 0;

  int get coins => _coins;
  DateTime? get lastDailyBonus => _lastDailyBonus;
  int get highScoreSnake => _highScoreSnake;
  int get highScore2048 => _highScore2048;
  int get highScoreMemory => _highScoreMemory;
  int get totalWins => _totalWins;
  int get gamesPlayed => _gamesPlayed;

  bool get canClaimDailyBonus {
    if (_lastDailyBonus == null) return true;
    return DateTime.now().difference(_lastDailyBonus!) >=
        AppConstants.dailyBonusDuration;
  }

  Duration get timeUntilNextBonus {
    if (_lastDailyBonus == null) return Duration.zero;
    final next = _lastDailyBonus!.add(AppConstants.dailyBonusDuration);
    final remaining = next.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  CoinsProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _coins = prefs.getInt(AppConstants.keyCoins) ?? AppConstants.startingCoins;
    _highScoreSnake = prefs.getInt(AppConstants.keyHighScoreSnake) ?? 0;
    _highScore2048 = prefs.getInt(AppConstants.keyHighScore2048) ?? 0;
    _highScoreMemory = prefs.getInt(AppConstants.keyHighScoreMemory) ?? 0;
    _totalWins = prefs.getInt(AppConstants.keyTotalWins) ?? 0;
    _gamesPlayed = prefs.getInt(AppConstants.keyGamesPlayed) ?? 0;

    final lastBonusStr = prefs.getString(AppConstants.keyLastDailyBonus);
    if (lastBonusStr != null) {
      _lastDailyBonus = DateTime.tryParse(lastBonusStr);
    }
    notifyListeners();
  }

  Future<void> _saveCoins() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.keyCoins, _coins);
  }

  Future<void> addCoins(int amount) async {
    _coins += amount;
    await _saveCoins();
    notifyListeners();
  }

  Future<bool> spendCoins(int amount) async {
    if (_coins < amount) return false;
    _coins -= amount;
    await _saveCoins();
    notifyListeners();
    return true;
  }

  Future<int> claimDailyBonus() async {
    if (!canClaimDailyBonus) return 0;
    _lastDailyBonus = DateTime.now();
    _coins += AppConstants.dailyBonusCoins;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.keyCoins, _coins);
    await prefs.setString(
        AppConstants.keyLastDailyBonus, _lastDailyBonus!.toIso8601String());
    notifyListeners();
    return AppConstants.dailyBonusCoins;
  }

  Future<void> recordWin() async {
    _totalWins++;
    _gamesPlayed++;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.keyTotalWins, _totalWins);
    await prefs.setInt(AppConstants.keyGamesPlayed, _gamesPlayed);
    notifyListeners();
  }

  Future<void> recordGame() async {
    _gamesPlayed++;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.keyGamesPlayed, _gamesPlayed);
    notifyListeners();
  }

  Future<void> updateHighScoreSnake(int score) async {
    if (score > _highScoreSnake) {
      _highScoreSnake = score;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(AppConstants.keyHighScoreSnake, _highScoreSnake);
      notifyListeners();
    }
  }

  Future<void> updateHighScore2048(int score) async {
    if (score > _highScore2048) {
      _highScore2048 = score;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(AppConstants.keyHighScore2048, _highScore2048);
      notifyListeners();
    }
  }

  Future<void> updateHighScoreMemory(int moves) async {
    if (_highScoreMemory == 0 || moves < _highScoreMemory) {
      _highScoreMemory = moves;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(AppConstants.keyHighScoreMemory, _highScoreMemory);
      notifyListeners();
    }
  }
}
