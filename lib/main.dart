import 'dart:async';
import 'dart:ui';

import 'package:country_picker/country_picker.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'providers/application_providers.dart';
import 'screens/splash_screen.dart';
import 'services/encryption_service.dart';
import 'services/notification_service.dart';
import 'widgets/device_performance_detector.dart';
import 'l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  await runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // ИСПРАВЛЕНИЕ: Современная настройка Edge-to-Edge без устаревших API
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
    // ИСПРАВЛЕНИЕ: Убираем statusBarColor и systemNavigationBarColor 
    // для избежания вызова устаревших API в Android 15+
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      // Не устанавливаем statusBarColor и systemNavigationBarColor
      // чтобы избежать вызова Window.setStatusBarColor()
      systemNavigationBarIconBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Colors.transparent,
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
       debugPrint('⚠️ App Check is using DEBUG providers.');
    } else {
      debugPrint('App Check activated with Play Integrity / App Attest.');
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
    await initializeDateFormatting('ar', null);

    await DevicePerformanceDetector.initialize();

    if (kIsWeb) {
       FlutterError.onError = (details) {
         FlutterError.dumpErrorToConsole(details);
       };
    } else if (kDebugMode) {
      FlutterError.onError = (details) {
        debugPrint('Flutter error: $details');
      };
      PlatformDispatcher.instance.onError = (error, stack) {
        debugPrint('Platform error: $error');
        debugPrint('Stack: $stack');
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
      debugPrint('Caught async error in Zone: $error');
      debugPrint('Stack: $stack');
    }
  });
}

class LifelineApp extends ConsumerStatefulWidget {
  const LifelineApp({super.key});

  @override
  ConsumerState<LifelineApp> createState() => _LifelineAppState();
}

class _LifelineAppState extends ConsumerState<LifelineApp> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (!mounted) return;
    
    // *** КЛЮЧЕВОЕ ИСПРАВЛЕНИЕ: Блокируем сессию шифрования при сворачивании или закрытии приложения ***
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      ref.read(encryptionServiceProvider.notifier).lockSession();
      ref.read(audioPlayerProvider.notifier).pauseAllAudio();
    }
  }

  @override
  Widget build(BuildContext context) {
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

