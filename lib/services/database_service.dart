import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/caption_model.dart';

class DatabaseService {
  static Box<CaptionModel>? _captionsBox;
  static Box<Map>? _settingsBox;
  static Box<Map>? _languagesBox;
  static Box<Map>? _pictogramsBox;
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Future<void> initialize() async {
    if (!Hive.isBoxOpen('captions')) {
      _captionsBox = await Hive.openBox<CaptionModel>('captions');
    } else {
      _captionsBox = Hive.box<CaptionModel>('captions');
    }

    if (!Hive.isBoxOpen('settings')) {
      _settingsBox = await Hive.openBox<Map>('settings');
    } else {
      _settingsBox = Hive.box<Map>('settings');
    }

    if (!Hive.isBoxOpen('languages')) {
      _languagesBox = await Hive.openBox<Map>('languages');
    } else {
      _languagesBox = Hive.box<Map>('languages');
    }

    if (!Hive.isBoxOpen('pictograms')) {
      _pictogramsBox = await Hive.openBox<Map>('pictograms');
    } else {
      _pictogramsBox = Hive.box<Map>('pictograms');
    }

    // Initialize default data if boxes are empty
    await _initializeDefaultData();
  }

  Future<void> _initializeDefaultData() async {
    // Initialize default languages if empty
    if (_languagesBox!.isEmpty) {
      await _insertDefaultLanguages();
    }
    
    // Initialize default settings if empty
    if (_settingsBox!.isEmpty) {
      await _insertDefaultSettings();
    }
  }

  Future<void> _insertDefaultLanguages() async {
    final defaultLanguages = [
      {'code': 'en-US', 'name': 'English', 'is_offline': 1},
      {'code': 'as-IN', 'name': 'অসমীয়া (Assamese)', 'is_offline': 1},
      {'code': 'bn-IN', 'name': 'বাংলা (Bengali)', 'is_offline': 1},
      {'code': 'brx-IN', 'name': 'बोड़ो (Bodo)', 'is_offline': 1},
      {'code': 'doi-IN', 'name': 'डोगरी (Dogri)', 'is_offline': 1},
      {'code': 'gu-IN', 'name': 'ગુજરાતી (Gujarati)', 'is_offline': 1},
      {'code': 'hi-IN', 'name': 'हिन्दी (Hindi)', 'is_offline': 1},
      {'code': 'kn-IN', 'name': 'ಕನ್ನಡ (Kannada)', 'is_offline': 1},
      {'code': 'ks-IN', 'name': 'कॉशुर (Kashmiri)', 'is_offline': 1},
      {'code': 'gom-IN', 'name': 'कोंकणी (Konkani)', 'is_offline': 1},
      {'code': 'mai-IN', 'name': 'मैथिली (Maithili)', 'is_offline': 1},
      {'code': 'ml-IN', 'name': 'മലയാളം (Malayalam)', 'is_offline': 1},
      {'code': 'mni-IN', 'name': 'মণিপুরী (Manipuri)', 'is_offline': 1},
      {'code': 'mr-IN', 'name': 'मराठी (Marathi)', 'is_offline': 1},
      {'code': 'ne-IN', 'name': 'नेपाली (Nepali)', 'is_offline': 1},
      {'code': 'or-IN', 'name': 'ଓଡିଆ (Odia)', 'is_offline': 1},
      {'code': 'pa-IN', 'name': 'ਪੰਜਾਬੀ (Punjabi)', 'is_offline': 1},
      {'code': 'sa-IN', 'name': 'संस्कृतम् (Sanskrit)', 'is_offline': 1},
      {'code': 'sat-IN', 'name': 'ᱥᱟᱱᱛᱟᱲᱤ (Santali)', 'is_offline': 1},
      {'code': 'sd-IN', 'name': 'سنڌي (Sindhi)', 'is_offline': 1},
      {'code': 'ta-IN', 'name': 'தமிழ் (Tamil)', 'is_offline': 1},
      {'code': 'te-IN', 'name': 'తెలుగు (Telugu)', 'is_offline': 1},
      {'code': 'ur-IN', 'name': 'اردو (Urdu)', 'is_offline': 1},
    ];

    for (int i = 0; i < defaultLanguages.length; i++) {
      await _languagesBox!.put(i, defaultLanguages[i]);
    }
  }

  Future<void> _insertDefaultSettings() async {
    final defaultSettings = {
      'current_language': 'hi-IN',
      'auto_language_detection': 1,
      'font_size': 18.0,
      'theme_mode': 'light',
      'notification_enabled': 1,
      'offline_mode': 1,
      'voice_feedback': 0,
      'haptic_feedback': 1,
      'show_confidence': 1,
      'auto_scroll': 1,
      'save_history': 1,
      'max_history_days': 30,
      'microphone_mode': 'tapToListen',
      'silence_detection': 1,
      'live_captions': 1,
    };

    await _settingsBox!.put('app_settings', defaultSettings);
  }

  // Caption management methods
  Future<int> insertCaption(CaptionModel caption) async {
    try {
      final key = _captionsBox!.length;
      await _captionsBox!.put(key, caption);
      return key;
    } catch (e) {
      if (kDebugMode) {
        print('Error inserting caption: $e');
      }
      return -1;
    }
  }

