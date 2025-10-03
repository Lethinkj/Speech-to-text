import 'package:hive/hive.dart';

part 'caption_model.g.dart';

@HiveType(typeId: 0)
class CaptionModel extends HiveObject {
  @HiveField(0)
  final String text;
  
  @HiveField(1)
  final String originalText;
  
  @HiveField(2)
  final String language;
  
  @HiveField(3)
  final double confidence;
  
  @HiveField(4)
  final DateTime timestamp;
  
  @HiveField(5)
  final bool isSimplified;
  
  @HiveField(6)
  final bool hasPictograms;
  
  @HiveField(7)
  final List<String> pictograms;
  
  @HiveField(8)
  final Map<String, dynamic> metadata;

  CaptionModel({
    required this.text,
    String? originalText,
    required this.language,
    required this.confidence,
    required this.timestamp,
    this.isSimplified = false,
    this.hasPictograms = false,
    this.pictograms = const [],
    this.metadata = const {},
  }) : originalText = originalText ?? text;

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'originalText': originalText,
      'language': language,
      'confidence': confidence,
      'timestamp': timestamp.toIso8601String(),
      'isSimplified': isSimplified,
      'hasPictograms': hasPictograms,
      'pictograms': pictograms,
      'metadata': metadata,
    };
  }

  // Create from JSON
  factory CaptionModel.fromJson(Map<String, dynamic> json) {
    return CaptionModel(
      text: json['text'],
      originalText: json['originalText'],
      language: json['language'],
      confidence: json['confidence'].toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      isSimplified: json['isSimplified'] ?? false,
      hasPictograms: json['hasPictograms'] ?? false,
      pictograms: List<String>.from(json['pictograms'] ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  // Create a copy with modifications
  CaptionModel copyWith({
    String? text,
    String? originalText,
    String? language,
    double? confidence,
    DateTime? timestamp,
    bool? isSimplified,
    bool? hasPictograms,
    List<String>? pictograms,
    Map<String, dynamic>? metadata,
  }) {
    return CaptionModel(
      text: text ?? this.text,
      originalText: originalText ?? this.originalText,
      language: language ?? this.language,
      confidence: confidence ?? this.confidence,
      timestamp: timestamp ?? this.timestamp,
      isSimplified: isSimplified ?? this.isSimplified,
      hasPictograms: hasPictograms ?? this.hasPictograms,
      pictograms: pictograms ?? this.pictograms,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'CaptionModel(text: $text, language: $language, confidence: $confidence)';
  }
}

class LanguageModel {
  final String code;
  final String name;
  final String nativeName;
  final bool isSupported;
  final bool isIndianLanguage;

  LanguageModel({
    required this.code,
    required this.name,
    required this.nativeName,
    this.isSupported = true,
    this.isIndianLanguage = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'nativeName': nativeName,
      'isSupported': isSupported,
      'isIndianLanguage': isIndianLanguage,
    };
  }

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      code: json['code'],
      name: json['name'],
      nativeName: json['nativeName'],
      isSupported: json['isSupported'] ?? true,
      isIndianLanguage: json['isIndianLanguage'] ?? false,
    );
  }
}

class PictogramModel {
  final String word;
  final String emoji;
  final String description;
  final String category;
  final List<String> synonyms;

  PictogramModel({
    required this.word,
    required this.emoji,
    required this.description,
    required this.category,
    this.synonyms = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'emoji': emoji,
      'description': description,
      'category': category,
      'synonyms': synonyms,
    };
  }

  factory PictogramModel.fromJson(Map<String, dynamic> json) {
    return PictogramModel(
      word: json['word'],
      emoji: json['emoji'],
      description: json['description'],
      category: json['category'],
      synonyms: List<String>.from(json['synonyms'] ?? []),
    );
  }
}