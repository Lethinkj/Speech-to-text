import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

enum MicrophoneMode { tapToListen }

class SpeechService extends ChangeNotifier {
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  String _currentWords = '';
  String _detectedLanguage = 'hi-IN';
  double _confidence = 0.0;
  MicrophoneMode _microphoneMode = MicrophoneMode.tapToListen;
  Timer? _silenceTimer;
  String _lastWords = '';
  
  final Map<String, String> _supportedLanguages = {
    'en-US': 'English',
    'bn-IN': 'বাংলা (Bengali)',
    'gu-IN': 'ગુજરાતી (Gujarati)',
    'hi-IN': 'हिन्दी (Hindi)',
    'kn-IN': 'ಕನ್ನಡ (Kannada)',
    'ml-IN': 'മലയാളം (Malayalam)',
    'mr-IN': 'मराठी (Marathi)',
    'ne-IN': 'नेपाली (Nepali)',
    'pa-IN': 'ਪੰਜਾਬੀ (Punjabi)',
    'ta-IN': 'தமிழ் (Tamil)',
    'te-IN': 'తెలుగు (Telugu)',
    'ur-IN': 'اردو (Urdu)',
  };

  bool get isListening => _isListening;
  String get currentWords => _currentWords;
  String get detectedLanguage => _detectedLanguage;
  double get confidence => _confidence;
  MicrophoneMode get microphoneMode => _microphoneMode;
  List<String> get languageCodes => _supportedLanguages.keys.toList();
  
  String getLanguageName(String code) => _supportedLanguages[code] ?? code;
  bool isLanguageOfflineCapable(String languageCode) => true;

  Future<void> initialize() async {
    try {
      debugPrint('🎤 Initializing MOBILE speech service...');
      
      final permission = await Permission.microphone.request();
      if (permission != PermissionStatus.granted) {
        debugPrint('❌ Microphone permission denied');
        throw Exception('Microphone permission denied');
      }
      debugPrint('✅ Microphone permission granted');
      
      // Initialize speech recognition with simplified configuration
      bool available = await _speechToText.initialize(
        onError: (error) {
          debugPrint('🔴 Speech error: ${error.errorMsg}');
        },
        onStatus: (status) {
          debugPrint('🔵 Speech status: $status');
        },
      );
      
      if (!available) {
        debugPrint('❌ Speech recognition not available');
        throw Exception('Speech recognition not available');
      }
      
      // Test available locales
      final locales = await _speechToText.locales();
      debugPrint('📋 Available locales: ${locales.map((l) => l.localeId).take(5).join(", ")}...');
      
      debugPrint('✅ MOBILE speech service ready!');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Speech initialization error: $e');
      rethrow;
    }
  }

  void setMicrophoneMode(MicrophoneMode mode) {
    _microphoneMode = mode;
    notifyListeners();
  }

  Future<void> startListening({String? languageId}) async {
    if (_isListening) {
      debugPrint('⚠️ Already listening, ignoring start request');
      return;
    }
    
    try {
      debugPrint('🎯 Starting mobile speech recognition...');
      final targetLanguage = languageId ?? _detectedLanguage;
      debugPrint('🌐 Target language: $targetLanguage');
      
      // Clear previous results
      _currentWords = '';
      _confidence = 0.0;
      _lastWords = '';
      
      // Cancel any existing silence timer
      _silenceTimer?.cancel();
      
      // Start with basic configuration first (without onDevice)
      await _speechToText.listen(
        onResult: (result) {
          debugPrint('🎤 MOBILE Speech result: "${result.recognizedWords}" (confidence: ${result.confidence})');
          
          // Update current words immediately
          _currentWords = result.recognizedWords;
          _confidence = result.confidence;
          
          debugPrint('📝 Setting currentWords to: "$_currentWords"');
          
          // Notify UI immediately for live captions
          notifyListeners();
          
          // Reset silence timer on new words
          if (_currentWords != _lastWords && _currentWords.isNotEmpty) {
            _lastWords = _currentWords;
            _resetSilenceTimer();
            debugPrint('✅ Updated captions: "$_currentWords"');
          }
        },
        localeId: targetLanguage,
        listenFor: const Duration(minutes: 5),
        pauseFor: const Duration(seconds: 3),
        partialResults: true, // Enable live captions
        // Remove problematic parameters initially
      );
      
      _isListening = true;
      _resetSilenceTimer();
      
      debugPrint('✅ Mobile speech recognition started successfully');
      debugPrint('🔊 Now listening for speech in $targetLanguage...');
      
      notifyListeners();
      
    } catch (e) {
      debugPrint('❌ Mobile speech recognition error: $e');
      _isListening = false;
      notifyListeners();
      rethrow;
    }
  }

