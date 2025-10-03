import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';
import '../utils/constants.dart';

class SettingsPanel extends StatelessWidget {
  final VoidCallback onClose;

  const SettingsPanel({
    super.key,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsService>(
      builder: (context, settingsService, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Settings',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: onClose,
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Settings Content
              Expanded(
                child: ListView(
                  children: [
                    // Language Selection
                    _buildLanguageSection(context, settingsService),
                    
                    const SizedBox(height: 24),
                    
                    // Display Settings
                    _buildDisplaySection(context, settingsService),
                    
                    const SizedBox(height: 24),
                    
                    // ASR Engine Settings
                    _buildASRSection(context, settingsService),
                    
                    const SizedBox(height: 24),
                    
                    // Accessibility Settings
                    _buildAccessibilitySection(context, settingsService),
                    
                    const SizedBox(height: 24),
                    
                    // Advanced Settings
                    _buildAdvancedSection(context, settingsService),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageSection(BuildContext context, SettingsService settingsService) {
    return _buildSection(
      context,
      title: 'Language Settings',
      icon: Icons.language,
      children: [
        // Language Selector
        ListTile(
          title: const Text('Recognition Language'),
          subtitle: Text(AppConstants.indianLanguages[settingsService.selectedLanguage] ?? 'Unknown'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => _showLanguageSelector(context, settingsService),
        ),
      ],
    );
  }

  Widget _buildDisplaySection(BuildContext context, SettingsService settingsService) {
    return _buildSection(
      context,
      title: 'Display Settings',
      icon: Icons.display_settings,
      children: [
        // Font Size
        ListTile(
          title: const Text('Font Size'),
          subtitle: Text('${settingsService.fontSize.round()}pt'),
          trailing: SizedBox(
            width: 150,
            child: Slider(
              value: settingsService.fontSize,
              min: AppConstants.minFontSize,
              max: AppConstants.maxFontSize,
              divisions: ((AppConstants.maxFontSize - AppConstants.minFontSize) / 2).round(),
              onChanged: (value) => settingsService.updateFontSize(value),
            ),
          ),
        ),
        
        // Theme Mode
        ListTile(
          title: const Text('Theme'),
          subtitle: Text('${_getThemeModeText(settingsService.themeMode)} theme active'),
          trailing: DropdownButton<ThemeMode>(
            value: settingsService.themeMode,
            items: ThemeMode.values.map((mode) {
              return DropdownMenuItem(
                value: mode,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      mode == ThemeMode.light 
                          ? Icons.light_mode 
                          : mode == ThemeMode.dark 
                              ? Icons.dark_mode 
                              : Icons.auto_mode,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(_getThemeModeText(mode)),
                  ],
                ),
              );
            }).toList(),
            onChanged: (mode) {
              if (mode != null) {
                debugPrint('🎨 Switching theme to: ${_getThemeModeText(mode)}');
                settingsService.updateThemeMode(mode);
              }
            },
          ),
        ),
        
        // High Contrast
        SwitchListTile(
          title: const Text('High Contrast Mode'),
          subtitle: const Text('Improves visibility for users with visual impairments'),
          value: settingsService.highContrastMode,
          onChanged: (value) => settingsService.toggleHighContrast(value),
        ),
      ],
    );
  }

  Widget _buildASRSection(BuildContext context, SettingsService settingsService) {
    return _buildSection(
      context,
      title: 'Speech Recognition',
      icon: Icons.mic,
      children: [
        // ASR Engine
        ListTile(
          title: const Text('Recognition Engine'),
          subtitle: Text(_getASREngineText(settingsService.preferredASREngine)),
          trailing: DropdownButton<ASREngine>(
            value: settingsService.preferredASREngine,
            items: ASREngine.values.map((engine) {
              return DropdownMenuItem(
                value: engine,
                child: Text(_getASREngineText(engine)),
              );
            }).toList(),
            onChanged: (engine) {
              if (engine != null) {
                settingsService.updateASREngine(engine);
              }
            },
          ),
        ),
        
        // Cloud Fallback
        SwitchListTile(
          title: const Text('Cloud Fallback'),
          subtitle: const Text('Use cloud services when on-device recognition fails'),
          value: settingsService.cloudFallbackEnabled,
          onChanged: (value) => settingsService.toggleCloudFallback(value),
        ),
        
        // Offline Mode
        SwitchListTile(
          title: const Text('Offline Mode'),
          subtitle: const Text('Use only on-device processing'),
          value: settingsService.offlineMode,
          onChanged: (value) => settingsService.toggleOfflineMode(value),
        ),
      ],
    );
  }

  Widget _buildAccessibilitySection(BuildContext context, SettingsService settingsService) {
    return _buildSection(
      context,
      title: 'Accessibility',
      icon: Icons.accessibility,
      children: [
        // Pictograms
        SwitchListTile(
          title: const Text('Show Pictograms'),
          subtitle: const Text('Add visual symbols to help with comprehension'),
          value: settingsService.pictogramsEnabled,
          onChanged: (value) => settingsService.togglePictograms(value),
        ),
        
        // Text Simplification
        SwitchListTile(
          title: const Text('Simplify Text'),
          subtitle: const Text('Convert complex sentences to simpler language'),
          value: settingsService.simplificationEnabled,
          onChanged: (value) => settingsService.toggleSimplification(value),
        ),
      ],
    );
  }

  Widget _buildAdvancedSection(BuildContext context, SettingsService settingsService) {
    return _buildSection(
      context,
      title: 'Advanced',
      icon: Icons.settings,
      children: [
        // Reset Settings
        ListTile(
          title: const Text('Reset to Defaults'),
          subtitle: const Text('Restore all settings to their default values'),
          trailing: const Icon(Icons.restore),
          onTap: () => _showResetDialog(context, settingsService),
        ),
        
        // Export Settings
        ListTile(
          title: const Text('Export Settings'),
          subtitle: const Text('Save current settings to file'),
          trailing: const Icon(Icons.file_upload),
          onTap: () => _exportSettings(context, settingsService),
        ),
        
        // Import Settings
        ListTile(
          title: const Text('Import Settings'),
          subtitle: const Text('Load settings from file'),
          trailing: const Icon(Icons.file_download),
          onTap: () => _importSettings(context, settingsService),
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  void _showLanguageSelector(BuildContext context, SettingsService settingsService) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: AppConstants.indianLanguages.length,
              itemBuilder: (context, index) {
                final languageCode = AppConstants.indianLanguages.keys.elementAt(index);
                final languageName = AppConstants.indianLanguages[languageCode]!;
                final isSelected = languageCode == settingsService.selectedLanguage;
                
                return ListTile(
                  title: Text(languageName),
                  trailing: isSelected ? const Icon(Icons.check) : null,
                  onTap: () {
                    settingsService.updateLanguage(languageCode);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showResetDialog(BuildContext context, SettingsService settingsService) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset Settings'),
          content: const Text('Are you sure you want to reset all settings to their default values?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                settingsService.resetToDefaults();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings reset to defaults')),
                );
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  void _exportSettings(BuildContext context, SettingsService settingsService) {
    // Implementation for exporting settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export settings feature coming soon')),
    );
  }

  void _importSettings(BuildContext context, SettingsService settingsService) {
    // Implementation for importing settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Import settings feature coming soon')),
    );
  }

  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  String _getASREngineText(ASREngine engine) {
    switch (engine) {
      case ASREngine.onDevice:
        return 'On-Device';
      case ASREngine.googleCloud:
        return 'Google Cloud';
      case ASREngine.azureSpeech:
        return 'Azure Speech';
    }
  }
}