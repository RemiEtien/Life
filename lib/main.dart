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
import 'services/notification_service.dart';
import 'widgets/device_performance_detector.dart';
import 'l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  await runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Enable edge-to-edge display mode (Android 15+ compatible)
    // System bar styling is handled by Android themes (values/styles.xml, values-v35/styles.xml)
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    final prefs = await SharedPreferences.getInstance();
    final savedLocaleCode = prefs.getString('appLocale');
    final initialLocale =
        savedLocaleCode != null ? Locale(savedLocaleCode) : null;

    await Firebase.initializeApp();
    FirebaseAnalytics.instance;

    await FirebaseAppCheck.instance.activate(
      androidProvider:
          kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
      appleProvider:
          kDebugMode ? AppleProvider.debug : AppleProvider.appAttest,
    );

    if (kDebugMode) {
      debugPrint('✅ App Check is using DEBUG provider');
    } else {
      debugPrint('✅ App Check activated with Play Integrity / App Attest');
    }

    // Initialize critical date formatting for default locale only
    // Other locales will be lazy-loaded when needed
    await initializeDateFormatting('en', null);

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

class _LifelineAppState extends ConsumerState<LifelineApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Defer heavy initialization until after first frame to avoid ANR
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeHeavyServices();
    });
  }

  Future<void> _initializeHeavyServices() async {
    try {
      // Initialize in parallel for faster startup
      await Future.wait([
        NotificationService().init(),
        DevicePerformanceDetector.initialize(),
        _initializeAllLocaleDateFormats(),
      ]);

      if (kDebugMode) {
        debugPrint('✅ Heavy services initialized successfully');
      }
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('❌ Error initializing heavy services: $e');
        debugPrint('Stack: $stack');
      }
      // Log to Crashlytics in production
      if (!kDebugMode) {
        unawaited(FirebaseCrashlytics.instance.recordError(
          e,
          stack,
          reason: 'Failed to initialize heavy services',
        ));
      }
    }
  }

  Future<void> _initializeAllLocaleDateFormats() async {
    // Initialize all supported locales in parallel
    await Future.wait([
      initializeDateFormatting('ru', null),
      initializeDateFormatting('de', null),
      initializeDateFormatting('es', null),
      initializeDateFormatting('fr', null),
      initializeDateFormatting('he', null),
      initializeDateFormatting('pt', null),
      initializeDateFormatting('zh', null),
      initializeDateFormatting('ar', null),
    ]);
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

    // FIX: Removed auto-lock on app lifecycle events (paused/inactive/detached)
    // Reason: Users reported excessive unlock screens when switching apps or sharing from gallery
    // Encryption service now remains unlocked during app session
    // Lock only occurs on:
    // 1. Cold start (initial app launch)
    // 2. Profile entry (navigating to profile screen)
    // 3. Per-memory unlock (if requireBiometricForMemory is enabled)

    if (kDebugMode) {
      debugPrint('[AppLifecycle] State changed to: $state (auto-lock disabled)');
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

