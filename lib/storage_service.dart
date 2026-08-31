/// Persistent storage service using SharedPreferences
library;

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'game.dart';

/// Manages persistent storage for game statistics, settings, and progress
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;
  bool _initialized = false;

  /// Initialize the storage service
  Future<void> init() async {
    if (!_initialized) {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
    }
  }

  /// Get stored stats or defaults
  GameStats getStats() {
    if (!_initialized || _prefs == null) return GameStats();
    
    return GameStats(
      gamesPlayed: _prefs!.getInt('stats_gamesPlayed') ?? 0,
      gamesWon: _prefs!.getInt('stats_gamesWon') ?? 0,
      currentStreak: _prefs!.getInt('stats_currentStreak') ?? 0,
      maxStreak: _prefs!.getInt('stats_maxStreak') ?? 0,
      guessDistribution: Map<int, int>.from({
        1: _prefs!.getInt('stats_guessDist_1') ?? 0,
        2: _prefs!.getInt('stats_guessDist_2') ?? 0,
        3: _prefs!.getInt('stats_guessDist_3') ?? 0,
        4: _prefs!.getInt('stats_guessDist_4') ?? 0,
        5: _prefs!.getInt('stats_guessDist_5') ?? 0,
        6: _prefs!.getInt('stats_guessDist_6') ?? 0,
      }),
    );
  }

  /// Save game stats
  Future<void> saveStats(GameStats stats) async {
    await init();
    await _prefs!.setInt('stats_gamesPlayed', stats.gamesPlayed);
    await _prefs!.setInt('stats_gamesWon', stats.gamesWon);
    await _prefs!.setInt('stats_currentStreak', stats.currentStreak);
    await _prefs!.setInt('stats_maxStreak', stats.maxStreak);
    for (final entry in stats.guessDistribution.entries) {
      await _prefs!.setInt('stats_guessDist_${entry.key}', entry.value);
    }
  }

  /// Get unlocked achievements
  List<UnlockedAchievement> getAchievements() {
    if (!_initialized || _prefs == null) return [];
    
    final achievementStrings = _prefs!.getStringList('achievements') ?? [];
    return achievementStrings
        .map((jsonStr) => UnlockedAchievement.fromJson(jsonDecode(jsonStr)))
        .toList();
  }

  /// Save achievements
  Future<void> saveAchievements(List<UnlockedAchievement> achievements) async {
    await init();
    final jsonStrings = achievements
        .map((a) => jsonEncode(a.toJson()))
        .toList();
    await _prefs!.setStringList('achievements', jsonStrings);
  }

  /// Get last played daily challenge date
  String? getLastDailyDate() {
    if (!_initialized || _prefs == null) return null;
    return _prefs!.getString('daily_lastPlayed');
  }

  /// Save last played daily challenge date
  Future<void> setLastDailyDate(String date) async {
    await init();
    await _prefs!.setString('daily_lastPlayed', date);
  }

  /// Get saved theme mode (0=system, 1=light, 2=dark)
  int getThemeMode() {
    if (!_initialized || _prefs == null) return 0;
    return _prefs!.getInt('settings_theme') ?? 0;
  }

  /// Save theme mode
  Future<void> setThemeMode(int mode) async {
    await init();
    await _prefs!.setInt('settings_theme', mode);
  }

  /// Get hard mode setting
  bool getHardMode() {
    if (!_initialized || _prefs == null) return false;
    return _prefs!.getBool('settings_hardMode') ?? false;
  }

  /// Save hard mode setting
  Future<void> setHardMode(bool enabled) async {
    await init();
    await _prefs!.setBool('settings_hardMode', enabled);
  }

  /// Get timed mode setting
  bool getTimedMode() {
    if (!_initialized || _prefs == null) return false;
    return _prefs!.getBool('settings_timedMode') ?? false;
  }

  /// Save timed mode setting
  Future<void> setTimedMode(bool enabled) async {
    await init();
    await _prefs!.setBool('settings_timedMode', enabled);
  }

  /// Get preferred word length (4, 5, 6, 7)
  int getWordLength() {
    if (!_initialized || _prefs == null) return 5;
    return _prefs!.getInt('settings_wordLength') ?? 5;
  }

  /// Save preferred word length
  Future<void> setWordLength(int length) async {
    await init();
    await _prefs!.setInt('settings_wordLength', length);
  }

  /// Get game history (last 100 games)
  List<GameHistoryEntry> getHistory() {
    if (!_initialized || _prefs == null) return [];
    
    final historyStrings = _prefs!.getStringList('history') ?? [];
    return historyStrings
        .map((jsonStr) => GameHistoryEntry.fromJson(jsonDecode(jsonStr)))
        .toList();
  }

  /// Add entry to game history
  Future<void> addToHistory(GameHistoryEntry entry) async {
    await init();
    final history = getHistory();
    history.insert(0, entry);
    if (history.length > 100) history.removeLast();
    
    final jsonStrings = history.map((e) => jsonEncode(e.toJson())).toList();
    await _prefs!.setStringList('history', jsonStrings);
  }

  /// Get XP and level
  int getXp() {
    if (!_initialized || _prefs == null) return 0;
    return _prefs!.getInt('progress_xp') ?? 0;
  }

  /// Save XP
  Future<void> setXp(int xp) async {
    await init();
    await _prefs!.setInt('progress_xp', xp);
  }

  /// Get level
  int getLevel() {
    if (!_initialized || _prefs == null) return 1;
    return _prefs!.getInt('progress_level') ?? 1;
  }

  /// Save level
  Future<void> setLevel(int level) async {
    await init();
    await _prefs!.setInt('progress_level', level);
  }

  /// Get combo count
  int getCombo() {
    if (!_initialized || _prefs == null) return 0;
    return _prefs!.getInt('progress_combo') ?? 0;
  }

  /// Save combo count
  Future<void> setCombo(int combo) async {
    await init();
    await _prefs!.setInt('progress_combo', combo);
  }

  /// Reset all data (for testing/debugging)
  Future<void> resetAll() async {
    await init();
    await _prefs!.clear();
  }
}