  Future<List<CaptionModel>> getAllCaptions() async {
    try {
      return _captionsBox!.values.toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting all captions: $e');
      }
      return [];
    }
  }

  Future<List<CaptionModel>> getCaptionsByLanguage(String language) async {
    try {
      return _captionsBox!.values
          .where((caption) => caption.language == language)
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting captions by language: $e');
      }
      return [];
    }
  }

  Future<CaptionModel?> getCaptionById(int id) async {
    try {
      return _captionsBox!.get(id);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting caption by id: $e');
      }
      return null;
    }
  }

  Future<bool> updateCaption(int id, CaptionModel caption) async {
    try {
      await _captionsBox!.put(id, caption);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating caption: $e');
      }
      return false;
    }
  }

  Future<bool> deleteCaption(int id) async {
    try {
      await _captionsBox!.delete(id);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting caption: $e');
      }
      return false;
    }
  }

  Future<bool> deleteCaptionsByLanguage(String language) async {
    try {
      final keysToDelete = <int>[];
      _captionsBox!.toMap().forEach((key, caption) {
        if (caption.language == language) {
          keysToDelete.add(key);
        }
      });
      
      for (final key in keysToDelete) {
        await _captionsBox!.delete(key);
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting captions by language: $e');
      }
      return false;
    }
  }

  Future<bool> clearAllCaptions() async {
    try {
      await _captionsBox!.clear();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing all captions: $e');
      }
      return false;
    }
  }

  // Language management methods
  Future<List<Map<String, dynamic>>> getSupportedLanguages() async {
    try {
      return _languagesBox!.values.cast<Map<String, dynamic>>().toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting supported languages: $e');
      }
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getOfflineLanguages() async {
    try {
      return _languagesBox!.values
          .cast<Map<String, dynamic>>()
          .where((lang) => lang['is_offline'] == 1)
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting offline languages: $e');
      }
      return [];
    }
  }

  // Settings management methods
  Future<Map<String, dynamic>?> getSettings() async {
    try {
      final settings = _settingsBox!.get('app_settings');
      return settings?.cast<String, dynamic>();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting settings: $e');
      }
      return null;
    }
  }

  Future<bool> updateSettings(Map<String, dynamic> settings) async {
    try {
      await _settingsBox!.put('app_settings', settings);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating settings: $e');
      }
      return false;
    }
  }

  Future<T?> getSetting<T>(String key) async {
    try {
      final settings = await getSettings();
      return settings?[key] as T?;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting setting $key: $e');
      }
      return null;
    }
  }

  Future<bool> setSetting<T>(String key, T value) async {
    try {
      final settings = await getSettings() ?? <String, dynamic>{};
      settings[key] = value;
      return await updateSettings(settings);
    } catch (e) {
      if (kDebugMode) {
        print('Error setting $key: $e');
      }
      return false;
    }
  }

  // Search methods
  Future<List<CaptionModel>> searchCaptions({
    String? query,
    String? language,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var results = _captionsBox!.values.toList();

      if (query != null && query.isNotEmpty) {
        results = results
            .where((caption) =>
                caption.text.toLowerCase().contains(query.toLowerCase()) ||
                caption.originalText.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }

      if (language != null && language.isNotEmpty) {
        results = results
            .where((caption) => caption.language == language)
            .toList();
      }

      if (startDate != null) {
        results = results
            .where((caption) => caption.timestamp.isAfter(startDate))
            .toList();
      }

      if (endDate != null) {
        results = results
            .where((caption) => caption.timestamp.isBefore(endDate))
            .toList();
      }

      return results;
    } catch (e) {
      if (kDebugMode) {
        print('Error searching captions: $e');
      }
      return [];
    }
  }

  // Statistics methods
  Future<Map<String, int>> getCaptionStatistics() async {
    try {
      final captions = _captionsBox!.values.toList();
      final stats = <String, int>{};

      stats['total_captions'] = captions.length;
      stats['languages_used'] = captions.map((c) => c.language).toSet().length;

      // Group by language
      final languageStats = <String, int>{};
      for (final caption in captions) {
        languageStats[caption.language] = 
            (languageStats[caption.language] ?? 0) + 1;
      }
      stats.addAll(languageStats);

      return stats;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting caption statistics: $e');
      }
      return {};
    }
  }

  // Cleanup methods
  Future<void> cleanupOldData() async {
    try {
      final maxHistoryDays = await getSetting<int>('max_history_days') ?? 30;
      final cutoffDate = DateTime.now().subtract(Duration(days: maxHistoryDays));
      
      final keysToDelete = <int>[];
      _captionsBox!.toMap().forEach((key, caption) {
        if (caption.timestamp.isBefore(cutoffDate)) {
          keysToDelete.add(key);
        }
      });
      
      for (final key in keysToDelete) {
        await _captionsBox!.delete(key);
      }
      
      if (kDebugMode) {
        print('Cleaned up ${keysToDelete.length} old captions');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error cleaning up old data: $e');
      }
    }
  }

  Future<void> close() async {
    try {
      await _captionsBox?.close();
      await _settingsBox?.close();
      await _languagesBox?.close();
      await _pictogramsBox?.close();
      
      _captionsBox = null;
      _settingsBox = null;
      _languagesBox = null;
      _pictogramsBox = null;
    } catch (e) {
      if (kDebugMode) {
        print('Error closing database: $e');
      }
    }
  }
}