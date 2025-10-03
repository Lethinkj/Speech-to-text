// App Constants
class AppConstants {
  static const String appName = 'Captoniner';
  static const String appSubtitle = 'AI-Powered Live Captions';
  static const String watermark = 'by R3D';
  static const String appVersion = '1.0.0';
  
  // API Endpoints
  static const String baseUrl = 'https://your-api-domain.com';
  static const String websocketUrl = 'wss://your-api-domain.com/ws';
  static const String speechApiUrl = '$baseUrl/api/speech';
  static const String translationApiUrl = '$baseUrl/api/translate';
  static const String simplificationApiUrl = '$baseUrl/api/simplify';
  static const String pictogramApiUrl = '$baseUrl/api/pictograms';
  
  // Database
  static const String databaseName = 'deaf_captioning.db';
  static const int databaseVersion = 1;
  
  // Storage Keys
  static const String userPrefsKey = 'user_preferences';
  static const String languageKey = 'selected_language';
  static const String fontSizeKey = 'font_size';
  static const String themeKey = 'theme_mode';
  static const String captionHistoryKey = 'caption_history';
  static const String offlineGlossaryKey = 'offline_glossary';
  static const String microphoneModeKey = 'microphone_mode';
  static const String offlineModeKey = 'offline_mode';
  
  // Settings
  static const double minFontSize = 12.0;
  static const double maxFontSize = 36.0;
  static const double defaultFontSize = 18.0;
  
  // Speech Recognition
  static const int maxListeningDuration = 30; // seconds
  static const int pauseDuration = 3; // seconds
  static const double confidenceThreshold = 0.5;
  
  // Supported Indian Languages
  static const Map<String, String> indianLanguages = {
    'en-IN': 'English (India)',
    'hi-IN': 'हिन्दी (Hindi)',
    'bn-IN': 'বাংলা (Bengali)',
    'te-IN': 'తెలుగు (Telugu)',
    'mr-IN': 'मराठी (Marathi)',
    'ta-IN': 'தமிழ் (Tamil)',
    'gu-IN': 'ગુજરાતી (Gujarati)',
    'kn-IN': 'ಕನ್ನಡ (Kannada)',
    'ml-IN': 'മലയാളം (Malayalam)',
    'pa-IN': 'ਪੰਜਾਬੀ (Punjabi)',
    'ur-IN': 'اردو (Urdu)',
    'as-IN': 'অসমীয়া (Assamese)',
    'or-IN': 'ଓଡ଼ିଆ (Odia)',
  };
  
  // Error Messages
  static const String microphonePermissionError = 'Microphone permission is required for speech recognition';
  static const String networkError = 'Network connection error. Please check your internet connection.';
  static const String speechRecognitionError = 'Speech recognition failed. Please try again.';
  static const String languageNotSupportedError = 'Selected language is not supported';
  
  // Success Messages
  static const String captionSavedMessage = 'Caption saved successfully';
  static const String settingsUpdatedMessage = 'Settings updated successfully';
  
  // Accessibility
  static const String captionSemanticLabel = 'Live caption text';
  static const String startListeningSemanticLabel = 'Start speech recognition';
  static const String stopListeningSemanticLabel = 'Stop speech recognition';
  static const String settingsSemanticLabel = 'Open settings';
  static const String languageSelectionSemanticLabel = 'Select language';
  static const String fontSizeSemanticLabel = 'Adjust font size';
  static const String pictogramToggleSemanticLabel = 'Toggle pictograms';
}

// Enums
enum ASREngine {
  onDevice,
  googleCloud,
  azureSpeech,
}

enum CaptionDisplayMode {
  simple,
  detailed,
  pictogramsOnly,
}

enum AppThemeMode {
  light,
  dark,
  system,
  highContrast,
}

enum ConnectionStatus {
  connected,
  disconnected,
  connecting,
  error,
}

enum ProcessingStatus {
  idle,
  listening,
  processing,
  complete,
  error,
}