  void _resetSilenceTimer() {
    _silenceTimer?.cancel();
    _silenceTimer = Timer(const Duration(seconds: 3), () {
      if (_isListening) {
        debugPrint('⏰ Auto-stopping due to silence');
        stopListening();
      }
    });
  }

  Future<void> stopListening() async {
    if (!_isListening) {
      debugPrint('⚠️ Not listening, ignoring stop request');
      return;
    }
    
    try {
      debugPrint('🛑 Stopping speech recognition...');
      _silenceTimer?.cancel();
      await _speechToText.stop();
      _isListening = false;
      
      debugPrint('📊 Final result: "$_currentWords" (confidence: $_confidence)');
      debugPrint('✅ Speech recognition stopped');
      
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error stopping speech recognition: $e');
      _isListening = false;
      notifyListeners();
    }
  }

  Future<void> changeLanguage(String languageId) {
    _detectedLanguage = languageId;
    notifyListeners();
    return Future.value();
  }

  // Toggle listening for tap-to-listen mode
  Future<void> toggleListening() async {
    if (_isListening) {
      await stopListening();
    } else {
      await startListening();
    }
  }

  // Get available offline languages
  Future<List<String>> getAvailableOfflineLanguages() async {
    try {
      final locales = await _speechToText.locales();
      final availableOfflineCodes = <String>[];
      
      for (final locale in locales) {
        // Check if the locale matches our supported Indian languages
        if (_supportedLanguages.containsKey(locale.localeId)) {
          availableOfflineCodes.add(locale.localeId);
        }
      }
      
      // If device doesn't have specific Indian language models,
      // still show them as available (using fallback or basic recognition)
      return _supportedLanguages.keys.toList();
    } catch (e) {
      debugPrint('Error getting offline languages: $e');
      // Return all supported languages as fallback
      return _supportedLanguages.keys.toList();
    }
  }

  // Check if specific language model is downloaded
  Future<bool> isLanguageModelDownloaded(String languageCode) async {
    try {
      final locales = await _speechToText.locales();
      return locales.any((locale) => locale.localeId == languageCode);
    } catch (e) {
      debugPrint('Error checking language model: $e');
      // Assume all Indian languages are available offline
      return _supportedLanguages.containsKey(languageCode);
    }
  }

  // Download language model for offline use
  Future<bool> downloadLanguageModel(String languageCode) async {
    try {
      // Note: The speech_to_text plugin doesn't have direct download functionality
      // This is a placeholder for future implementation or device-level language downloads
      debugPrint('Language model download requested for: $languageCode');
      
      // For now, we'll assume the language is available
      // In a real implementation, this would trigger device-level language downloads
      return true;
    } catch (e) {
      debugPrint('Error downloading language model: $e');
      return false;
    }
  }

  // Get offline language status
  Map<String, bool> getOfflineLanguageStatus() {
    final status = <String, bool>{};
    for (final languageCode in _supportedLanguages.keys) {
      // Mark all Indian languages as available offline
      status[languageCode] = true;
    }
    return status;
  }

  @override
  void dispose() {
    _silenceTimer?.cancel();
    _speechToText.cancel();
    super.dispose();
  }
}
