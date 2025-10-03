import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/preloaded_offline_manager.dart';

class PreloadedLanguagePanel extends StatefulWidget {
  final VoidCallback onClose;

  const PreloadedLanguagePanel({
    super.key,
    required this.onClose,
  });

  @override
  State<PreloadedLanguagePanel> createState() => _PreloadedLanguagePanelState();
}

class _PreloadedLanguagePanelState extends State<PreloadedLanguagePanel> {
  @override
  void initState() {
    super.initState();
    // Ensure the manager is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final manager = Provider.of<PreloadedOfflineManager>(context, listen: false);
      if (!manager.isInitialized) {
        manager.initialize();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Icon(Icons.offline_bolt, color: Colors.green.shade600, size: 24),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Offline Languages (Preloaded)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onClose,
                ),
              ],
            ),
          ),

          // Info Banner
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.green.shade700, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'No downloads needed! Languages are built into the app and work offline.',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

          // Language List
          Expanded(
            child: Consumer<PreloadedOfflineManager>(
              builder: (context, manager, child) {
                if (!manager.isInitialized) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Initializing offline speech recognition...'),
                      ],
                    ),
                  );
                }

                if (!manager.speechAvailable) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.mic_off, size: 48, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'Speech recognition not available',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Please check device settings or try restarting the app.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // Storage Info
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.storage, color: Colors.blue.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Storage Usage',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                                Text(
                                  manager.getStorageInfo(),
                                  style: TextStyle(
                                    color: Colors.blue.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              await manager.resetToDefaults();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Reset to defaults')),
                              );
                            },
                            child: const Text('Reset'),
                          ),
                        ],
                      ),
                    ),

                    // Language List
                    ...manager.availableLanguages.entries.map((entry) {
                      final languageCode = entry.key;
                      final languageName = entry.value;
                      final isEnabled = manager.isLanguageEnabled(languageCode);
                      final isCore = languageCode == 'hi-IN' || languageCode == 'en-US';

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: SwitchListTile(
                          secondary: CircleAvatar(
                            backgroundColor: isEnabled ? Colors.green : Colors.grey,
                            child: Icon(
                              isEnabled ? Icons.offline_bolt : Icons.language,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            languageName,
                            style: TextStyle(
                              fontWeight: isEnabled ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEnabled 
                                    ? 'Ready for offline speech recognition' 
                                    : 'Tap to enable offline recognition',
                                style: TextStyle(
                                  color: isEnabled ? Colors.green : Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              if (isCore)
                                const Text(
                                  'Core language (always available)',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                            ],
                          ),
                          value: isEnabled,
                          onChanged: isCore ? null : (value) async {
                            final success = await manager.toggleLanguage(languageCode);
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    value 
                                        ? 'Enabled $languageName for offline use'
                                        : 'Disabled $languageName',
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                        ),
                      );
                    }).toList(),

                    const SizedBox(height: 20),

                    // Test Button
                    ElevatedButton.icon(
                      onPressed: () => _testOfflineRecognition(context, manager),
                      icon: const Icon(Icons.mic_none),
                      label: const Text('Test Offline Recognition'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),

                    const SizedBox(height: 80), // Space for bottom navigation
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _testOfflineRecognition(BuildContext context, PreloadedOfflineManager manager) async {
    // Show test dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.mic, color: Colors.green),
            SizedBox(width: 8),
            Text('Testing Offline Recognition'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Testing speech recognition with enabled languages...'),
            SizedBox(height: 8),
            Text(
              'This test verifies that offline recognition is working properly.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );

    // Test enabled languages
    final enabledLanguages = manager.getEnabledLanguageCodes();
    int successCount = 0;

    for (String languageCode in enabledLanguages) {
      try {
        final success = await manager.testLanguageRecognition(languageCode);
        if (success) successCount++;
      } catch (e) {
        debugPrint('Test failed for $languageCode: $e');
      }
    }

    // Close test dialog
    Navigator.of(context).pop();

    // Show results
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              successCount > 0 ? Icons.check_circle : Icons.error,
              color: successCount > 0 ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            const Text('Test Results'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tested: ${enabledLanguages.length} languages'),
            Text('Ready: $successCount languages'),
            const SizedBox(height: 16),
            Text(
              successCount > 0
                  ? '✅ Offline speech recognition is working!'
                  : '⚠️ Speech recognition may need device setup',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: successCount > 0 ? Colors.green : Colors.orange,
              ),
            ),
            if (successCount == 0) ...[
              const SizedBox(height: 8),
              const Text(
                'Try enabling speech recognition in your device settings or grant microphone permissions.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}