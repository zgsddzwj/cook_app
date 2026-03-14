import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:snap_cook/l10n/generated/app_localizations.dart';
import 'core/app_theme.dart';
import 'core/recognition_service.dart';
import 'models/ingredient.dart' as models;
import 'pages/main_screen.dart';
import 'core/pantry_provider.dart';
import 'core/navigation_provider.dart';
import 'core/recipes_provider.dart';
import 'core/diet_preferences_provider.dart';
import 'core/scan_history_provider.dart';
import 'core/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
  // Initialize recognition service
  await RecognitionService.initialize();
  // Configure cloud recognizer (CloseAI)
  RecognitionService.cloudRecognizer = models.LLMService.recognizeIngredients;
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PantryProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => RecipesProvider()),
        ChangeNotifierProvider(create: (_) => DietPreferencesProvider()),
        ChangeNotifierProvider(create: (_) => ScanHistoryProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const SnapCook(),
    ),
  );
}

class SnapCook extends StatelessWidget {
  const SnapCook({super.key});

  @override
  Widget build(BuildContext context) {
    // Set custom error widget to avoid red screen for image loading errors
    ErrorWidget.builder = (FlutterErrorDetails details) {
      // Check if it's an image loading error
      if (details.exception is Exception &&
          details.exception.toString().contains('image')) {
        return const SizedBox.shrink(); // Hide image loading errors silently
      }
      // For other errors, show default error widget in debug mode
      return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(16),
        child: const Icon(Icons.error_outline, color: Colors.grey),
      );
    };

    return MaterialApp(
      title: 'SnapCook',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'), // Force English as default
      home: const MainScreen(),
    );
  }
}
