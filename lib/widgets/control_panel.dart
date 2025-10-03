import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/speech_service.dart';

class ControlPanel extends StatelessWidget {
  final VoidCallback onStartListening;
  final VoidCallback onStopListening;
  final bool isListening;
  final bool isProcessing;

  const ControlPanel({
    super.key,
    required this.onStartListening,
    required this.onStopListening,
    required this.isListening,
    required this.isProcessing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Controls row
            Consumer<SpeechService>(
              builder: (context, speechService, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Language display
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            speechService.isLanguageOfflineCapable(speechService.detectedLanguage)
                                ? Icons.offline_bolt
                                : Icons.cloud,
                            color: speechService.isLanguageOfflineCapable(speechService.detectedLanguage)
                                ? Colors.green
                                : Colors.blue,
                            size: 20,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            speechService.getLanguageName(speechService.detectedLanguage),
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    
                    // Main microphone button with tap-to-listen
                    GestureDetector(
                      onTap: isProcessing ? null : () async {
                        await speechService.toggleListening();
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: isListening 
                              ? Colors.red 
                              : Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (isListening ? Colors.red : Theme.of(context).primaryColor)
                                  .withOpacity(0.3),
                              blurRadius: 12,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isProcessing 
                                  ? Icons.hourglass_empty
                                  : isListening 
                                      ? Icons.mic 
                                      : Icons.mic_none,
                              color: Colors.white,
                              size: 36,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isListening ? 'Listening...' : 'Tap to Listen',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Status indicator
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isListening ? Icons.hearing : Icons.hearing_disabled,
                            color: isListening ? Colors.green : Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isListening ? 'Active' : 'Idle',
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                          if (isListening)
                            Text(
                              'Auto-stop: 3s',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // Language selector
            Consumer<SpeechService>(
              builder: (context, speechService, child) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: speechService.detectedLanguage,
                    isExpanded: true,
                    underline: const SizedBox(),
                    hint: const Text('Select Language'),
                    items: speechService.languageCodes.map((code) {
                      return DropdownMenuItem(
                        value: code,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                speechService.getLanguageName(code),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (speechService.isLanguageOfflineCapable(code))
                              const Icon(
                                Icons.offline_bolt, 
                                size: 16, 
                                color: Colors.green,
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        speechService.changeLanguage(value);
                      }
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}