/// Game statistics data class
class GameStats {
  GameStats({
    this.gamesPlayed = 0,
    this.gamesWon = 0,
    this.currentStreak = 0,
    this.maxStreak = 0,
    Map<int, int>? guessDistribution,
  }) : guessDistribution = guessDistribution ?? {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0};

  final int gamesPlayed;
  final int gamesWon;
  final int currentStreak;
  final int maxStreak;
  final Map<int, int> guessDistribution;

  double get winRate => gamesPlayed > 0 ? gamesWon / gamesPlayed : 0.0;
}

/// Game history entry
class GameHistoryEntry {
  GameHistoryEntry({
    required this.date,
    required this.word,
    required this.guesses,
    required this.won,
    this.wordLength = 5,
    this.hardMode = false,
    this.timedMode = false,
    this.timeSeconds = 0,
  });

  final DateTime date;
  final String word;
  final int guesses;
  final bool won;
  final int wordLength;
  final bool hardMode;
  final bool timedMode;
  final int timeSeconds;

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'word': word,
    'guesses': guesses,
    'won': won,
    'wordLength': wordLength,
    'hardMode': hardMode,
    'timedMode': timedMode,
    'timeSeconds': timeSeconds,
  };

  factory GameHistoryEntry.fromJson(Map<String, dynamic> json) {
    return GameHistoryEntry(
      date: DateTime.parse(json['date']),
      word: json['word'],
      guesses: json['guesses'],
      won: json['won'],
      wordLength: json['wordLength'] ?? 5,
      hardMode: json['hardMode'] ?? false,
      timedMode: json['timedMode'] ?? false,
      timeSeconds: json['timeSeconds'] ?? 0,
    );
  }
}
