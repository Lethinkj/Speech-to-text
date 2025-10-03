import 'package:flutter/foundation.dart';
import 'package:translator/translator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/caption_model.dart';
import '../utils/constants.dart';

class TranslationService extends ChangeNotifier {
  final GoogleTranslator _translator = GoogleTranslator();
  bool _isSimplifying = false;
  bool _isTranslating = false;
  
  // Language detection service
  String _detectedLanguage = 'en';
  
  // Text simplification cache
  final Map<String, String> _simplificationCache = {};
  
  // Pictogram replacement dictionary
  final Map<String, String> _pictogramDictionary = {
    'hello': '👋',
    'goodbye': '👋',
    'thanks': '🙏',
    'thank you': '🙏',
    'yes': '✅',
    'no': '❌',
    'happy': '😊',
    'sad': '😢',
    'angry': '😠',
    'food': '🍽️',
    'water': '💧',
    'home': '🏠',
    'school': '🏫',
    'hospital': '🏥',
    'help': '🆘',
    'emergency': '🚨',
    'police': '👮',
    'doctor': '👨‍⚕️',
    'medicine': '💊',
    'phone': '📱',
    'computer': '💻',
    'book': '📚',
    'car': '🚗',
    'bus': '🚌',
    'train': '🚆',
    'airplane': '✈️',
    'money': '💰',
    'time': '⏰',
    'weather': '🌤️',
    'rain': '🌧️',
    'sun': '☀️',
    'hot': '🔥',
    'cold': '❄️',
  };

  // Getters
  bool get isSimplifying => _isSimplifying;
  bool get isTranslating => _isTranslating;
  String get detectedLanguage => _detectedLanguage;

  // Detect language from text
  Future<String> detectLanguage(String text) async {
    try {
      // Use fastText or similar model for language detection
      // For now, using simple heuristics
      if (text.contains(RegExp(r'[\u0900-\u097F]'))) {
        return 'hi'; // Hindi
      } else if (text.contains(RegExp(r'[\u0980-\u09FF]'))) {
        return 'bn'; // Bengali
      } else if (text.contains(RegExp(r'[\u0C00-\u0C7F]'))) {
        return 'te'; // Telugu
      } else if (text.contains(RegExp(r'[\u0B80-\u0BFF]'))) {
        return 'ta'; // Tamil
      }
      return 'en'; // Default to English
    } catch (e) {
      debugPrint('Language detection error: $e');
      return 'en';
    }
  }

  // Translate text to target language
  Future<String> translateText(String text, String targetLanguage) async {
    if (text.isEmpty) return text;
    
    _isTranslating = true;
    notifyListeners();
    
    try {
      final translation = await _translator.translate(
        text,
        to: targetLanguage,
      );
      
      _isTranslating = false;
      notifyListeners();
      
      return translation.text;
    } catch (e) {
      debugPrint('Translation error: $e');
      _isTranslating = false;
      notifyListeners();
      return text; // Return original text if translation fails
    }
  }

  // Simplify text for better comprehension
  Future<String> simplifyText(String text) async {
    if (text.isEmpty) return text;
    
    // Check cache first
    if (_simplificationCache.containsKey(text)) {
      return _simplificationCache[text]!;
    }
    
    _isSimplifying = true;
    notifyListeners();
    
    try {
      // Use rule-based simplification for common patterns
      String simplified = _ruleBasedSimplification(text);
      
      // If available, use ML-based simplification (T5/mBART)
      simplified = await _mlBasedSimplification(simplified);
      
      // Cache the result
      _simplificationCache[text] = simplified;
      
      _isSimplifying = false;
      notifyListeners();
      
      return simplified;
    } catch (e) {
      debugPrint('Simplification error: $e');
      _isSimplifying = false;
      notifyListeners();
      return text;
    }
  }

  // Rule-based text simplification
  String _ruleBasedSimplification(String text) {
    String simplified = text;
    
    // Replace complex words with simpler alternatives
    final Map<String, String> replacements = {
      'utilize': 'use',
      'assistance': 'help',
      'commence': 'start',
      'terminate': 'end',
      'approximately': 'about',
      'nevertheless': 'but',
      'consequently': 'so',
      'furthermore': 'also',
      'therefore': 'so',
      'however': 'but',
      'immediately': 'now',
      'subsequently': 'then',
      'previously': 'before',
      'currently': 'now',
      'eventually': 'later',
      'necessary': 'needed',
      'important': 'key',
      'significant': 'big',
      'excellent': 'great',
      'terrible': 'bad',
      'magnificent': 'great',
      'enormous': 'huge',
      'tiny': 'small',
    };
    
    for (String complex in replacements.keys) {
      simplified = simplified.replaceAll(
        RegExp(complex, caseSensitive: false),
        replacements[complex]!,
      );
    }
    
    // Simplify sentence structure
    simplified = _simplifySentenceStructure(simplified);
    
    return simplified;
  }

