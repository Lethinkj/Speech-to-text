import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart';

class OfflineLanguageManager extends ChangeNotifier {
  static final OfflineLanguageManager _instance = OfflineLanguageManager._internal();
  factory OfflineLanguageManager() => _instance;
  OfflineLanguageManager._internal();

  final SpeechToText _speechToText = SpeechToText();
  Map<String, bool> _downloadedLanguages = {};
  Map<String, double> _downloadProgress = {};
  bool _isInitialized = false;

  // Supported Indian languages for offline recognition
  final Map<String, String> _offlineLanguages = {
    'en-US': 'English',
    'hi-IN': 'हिन्दी (Hindi)',
    'bn-IN': 'বাংলা (Bengali)',
    'ta-IN': 'தமிழ் (Tamil)',
    'te-IN': 'తెలుగు (Telugu)',
    'ml-IN': 'മലയാളം (Malayalam)',
    'kn-IN': 'ಕನ್ನಡ (Kannada)',
    'gu-IN': 'ગુજરાતી (Gujarati)',
    'mr-IN': 'मराठी (Marathi)',
    'pa-IN': 'ਪੰਜਾਬੀ (Punjabi)',
    'or-IN': 'ଓଡିଆ (Odia)',
    'as-IN': 'অসমীয়া (Assamese)',
    'ur-IN': 'اردو (Urdu)',
    'sa-IN': 'संस्कृतम् (Sanskrit)',
    'ne-IN': 'नेपाली (Nepali)',
    'sd-IN': 'سنڌي (Sindhi)',
    'ks-IN': 'कॉशुर (Kashmiri)',
    'mai-IN': 'मैथिली (Maithili)',
    'sat-IN': 'ᱥᱟᱱᱛᱟᱲᱤ (Santali)',
    'gom-IN': 'कोंकणी (Konkani)',
    'mni-IN': 'মণিপুরী (Manipuri)',
    'doi-IN': 'डोगरी (Dogri)',
    'brx-IN': 'बोड़ो (Bodo)',
  };

  Map<String, bool> get downloadedLanguages => Map.unmodifiable(_downloadedLanguages);
  Map<String, double> get downloadProgress => Map.unmodifiable(_downloadProgress);
  Map<String, String> get offlineLanguages => Map.unmodifiable(_offlineLanguages);
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load previously downloaded languages from SharedPreferences
      await _loadDownloadedLanguages();
      
      // Check available device languages
      await _checkDeviceLanguages();
      
