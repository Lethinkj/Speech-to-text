import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/home_screen.dart';
import 'services/speech_service.dart';
import 'services/translation_service.dart';
import 'services/database_service.dart';
import 'services/settings_service.dart';
import 'services/preloaded_offline_manager.dart';
import 'models/caption_model.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  
  // Register Hive adapters
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(CaptionModelAdapter());
  }
  
  // Initialize services
  try {
    // Initialize settings service first for theme
    final settingsService = SettingsService();
    await settingsService.initialize();
    debugPrint('🎨 Settings initialized with theme: ${settingsService.themeMode}');
    
    if (!kIsWeb) {
      await DatabaseService().initialize();
      // Initialize offline language manager
      await PreloadedOfflineManager().initialize();
    }
  } catch (e) {
    debugPrint('Service initialization error: $e');
  }
  
  runApp(const DeafCaptioningApp());
}

class DeafCaptioningApp extends StatelessWidget {
  const DeafCaptioningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SpeechService()),
        ChangeNotifierProvider(create: (_) => TranslationService()),
        ChangeNotifierProvider(create: (_) => SettingsService()),
        ChangeNotifierProvider(create: (_) => PreloadedOfflineManager()),
      ],
      child: Consumer<SettingsService>(
        builder: (context, settingsService, child) {
          return GetMaterialApp(
            title: 'Captoniner',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsService.themeMode,
            home: const HomeScreen(),
            debugShowCheckedModeBanner: false,
            // Accessibility configuration
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(MediaQuery.of(context).textScaleFactor.clamp(1.0, 2.0)),
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}