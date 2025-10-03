import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class SettingsService extends ChangeNotifier {
  SharedPreferences? _prefs;
  
  // Default settings
  String _selectedLanguage = 'en-IN';
  double _fontSize = AppConstants.defaultFontSize;
  ThemeMode _themeMode = ThemeMode.system;
  bool _pictogramsEnabled = true;
  bool _simplificationEnabled = true;
  bool _highContrastMode = false;
  ASREngine _preferredASREngine = ASREngine.onDevice;
  bool _cloudFallbackEnabled = true;
  bool _offlineMode = false;
  
  // Getters
  String get selectedLanguage => _selectedLanguage;
  double get fontSize => _fontSize;
  ThemeMode get themeMode => _themeMode;
  bool get pictogramsEnabled => _pictogramsEnabled;
  bool get simplificationEnabled => _simplificationEnabled;
  bool get highContrastMode => _highContrastMode;
  ASREngine get preferredASREngine => _preferredASREngine;
  bool get cloudFallbackEnabled => _cloudFallbackEnabled;
  bool get offlineMode => _offlineMode;

  // Initialize settings
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSettings();
  }

  // Load settings from storage
  Future<void> _loadSettings() async {
    if (_prefs == null) return;
    
    _selectedLanguage = _prefs!.getString(AppConstants.languageKey) ?? 'en-IN';
    _fontSize = _prefs!.getDouble(AppConstants.fontSizeKey) ?? AppConstants.defaultFontSize;
    _themeMode = ThemeMode.values[_prefs!.getInt(AppConstants.themeKey) ?? 2];
    _pictogramsEnabled = _prefs!.getBool('pictograms_enabled') ?? true;
    _simplificationEnabled = _prefs!.getBool('simplification_enabled') ?? true;
    _highContrastMode = _prefs!.getBool('high_contrast_mode') ?? false;
    _preferredASREngine = ASREngine.values[_prefs!.getInt('preferred_asr_engine') ?? 0];
    _cloudFallbackEnabled = _prefs!.getBool('cloud_fallback_enabled') ?? true;
    _offlineMode = _prefs!.getBool('offline_mode') ?? false;
    
    notifyListeners();
  }

  // Save settings to storage
  Future<void> _saveSettings() async {
    if (_prefs == null) return;
    
    await _prefs!.setString(AppConstants.languageKey, _selectedLanguage);
    await _prefs!.setDouble(AppConstants.fontSizeKey, _fontSize);
    await _prefs!.setInt(AppConstants.themeKey, _themeMode.index);
    await _prefs!.setBool('pictograms_enabled', _pictogramsEnabled);
    await _prefs!.setBool('simplification_enabled', _simplificationEnabled);
    await _prefs!.setBool('high_contrast_mode', _highContrastMode);
    await _prefs!.setInt('preferred_asr_engine', _preferredASREngine.index);
    await _prefs!.setBool('cloud_fallback_enabled', _cloudFallbackEnabled);
    await _prefs!.setBool('offline_mode', _offlineMode);
  }

  // Update language
  Future<void> updateLanguage(String languageCode) async {
    _selectedLanguage = languageCode;
    await _saveSettings();
    notifyListeners();
  }

  // Update font size
  Future<void> updateFontSize(double size) async {
    _fontSize = size.clamp(AppConstants.minFontSize, AppConstants.maxFontSize);
    await _saveSettings();
    notifyListeners();
  }

  // Update theme mode
  Future<void> updateThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _saveSettings();
    notifyListeners();
  }

  // Toggle pictograms
  Future<void> togglePictograms(bool enabled) async {
    _pictogramsEnabled = enabled;
    await _saveSettings();
    notifyListeners();
  }

  // Toggle text simplification
  Future<void> toggleSimplification(bool enabled) async {
    _simplificationEnabled = enabled;
    await _saveSettings();
    notifyListeners();
  }

  // Toggle high contrast mode
  Future<void> toggleHighContrast(bool enabled) async {
    _highContrastMode = enabled;
    await _saveSettings();
    notifyListeners();
  }

  // Update ASR engine preference
  Future<void> updateASREngine(ASREngine engine) async {
    _preferredASREngine = engine;
    await _saveSettings();
    notifyListeners();
  }

  // Toggle cloud fallback
  Future<void> toggleCloudFallback(bool enabled) async {
    _cloudFallbackEnabled = enabled;
    await _saveSettings();
    notifyListeners();
  }

  // Toggle offline mode
  Future<void> toggleOfflineMode(bool enabled) async {
    _offlineMode = enabled;
    await _saveSettings();
    notifyListeners();
  }

  // Reset settings to defaults
  Future<void> resetToDefaults() async {
    _selectedLanguage = 'en-IN';
    _fontSize = AppConstants.defaultFontSize;
    _themeMode = ThemeMode.system;
    _pictogramsEnabled = true;
    _simplificationEnabled = true;
    _highContrastMode = false;
    _preferredASREngine = ASREngine.onDevice;
    _cloudFallbackEnabled = true;
    _offlineMode = false;
    
    await _saveSettings();
    notifyListeners();
  }

  // Export settings
  Map<String, dynamic> exportSettings() {
    return {
      'selectedLanguage': _selectedLanguage,
      'fontSize': _fontSize,
      'themeMode': _themeMode.index,
      'pictogramsEnabled': _pictogramsEnabled,
      'simplificationEnabled': _simplificationEnabled,
      'highContrastMode': _highContrastMode,
      'preferredASREngine': _preferredASREngine.index,
      'cloudFallbackEnabled': _cloudFallbackEnabled,
      'offlineMode': _offlineMode,
    };
  }

  // Import settings
  Future<void> importSettings(Map<String, dynamic> settings) async {
    _selectedLanguage = settings['selectedLanguage'] ?? 'en-IN';
    _fontSize = (settings['fontSize'] ?? AppConstants.defaultFontSize).clamp(
      AppConstants.minFontSize,
      AppConstants.maxFontSize,
    );
    _themeMode = ThemeMode.values[settings['themeMode'] ?? 2];
    _pictogramsEnabled = settings['pictogramsEnabled'] ?? true;
    _simplificationEnabled = settings['simplificationEnabled'] ?? true;
    _highContrastMode = settings['highContrastMode'] ?? false;
    _preferredASREngine = ASREngine.values[settings['preferredASREngine'] ?? 0];
    _cloudFallbackEnabled = settings['cloudFallbackEnabled'] ?? true;
    _offlineMode = settings['offlineMode'] ?? false;
    
    await _saveSettings();
    notifyListeners();
  }
}