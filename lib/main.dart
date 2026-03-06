import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cook_app/l10n/generated/app_localizations.dart';
import 'core/app_theme.dart';
import 'pages/main_screen.dart';
import 'core/pantry_provider.dart';
import 'core/navigation_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PantryProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ],
      child: const CookApp(),
    ),
  );
}

class CookApp extends StatelessWidget {
  const CookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CookApp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const MainScreen(),
    );
  }
}
