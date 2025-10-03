// Test script to verify offline functionality
// Run this with: flutter test test_offline_functionality.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'lib/services/offline_language_manager.dart';
import 'lib/services/speech_service.dart';

void main() {
  group('Offline Functionality Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('OfflineLanguageManager initialization', () async {
      final manager = OfflineLanguageManager();
      await manager.initialize();
      
      expect(manager.availableLanguages.length, equals(22));
      expect(manager.availableLanguages.containsKey('hi-IN'), isTrue);
      expect(manager.availableLanguages.containsKey('en-IN'), isTrue);
    });

    test('Language download simulation', () async {
      final manager = OfflineLanguageManager();
      await manager.initialize();
      
      // Test download progress
      bool downloadCompleted = false;
      manager.addListener(() {
        if (manager.downloadProgress['hi-IN'] == 1.0) {
          downloadCompleted = true;
        }
      });
      
      await manager.downloadLanguage('hi-IN');
      
      // Wait for download completion (simulated)
      await Future.delayed(Duration(milliseconds: 3100));
      
      expect(downloadCompleted, isTrue);
      expect(await manager.isLanguageDownloaded('hi-IN'), isTrue);
    });

    test('SpeechService offline capability check', () async {
      final speechService = SpeechService();
      await speechService.initialize();
      
      // Test Indian languages offline capability
      expect(speechService.isLanguageOfflineCapable('hi-IN'), isTrue);
      expect(speechService.isLanguageOfflineCapable('ta-IN'), isTrue);
      expect(speechService.isLanguageOfflineCapable('bn-IN'), isTrue);
      expect(speechService.isLanguageOfflineCapable('te-IN'), isTrue);
      
      // Test non-Indian language
      expect(speechService.isLanguageOfflineCapable('fr-FR'), isFalse);
    });

    test('Storage management', () async {
      final manager = OfflineLanguageManager();
      await manager.initialize();
      
      // Download a few languages
      await manager.downloadLanguage('hi-IN');
      await manager.downloadLanguage('ta-IN');
      await manager.downloadLanguage('bn-IN');
      
      // Wait for downloads to complete
      await Future.delayed(Duration(milliseconds: 10000));
      
      double totalStorage = manager.getTotalStorageUsed();
      expect(totalStorage, greaterThan(0));
      
      int downloadedCount = manager.getDownloadedLanguagesCount();
      expect(downloadedCount, equals(3));
    });

    test('Core languages download', () async {
      final manager = OfflineLanguageManager();
      await manager.initialize();
      
      List<String> coreLanguages = ['hi-IN', 'en-IN', 'ta-IN', 'te-IN', 'bn-IN'];
      
      bool allDownloadsStarted = false;
      manager.addListener(() {
        bool allStarted = coreLanguages.every((lang) => 
          manager.downloadProgress.containsKey(lang) && 
          manager.downloadProgress[lang]! > 0);
        if (allStarted) {
          allDownloadsStarted = true;
        }
      });
      
      await manager.downloadCoreLanguages();
      
      // Wait for all downloads to start
      await Future.delayed(Duration(milliseconds: 500));
      
      expect(allDownloadsStarted, isTrue);
    });
  });
}