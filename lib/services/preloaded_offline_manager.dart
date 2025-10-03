import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart';

class PreloadedOfflineManager extends ChangeNotifier {
  static final PreloadedOfflineManager _instance = PreloadedOfflineManager._internal();
  factory PreloadedOfflineManager() => _instance;
  PreloadedOfflineManager._internal();

  final SpeechToText _speechToText = SpeechToText();
  Map<String, bool> _enabledLanguages = {};
  bool _isInitialized = false;
  bool _speechAvailable = false;

  // Preloaded Indian languages - only languages that actually work properly
  final Map<String, String> _preloadedLanguages = {
    'en-US': 'English',
    'hi-IN': 'हिन्दी (Hindi)',
    'bn-IN': 'বাংলা (Bengali)',
    'ta-IN': 'தமিழ் (Tamil)',
    'te-IN': 'తెలుగు (Telugu)',
    'ml-IN': 'മലയാളം (Malayalam)',
    'kn-IN': 'ಕನ್ನಡ (Kannada)',
    'gu-IN': 'ગુજરાતી (Gujarati)',
    'mr-IN': 'मराठी (Marathi)',
    'pa-IN': 'ਪੰਜਾਬੀ (Punjabi)',
    'ne-IN': 'नेपाली (Nepali)',
    'ur-IN': 'اردو (Urdu)',
  };

  // Public getters
  Map<String, String> get availableLanguages => Map.unmodifiable(_preloadedLanguages);
  Map<String, bool> get enabledLanguages => Map.unmodifiable(_enabledLanguages);
  bool get isInitialized => _isInitialized;
  bool get speechAvailable => _speechAvailable;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('🚀 Initializing cleaned language set...');
      
      // Initialize speech recognition
      _speechAvailable = await _speechToText.initialize(
        onError: (error) => debugPrint('🔴 Speech error: $error'),
        onStatus: (status) => debugPrint('🔵 Speech status: $status'),
      );

      if (_speechAvailable) {
        debugPrint('✅ Speech recognition available');
        
        // Load user preferences for enabled languages
        await _loadEnabledLanguages();
        
        debugPrint('✅ Cleaned language manager initialized');
        debugPrint('📊 Working languages: ${_preloadedLanguages.keys.join(', ')}');
      } else {
        debugPrint('❌ Speech recognition not available on device');
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error initializing language manager: $e');
      _isInitialized = true;
    }
  }

  Future<void> _loadEnabledLanguages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Default enabled languages
      _enabledLanguages['en-US'] = true;
      _enabledLanguages['hi-IN'] = true;
      
      // Load user preferences
      for (String languageCode in _preloadedLanguages.keys) {
        final enabled = prefs.getBool('offline_enabled_$languageCode') ?? 
                       (languageCode == 'en-US' || languageCode == 'hi-IN');
        _enabledLanguages[languageCode] = enabled;
      }
    } catch (e) {
      debugPrint('Error loading enabled languages: $e');
    }
  }

  // Enable/disable a language
  Future<bool> toggleLanguage(String languageCode) async {
    if (!_preloadedLanguages.containsKey(languageCode)) {
      debugPrint('Language not available: $languageCode');
      return false;
    }

    try {
      final newState = !(_enabledLanguages[languageCode] ?? false);
      _enabledLanguages[languageCode] = newState;
      
      // Save to preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('offline_enabled_$languageCode', newState);
      
      debugPrint('${newState ? '✅ Enabled' : '❌ Disabled'} language: $languageCode');
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error toggling language: $e');
      return false;
    }
  }

  // Check if language is enabled
  bool isLanguageEnabled(String languageCode) {
    return _enabledLanguages[languageCode] ?? false;
  }

  // Get language display name
  String getLanguageName(String languageCode) {
    return _preloadedLanguages[languageCode] ?? languageCode;
  }

  // Get all enabled language codes
  List<String> getEnabledLanguageCodes() {
    return _enabledLanguages.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
  }

  // Test speech recognition for a specific language
  Future<bool> testLanguageRecognition(String languageCode) async {
    if (!_speechAvailable) {
      debugPrint('Speech recognition not available');
      return false;
    }

    try {
      debugPrint('🧪 Testing speech recognition for: $languageCode');
      
      await _speechToText.listen(
        onResult: (result) {
          debugPrint('🎤 Test result: "${result.recognizedWords}" (confidence: ${result.confidence})');
        },
        localeId: languageCode,
        listenFor: const Duration(milliseconds: 1000),
        pauseFor: const Duration(milliseconds: 500),
        partialResults: true,
      );
      
      // Wait for test completion
      await Future.delayed(const Duration(milliseconds: 1200));
      await _speechToText.stop();
      
      debugPrint('🧪 Test completed for $languageCode');
      return true;
      
    } catch (e) {
      debugPrint('🔴 Test failed for $languageCode: $e');
      return false;
    }
  }

  // Get storage info (for UI display)
  String getStorageInfo() {
    final enabledCount = getEnabledLanguageCodes().length;
    return '${enabledCount} working languages selected';
  }

  // Reset all settings
  Future<void> resetToDefaults() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Remove all offline language preferences
      final keys = prefs.getKeys().where((key) => key.startsWith('offline_enabled_'));
      for (String key in keys) {
        await prefs.remove(key);
      }
      
      // Reload defaults
      await _loadEnabledLanguages();
      notifyListeners();
      
      debugPrint('🔄 Reset to default language settings');
    } catch (e) {
      debugPrint('Error resetting settings: $e');
    }
  }
}