  // Simplify sentence structure
  String _simplifySentenceStructure(String text) {
    // Break long sentences into shorter ones
    List<String> sentences = text.split(RegExp(r'[.!?]+'));
    List<String> simplifiedSentences = [];
    
    for (String sentence in sentences) {
      if (sentence.trim().isEmpty) continue;
      
      // If sentence is too long, try to break it
      if (sentence.length > 100) {
        List<String> parts = sentence.split(RegExp(r'[,;]+'));
        for (String part in parts) {
          if (part.trim().isNotEmpty) {
            simplifiedSentences.add(part.trim() + '.');
          }
        }
      } else {
        simplifiedSentences.add(sentence.trim() + '.');
      }
    }
    
    return simplifiedSentences.join(' ');
  }

  // ML-based text simplification (placeholder for T5/mBART integration)
  Future<String> _mlBasedSimplification(String text) async {
    try {
      // This would integrate with T5 or mBART models
      // For now, return the rule-based simplified text
      return text;
      
      // Example API call structure:
      /*
      final response = await http.post(
        Uri.parse(AppConstants.simplificationApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'text': text,
          'language': _detectedLanguage,
          'style': 'simple',
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['simplified_text'];
      }
      */
    } catch (e) {
      debugPrint('ML simplification error: $e');
    }
    
    return text;
  }

  // Add pictograms to text
  String addPictograms(String text) {
    String textWithPictograms = text;
    
    for (String word in _pictogramDictionary.keys) {
      final pattern = RegExp(r'\b' + RegExp.escape(word) + r'\b', caseSensitive: false);
      textWithPictograms = textWithPictograms.replaceAll(
        pattern,
        '$word ${_pictogramDictionary[word]}',
      );
    }
    
    return textWithPictograms;
  }

  // Process caption with all enhancements
  Future<CaptionModel> processCaption(CaptionModel originalCaption, {
    bool simplify = false,
    bool addPictogramsFlag = false,
    String? targetLanguage,
  }) async {
    String processedText = originalCaption.text;
    List<String> pictograms = [];
    
    // Detect language if not provided
    if (originalCaption.language.isEmpty) {
      _detectedLanguage = await detectLanguage(processedText);
    } else {
      _detectedLanguage = originalCaption.language;
    }
    
    // Translate if target language is different
    if (targetLanguage != null && targetLanguage != _detectedLanguage) {
      processedText = await translateText(processedText, targetLanguage);
    }
    
    // Simplify text if requested
    if (simplify) {
      processedText = await simplifyText(processedText);
    }
    
    // Add pictograms if requested
    if (addPictogramsFlag) {
      processedText = addPictograms(processedText);
      pictograms = _extractPictograms(processedText);
    }
    
    return originalCaption.copyWith(
      text: processedText,
      isSimplified: simplify,
      hasPictograms: addPictogramsFlag,
      pictograms: pictograms,
      metadata: {
        ...originalCaption.metadata,
        'processed_at': DateTime.now().toIso8601String(),
        'detected_language': _detectedLanguage,
        'target_language': targetLanguage,
      },
    );
  }

  // Extract pictograms from text
  List<String> _extractPictograms(String text) {
    List<String> pictograms = [];
    final RegExp emojiRegex = RegExp(
      r'[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|[\u{1F1E0}-\u{1F1FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]',
      unicode: true,
    );
    
    Iterable<Match> matches = emojiRegex.allMatches(text);
    for (Match match in matches) {
      pictograms.add(match.group(0)!);
    }
    
    return pictograms.toSet().toList(); // Remove duplicates
  }

  // Load custom pictogram dictionary
  Future<void> loadCustomPictogramDictionary(Map<String, String> customDict) async {
    _pictogramDictionary.addAll(customDict);
    notifyListeners();
  }

  // Update pictogram dictionary from server
  Future<void> updatePictogramDictionary() async {
    try {
      final response = await http.get(
        Uri.parse(AppConstants.pictogramApiUrl),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final Map<String, String> serverDict = Map<String, String>.from(data['pictograms']);
        _pictogramDictionary.addAll(serverDict);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to update pictogram dictionary: $e');
    }
  }

  // Clear caches
  void clearCaches() {
    _simplificationCache.clear();
    notifyListeners();
  }
}