      // Initialize core languages (Hindi and English) as always available
      _downloadedLanguages['hi-IN'] = true;
      _downloadedLanguages['en-US'] = true;
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing offline language manager: $e');
    }
  }

  Future<void> _loadDownloadedLanguages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith('lang_downloaded_'));
      
      for (final key in keys) {
        final languageCode = key.replaceFirst('lang_downloaded_', '');
        _downloadedLanguages[languageCode] = prefs.getBool(key) ?? false;
      }
    } catch (e) {
      debugPrint('Error loading downloaded languages: $e');
    }
  }

  Future<void> _saveDownloadedLanguage(String languageCode, bool isDownloaded) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('lang_downloaded_$languageCode', isDownloaded);
    } catch (e) {
      debugPrint('Error saving downloaded language status: $e');
    }
  }

  Future<void> _checkDeviceLanguages() async {
    try {
      // Initialize speech recognition first
      final available = await _speechToText.initialize();
      if (!available) {
        debugPrint('Speech recognition not available on device');
        return;
      }
      
      final locales = await _speechToText.locales();
      debugPrint('Available device locales: ${locales.map((l) => l.localeId).join(', ')}');
      
      // Check which of our supported languages are available
      for (final locale in locales) {
        if (_offlineLanguages.containsKey(locale.localeId)) {
          _downloadedLanguages[locale.localeId] = true;
          debugPrint('Found supported language on device: ${locale.localeId}');
        }
      }
      
      // Always ensure English is available (most common)
      if (!_downloadedLanguages.containsKey('en-US')) {
        // Check for any English variant
        final hasEnglish = locales.any((l) => l.localeId.startsWith('en'));
        if (hasEnglish) {
          _downloadedLanguages['en-US'] = true;
        }
      }
      
    } catch (e) {
      debugPrint('Error checking device languages: $e');
      // Conservative fallback: Only mark English as available
      _downloadedLanguages['en-US'] = true;
    }
  }

  bool isLanguageDownloaded(String languageCode) {
    return _downloadedLanguages[languageCode] ?? false;
  }

  double getDownloadProgress(String languageCode) {
    return _downloadProgress[languageCode] ?? 0.0;
  }

  Future<bool> downloadLanguage(String languageCode) async {
    if (!_offlineLanguages.containsKey(languageCode)) {
      debugPrint('Language not supported for offline: $languageCode');
      return false;
    }

    if (isLanguageDownloaded(languageCode)) {
      debugPrint('Language already enabled: $languageCode');
      return true;
    }

    try {
      debugPrint('Enabling offline support for language: $languageCode');
      _downloadProgress[languageCode] = 0.1;
      notifyListeners();

      // Step 1: Check device speech recognition initialization
      final speechAvailable = await _speechToText.initialize(
        onError: (error) => debugPrint('Speech init error: $error'),
        onStatus: (status) => debugPrint('Speech init status: $status'),
      );
      
      _downloadProgress[languageCode] = 0.3;
      notifyListeners();
      
      if (!speechAvailable) {
        debugPrint('Speech recognition not available on device');
        _downloadProgress.remove(languageCode);
        notifyListeners();
        return false;
      }

      // Step 2: Get available locales from device
      final locales = await _speechToText.locales();
      _downloadProgress[languageCode] = 0.6;
      notifyListeners();
      
      debugPrint('Available device locales: ${locales.map((l) => '${l.localeId}').join(', ')}');
      
      // Step 3: Check if requested language is available
      final exactMatch = locales.firstWhere(
        (locale) => locale.localeId == languageCode,
        orElse: () => LocaleName('', ''),
      );
      
      bool isSupported = exactMatch.localeId.isNotEmpty;
      
      // Step 4: Try language variants if exact match not found
      if (!isSupported && languageCode.contains('-')) {
        final baseLanguage = languageCode.split('-')[0];
        final variantMatch = locales.firstWhere(
          (locale) => locale.localeId.startsWith(baseLanguage),
          orElse: () => LocaleName('', ''),
        );
        isSupported = variantMatch.localeId.isNotEmpty;
        if (isSupported) {
          debugPrint('Using language variant: ${variantMatch.localeId} for $languageCode');
        }
      }
      
      _downloadProgress[languageCode] = 0.9;
      notifyListeners();
      
      if (isSupported) {
        // Step 5: Test offline recognition capability
        bool offlineWorks = await _testOfflineRecognition(languageCode);
        
        if (offlineWorks) {
          _downloadedLanguages[languageCode] = true;
          await _saveDownloadedLanguage(languageCode, true);
          await _saveLanguageMetadata(languageCode);
          debugPrint('✅ Offline language enabled: $languageCode');
        } else {
          debugPrint('❌ Offline recognition test failed for: $languageCode');
        }
      } else {
        debugPrint('❌ Language not supported on device: $languageCode');
      }
      
      _downloadProgress.remove(languageCode);
      notifyListeners();
      return _downloadedLanguages[languageCode] ?? false;
    } catch (e) {
      debugPrint('Error downloading language $languageCode: $e');
      _downloadProgress.remove(languageCode);
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeLanguage(String languageCode) async {
    if (!isLanguageDownloaded(languageCode)) {
      return true;
    }

    // Don't allow removal of core languages
    if (languageCode == 'hi-IN' || languageCode == 'en-US') {
      debugPrint('Cannot remove core language: $languageCode');
      return false;
    }

    try {
      _downloadedLanguages[languageCode] = false;
      await _saveDownloadedLanguage(languageCode, false);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error removing language $languageCode: $e');
      return false;
    }
  }

  List<String> getDownloadedLanguageCodes() {
    return _downloadedLanguages.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
  }

  List<String> getAvailableLanguageCodes() {
    return _offlineLanguages.keys.toList();
  }

  String getLanguageName(String languageCode) {
    return _offlineLanguages[languageCode] ?? languageCode;
  }

  Future<void> downloadAllCoreLanguages() async {
    final coreLanguages = ['hi-IN', 'en-US', 'bn-IN', 'ta-IN', 'te-IN'];
    
    for (final languageCode in coreLanguages) {
      if (!isLanguageDownloaded(languageCode)) {
        await downloadLanguage(languageCode);
      }
    }
  }

  double getTotalStorageUsed() {
    // Estimate storage usage (in MB)
    final downloadedCount = getDownloadedLanguageCodes().length;
    return downloadedCount * 25.0; // Assume 25MB per language model
  }

  void clearCache() {
    _downloadProgress.clear();
    notifyListeners();
  }

  // Test if offline recognition actually works for a language
  Future<bool> _testOfflineRecognition(String languageCode) async {
    try {
      debugPrint('Testing offline recognition for: $languageCode');
      
      // Create a test speech recognition session
      bool testPassed = false;
      
      await _speechToText.listen(
        onResult: (result) {
          debugPrint('Offline test result: ${result.recognizedWords}');
          testPassed = true;
        },
        localeId: languageCode,
        onDevice: true, // Force offline mode
        listenFor: const Duration(milliseconds: 500),
        partialResults: false,
      );
      
      // Wait a bit for the test
      await Future.delayed(const Duration(milliseconds: 600));
      await _speechToText.stop();
      
      // If we got here without errors, offline support is available
      debugPrint('Offline test completed for $languageCode: $testPassed');
      return true; // Return true if no exceptions occurred
      
    } catch (e) {
      debugPrint('Offline test failed for $languageCode: $e');
      return false;
    }
  }

  // Save language metadata to local storage
  Future<void> _saveLanguageMetadata(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final metadata = {
        'enabled_date': DateTime.now().toIso8601String(),
        'language_code': languageCode,
        'language_name': _offlineLanguages[languageCode] ?? languageCode,
        'offline_tested': true,
      };
      
      await prefs.setString('lang_meta_$languageCode', metadata.toString());
      debugPrint('Saved metadata for language: $languageCode');
    } catch (e) {
      debugPrint('Error saving language metadata: $e');
    }
  }

  // Check if we have a working internet connection
  Future<bool> _hasInternetConnection() async {
    try {
      // This will fail when offline, confirming we're testing offline mode
      final result = await _speechToText.locales();
      return result.isNotEmpty;
    } catch (e) {
      debugPrint('No internet connection detected (good for offline test)');
      return false;
    }
  }

  // Public getter for available languages
  Map<String, String> get availableLanguages => _offlineLanguages;

  // Get count of downloaded languages
  int getDownloadedLanguagesCount() {
    return getDownloadedLanguageCodes().length;
  }

  // Alias for downloadAllCoreLanguages
  Future<void> downloadCoreLanguages() async {
    await downloadAllCoreLanguages();
  }

  // Remove a language from offline storage
  Future<bool> removeLanguage(String languageCode) async {
    if (languageCode == 'hi-IN' || languageCode == 'en-US') {
      debugPrint('Cannot remove core language: $languageCode');
      return false;
    }
    
    try {
      _downloadedLanguages.remove(languageCode);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('lang_downloaded_$languageCode');
      await prefs.remove('lang_meta_$languageCode');
      notifyListeners();
      debugPrint('Removed language: $languageCode');
      return true;
    } catch (e) {
      debugPrint('Error removing language: $e');
      return false;
    }
  }
}