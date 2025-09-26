import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifeline/l10n/app_localizations.dart';
import 'package:lifeline/providers/application_providers.dart';
import 'package:lifeline/screens/auth_gate.dart';
import 'package:lifeline/screens/legal/document_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConsentScreen extends ConsumerStatefulWidget {
  const ConsentScreen({super.key});

  @override
  ConsumerState<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends ConsumerState<ConsentScreen> {
  bool _agreedToTerms = false;
  bool _isLoading = false;

  void _log(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }

  void _onContinue() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_agreedToTerms) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasConsented', true);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AuthGate()),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.consentErrorSaving(e.toString()))),
        );
      }
    }
  }

  void _openDocument(String title, String path, String languageCode) async {
    _log('=== DOCUMENT DEBUG START ===');
    _log('Title: $title');
    _log('Original path: $path');
    _log('Language code: $languageCode');

    String finalPath = path;
    bool fileExists = false;

    try {
      _log('Trying to load: $path');
      await rootBundle.load(path);
      fileExists = true;
      _log('SUCCESS: File found at $path');
    } catch (e) {
      _log('FAILED: File not found at $path, error: $e');
    }

    if (!fileExists) {
      finalPath = path.replaceAll(RegExp(r'_[a-z]{2}\.md$'), '_en.md');
      _log('Trying fallback: $finalPath');
      try {
        await rootBundle.load(finalPath);
        fileExists = true;
        _log('SUCCESS: Fallback file found at $finalPath');
      } catch (e) {
        _log('FAILED: Fallback also failed at $finalPath, error: $e');
      }
    }

    _log('Final result - fileExists: $fileExists, finalPath: $finalPath');
    _log('=== DOCUMENT DEBUG END ===');

    if (!fileExists) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(AppLocalizations.of(context)!.documentErrorLoading)),
        );
      }
      return;
    }

    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DocumentScreen(title: title, documentPath: finalPath),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider) ?? Localizations.localeOf(context);
    final languageCode = locale.languageCode;

    _log('Current locale: $locale');
    _log('Language code: $languageCode');

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Image.asset('assets/logo.png', height: 80),
              const SizedBox(height: 16),
              Text(
                l10n.consentWelcomeTitle,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.consentWelcomeSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
              ),
              const Spacer(),
              CheckboxListTile(
                title: Text.rich(
                  TextSpan(
                    text: l10n.consentIAgreeTo,
                    style: const TextStyle(color: Colors.white),
                    children: [
                      TextSpan(
                        text: l10n.consentTermsOfService,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => _openDocument(
                                l10n.consentTermsOfService,
                                'assets/legal/terms_of_service_$languageCode.md',
                                languageCode,
                              ),
                      ),
                      TextSpan(text: l10n.consentAnd),
                      TextSpan(
                        text: l10n.consentPrivacyPolicy,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => _openDocument(
                                l10n.consentPrivacyPolicy,
                                'assets/legal/privacy_policy_$languageCode.md',
                                languageCode,
                              ),
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
                value: _agreedToTerms,
                onChanged: (bool? value) {
                  setState(() {
                    _agreedToTerms = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _agreedToTerms ? _onContinue : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        disabledBackgroundColor: Colors.grey.shade800,
                      ),
                      child: Text(
                        l10n.consentContinue,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
