import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/offline_language_manager.dart';

class OfflineLanguagePanel extends StatefulWidget {
  final VoidCallback? onClose;

  const OfflineLanguagePanel({
    super.key,
    this.onClose,
  });

  @override
  State<OfflineLanguagePanel> createState() => _OfflineLanguagePanelState();
}

class _OfflineLanguagePanelState extends State<OfflineLanguagePanel> {
  late OfflineLanguageManager _languageManager;

  @override
  void initState() {
    super.initState();
    _languageManager = OfflineLanguageManager();
    _initializeManager();
  }

  Future<void> _initializeManager() async {
    await _languageManager.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _languageManager,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.offline_bolt, color: Colors.white),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Offline Languages',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: widget.onClose,
                  ),
                ],
              ),
            ),

            // Storage info
            Consumer<OfflineLanguageManager>(
              builder: (context, manager, child) {
                final storageUsed = manager.getTotalStorageUsed();
                final downloadedCount = manager.getDownloadedLanguageCodes().length;
                
                return Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
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
                              '$downloadedCount languages downloaded',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            Text(
                              '${storageUsed.toStringAsFixed(1)} MB used',
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
                          await manager.downloadAllCoreLanguages();
                        },
                        child: const Text('Download Core'),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Language list
            Expanded(
              child: Consumer<OfflineLanguageManager>(
                builder: (context, manager, child) {
                  final languageCodes = manager.getAvailableLanguageCodes();
                  
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: languageCodes.length,
                    itemBuilder: (context, index) {
                      final languageCode = languageCodes[index];
                      final languageName = manager.getLanguageName(languageCode);
                      final isDownloaded = manager.isLanguageDownloaded(languageCode);
                      final downloadProgress = manager.getDownloadProgress(languageCode);
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isDownloaded 
                                ? Colors.green 
                                : Colors.grey.shade300,
                            child: Icon(
                              isDownloaded 
                                  ? Icons.offline_bolt 
                                  : Icons.cloud_download,
                              color: isDownloaded 
                                  ? Colors.white 
                                  : Colors.grey.shade600,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            languageName,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: isDownloaded
                              ? const Text(
                                  'Ready for offline speech recognition',
                                  style: TextStyle(color: Colors.green),
                                )
                              : downloadProgress > 0
                                  ? Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Checking device... ${(downloadProgress * 100).toInt()}%'),
                                        const SizedBox(height: 4),
                                        LinearProgressIndicator(value: downloadProgress),
                                      ],
                                    )
                                  : const Text('Tap to check availability'),
                          trailing: isDownloaded
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                                      onPressed: () => _showOfflineInfo(context, languageCode, languageName),
                                      tooltip: 'Offline info',
                                    ),
                                    if (languageCode != 'hi-IN' && languageCode != 'en-US')
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline),
                                        onPressed: () async {
                                        final result = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Remove Language'),
                                            content: Text(
                                              'Remove $languageName from offline storage?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, false),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, true),
                                                child: const Text('Remove'),
                                              ),
                                            ],
                                          ),
                                        );
                                        
                                        if (result == true) {
                                          await manager.removeLanguage(languageCode);
                                        }
                                        },
                                      )
                                    else
                                      const Icon(
                                        Icons.lock,
                                        color: Colors.grey,
                                        size: 20,
                                      ),
                                  ],
                                )
                              : downloadProgress > 0
                                  ? const SizedBox(width: 48) // Space for progress
                                  : null,
                          onTap: isDownloaded || downloadProgress > 0
                              ? null
                              : () async {
                                  await manager.downloadLanguage(languageCode);
                                },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOfflineInfo(BuildContext context, String languageCode, String languageName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.offline_bolt, color: Colors.green),
            const SizedBox(width: 8),
            Text('Offline Speech Recognition'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Language: $languageName',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'How it works:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('• Speech recognition happens on your device'),
            const Text('• No internet connection required'),
            const Text('• Your voice data stays private'),
            const Text('• May require device language models'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Note:',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700),
                  ),
                  const SizedBox(height: 4),
                  const Text('If offline recognition doesn\'t work, your device may not have this language model installed. You can download language models from your device\'s speech recognition settings.'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}