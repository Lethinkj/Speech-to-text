import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/speech_service.dart';
import '../services/translation_service.dart';
import '../services/settings_service.dart';
import '../services/preloaded_offline_manager.dart';
import '../widgets/caption_display.dart';
import '../widgets/control_panel.dart';
import '../widgets/settings_panel.dart';
import '../widgets/preloaded_language_panel.dart';
import '../models/caption_model.dart';
import '../utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showSettings = false;
  bool _showOfflineLanguages = false;
  bool _isProcessing = false;
  
  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    final speechService = Provider.of<SpeechService>(context, listen: false);
    final settingsService = Provider.of<SettingsService>(context, listen: false);
    
    await settingsService.initialize();
    await speechService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // R3D Logo
                Image.asset(
                  'assets/images/r3d_logo.png',
                  width: 24,
                  height: 24,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback to text logo if image fails to load
                    return Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.cyan, width: 2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Center(
                        child: Text(
                          'R3D',
                          style: TextStyle(
                            color: Colors.cyan,
                            fontWeight: FontWeight.bold,
                            fontSize: 8,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                const Text(
                  AppConstants.appName,
                  semanticsLabel: 'Captoniner',
                ),
              ],
            ),
            Text(
              AppConstants.watermark,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () {
              _showDebugInfo(context);
            },
            tooltip: 'Debug Info',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              setState(() {
                _showOfflineLanguages = !_showOfflineLanguages;
                _showSettings = false; // Close settings if open
              });
            },
            tooltip: 'Offline Languages',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              setState(() {
                _showSettings = !_showSettings;
                _showOfflineLanguages = false; // Close languages if open
              });
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer3<SpeechService, TranslationService, SettingsService>(
          builder: (context, speechService, translationService, settingsService, child) {
            return Column(
              children: [
                // Language indicator
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: speechService.isLanguageOfflineCapable(speechService.detectedLanguage)
                      ? Colors.green.shade100
                      : Colors.blue.shade100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        speechService.isListening ? Icons.mic : Icons.mic_none,
                        color: speechService.isListening ? Colors.red : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        speechService.isListening ? 'Listening...' : 'Tap to start',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        speechService.getLanguageName(speechService.detectedLanguage),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        speechService.isLanguageOfflineCapable(speechService.detectedLanguage)
                            ? Icons.offline_bolt
                            : Icons.cloud,
                        size: 16,
                        color: speechService.isLanguageOfflineCapable(speechService.detectedLanguage)
                            ? Colors.green
                            : Colors.blue,
                      ),
                    ],
                  ),
                ),
                
                // Main caption display area
                Expanded(
                  child: Consumer<SpeechService>(
                    builder: (context, speechService, child) {
                      debugPrint('🎯 MOBILE Consumer rebuilt - Words: "${speechService.currentWords}", Listening: ${speechService.isListening}, Confidence: ${speechService.confidence}');
                      
                      // Always show current words, even if empty (for debugging)
                      CaptionModel? currentCaption;
                      if (speechService.currentWords.isNotEmpty) {
                        currentCaption = CaptionModel(
                          text: speechService.currentWords,
                          originalText: speechService.currentWords,
                          language: speechService.detectedLanguage,
                          timestamp: DateTime.now(),
                          confidence: speechService.confidence,
                        );
                        debugPrint('📝 MOBILE Created caption: "${currentCaption.text}"');
                      } else if (speechService.isListening) {
                        // Show listening indicator when no words yet
                        currentCaption = CaptionModel(
                          text: 'Listening for speech...',
                          originalText: '',
                          language: speechService.detectedLanguage,
                          timestamp: DateTime.now(),
                          confidence: 0.0,
                        );
                        debugPrint('👂 MOBILE Showing listening indicator');
                      } else {
                        debugPrint('❌ MOBILE No words and not listening');
                      }
                      
                      return CaptionDisplay(
                        caption: currentCaption,
                        isProcessing: _isProcessing,
                        fontSize: settingsService.fontSize,
                        isListening: speechService.isListening,
                      );
                    },
                  ),
                ),
                
                // Settings panel overlay
                if (_showSettings)
                  Container(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: SettingsPanel(
                      onClose: () {
                        setState(() {
                          _showSettings = false;
                        });
                      },
                    ),
                  ),
                
                // Offline languages panel overlay
                if (_showOfflineLanguages)
                  Container(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: PreloadedLanguagePanel(
                      onClose: () {
                        setState(() {
                          _showOfflineLanguages = false;
                        });
                      },
                    ),
                  ),
                
                // Control panel
                ControlPanel(
                  onStartListening: () async {
                    setState(() {
                      _isProcessing = true;
                    });
                    
                    await speechService.toggleListening();
                    
                    setState(() {
                      _isProcessing = false;
                    });
                  },
                  onStopListening: () async {
                    await speechService.stopListening();
                  },
                  isListening: speechService.isListening,
                  isProcessing: _isProcessing,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showDebugInfo(BuildContext context) {
    final speechService = Provider.of<SpeechService>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.bug_report, color: Colors.orange),
            SizedBox(width: 8),
            Text('Debug Info'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🎤 Is Listening: ${speechService.isListening}'),
            Text('📝 Current Words: "${speechService.currentWords}"'),
            Text('🔊 Confidence: ${speechService.confidence}'),
            Text('🌍 Language: ${speechService.detectedLanguage}'),
            const SizedBox(height: 16),
            const Text('Quick Test:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                if (!speechService.isListening) {
                  await speechService.startListening();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('🎤 Started listening - speak now!')),
                  );
                } else {
                  await speechService.stopListening();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('🛑 Stopped listening')),
                  );
                }
              },
              child: Text(speechService.isListening ? 'Stop Test' : 'Start Test'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
