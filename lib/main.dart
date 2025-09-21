import 'dart:async';
import 'dart:ui';

import 'package:country_picker/country_picker.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ИМПОРТ ДЛЯ SystemChrome
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lifeline/providers/application_providers.dart';
import 'package:lifeline/screens/splash_screen.dart';
import 'package:lifeline/services/notification_service.dart';
import 'package:lifeline/widgets/device_performance_detector.dart';
import 'package:lifeline/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  await runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // ИСПРАВЛЕНИЕ (Google Play / Android 15): Включаем режим "от края до края"
    // и делаем иконки системных панелей видимыми на прозрачном фоне.
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      statusBarColor: Colors.transparent, // Это поле теперь игнорируется в edge-to-edge, но оставляем для совместимости
      systemNavigationBarIconBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ));

    final prefs = await SharedPreferences.getInstance();
    final savedLocaleCode = prefs.getString('appLocale');
    final initialLocale =
        savedLocaleCode != null ? Locale(savedLocaleCode) : null;

    await Firebase.initializeApp();
    FirebaseAnalytics.instance;
    
    await FirebaseAppCheck.instance.activate(
      androidProvider: kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
      appleProvider: kDebugMode ? AppleProvider.debug : AppleProvider.appAttest,
    );
    
    if (kDebugMode) {
      print('⚠️ App Check is using DEBUG providers.');
    } else {
      print('App Check activated with Play Integrity / App Attest.');
    }


    await NotificationService().init();
    await initializeDateFormatting('ru', null);
    await initializeDateFormatting('en', null);
    await initializeDateFormatting('de', null);
    await initializeDateFormatting('es', null);
    await initializeDateFormatting('fr', null);
    await initializeDateFormatting('he', null);
    await initializeDateFormatting('pt', null);
    await initializeDateFormatting('zh', null);

    await DevicePerformanceDetector.initialize();

    if (kIsWeb) {
       FlutterError.onError = (details) {
         FlutterError.dumpErrorToConsole(details);
       };
    } else if (kDebugMode) {
      FlutterError.onError = (details) {
        print('Flutter error: $details');
      };
      PlatformDispatcher.instance.onError = (error, stack) {
        print('Platform error: $error');
        print('Stack: $stack');
        return true;
      };
    } else {
      FlutterError.onError = (details) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      };
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    }

    runApp(
      ProviderScope(
        overrides: [
          localeProvider
              .overrideWith((ref) => LocaleNotifier(ref, initialLocale)),
        ],
        child: const LifelineApp(),
      ),
    );
  }, (error, stack) {
    if (!kDebugMode) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    } else {
      print('Caught async error in Zone: $error');
      print('Stack: $stack');
    }
  });
}

class LifelineApp extends ConsumerWidget {
  const LifelineApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFFF3B3B),
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF0D0C11),
      textTheme: GoogleFonts.orbitronTextTheme(
        ThemeData.dark().textTheme,
      ),
    );

    final locale = ref.watch(localeProvider);
    final localeToUse =
        locale ?? WidgetsBinding.instance.platformDispatcher.locale;

    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: theme,
      locale: localeToUse,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        CountryLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const SplashScreen(),
    );
  }
}

