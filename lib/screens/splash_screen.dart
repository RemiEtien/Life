import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:lifeline/l10n/app_localizations.dart';
import 'package:lifeline/providers/application_providers.dart';
import 'package:lifeline/screens/auth_gate.dart';
import 'package:lifeline/screens/legal/consent_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  late AudioPlayer _audioPlayer;
  String _statusMessage = "";

  @override
  void initState() {
    super.initState();
    // BREADCRUMB: Log when this widget is created.
    FirebaseCrashlytics.instance.log('SplashScreen: initState');
    _audioPlayer = AudioPlayer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        if (ref.read(localeProvider) == null) {
          final currentLocale = Localizations.localeOf(context);
          ref.read(localeProvider.notifier).setLocale(currentLocale);
        }

        final l10n = AppLocalizations.of(context);
        if (l10n != null) {
          setState(() {
            _statusMessage = l10n.splashMessageInitializing;
          });
          _startSequence(l10n);
        }
      }
    });
  }

  Future<void> _startSequence(AppLocalizations l10n) async {
    FirebaseCrashlytics.instance.log('SplashScreen: Starting sequence.');
    try {
      _audioPlayer.play(AssetSource('sounds/intro_phrase.mp3'));
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Could not play intro sound: $e");
      }
    }

    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) {
      FirebaseCrashlytics.instance.log('SplashScreen: Unmounted after 3s sound delay.');
      return;
    }

    FirebaseCrashlytics.instance.log('SplashScreen: Checking consent.');
    if (mounted) {
      setState(() => _statusMessage = l10n.splashMessageCheckingSettings);
    }
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) {
      FirebaseCrashlytics.instance.log('SplashScreen: Unmounted after getting SharedPreferences.');
      return;
    }

    await prefs.reload();
    final bool hasConsented = prefs.getBool('hasConsented') ?? false;

    if (!mounted) {
      FirebaseCrashlytics.instance.log('SplashScreen: Unmounted after checking consent.');
      return;
    }

    if (!hasConsented) {
      FirebaseCrashlytics.instance.log('SplashScreen: No consent. Navigating to ConsentScreen.');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ConsentScreen()),
      );
      return;
    }

    FirebaseCrashlytics.instance.log('SplashScreen: Consent found. Awaiting first auth state.');
    if (mounted) {
      setState(() => _statusMessage = l10n.splashMessageAuthenticating);
    }
    
    // Using ref.read for one-time read
    final user = await ref.read(authStateChangesProvider.future);
    if (!mounted) {
      FirebaseCrashlytics.instance.log('SplashScreen: Unmounted after awaiting auth state.');
      return;
    }

    if (user == null) {
      FirebaseCrashlytics.instance.log('SplashScreen: User is null. Navigating to AuthGate (Login).');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthGate()),
      );
      return;
    }

    FirebaseCrashlytics.instance.log('SplashScreen: User found. Syncing locale with profile.');
    await ref.read(localeProvider.notifier).syncLocaleWithUserProfile();
    if (!mounted) {
      FirebaseCrashlytics.instance.log('SplashScreen: Unmounted after syncing locale.');
      return;
    }

    if (mounted) {
      setState(() => _statusMessage = l10n.splashMessageSyncing);
    }
    
    // ИЗМЕНЕНО: Мы дожидаемся завершения первой синхронизации ЗДЕСЬ,
    // чтобы гарантировать, что локальная база данных актуальна перед показом UI.
    FirebaseCrashlytics.instance.log('SplashScreen: Starting initial sync from cloud.');
    try {
      await ref.read(syncServiceProvider).syncFromCloudToLocal(isInitialSync: true);
    } catch (e, stack) {
      if (kDebugMode) {
        print("[SplashScreen] Initial sync failed, proceeding with local data. Error: $e");
      }
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Initial sync failed on SplashScreen');
    }

    if (!mounted) {
      FirebaseCrashlytics.instance.log('SplashScreen: Unmounted before final navigation.');
      return;
    }

    FirebaseCrashlytics.instance.log('SplashScreen: Sequence complete. Navigating to AuthGate (Main).');
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AuthGate()),
    );
  }

  @override
  void dispose() {
    // BREADCRUMB: Log when this widget is destroyed.
    FirebaseCrashlytics.instance.log('SplashScreen: dispose');
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              width: 300,
              height: 300,
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 20),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _statusMessage,
                key: ValueKey(_statusMessage),
                style: TextStyle(color: Colors.white.withAlpha((255 * 0.7).round())),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
