import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifeline/l10n/app_localizations.dart';
import 'package:lifeline/providers/application_providers.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  bool _canResendEmail = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _sendVerificationEmail(); // Отправляем письмо при первом входе на экран

    // Таймер для периодической проверки статуса верификации
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      // Обязательно перезагружаем состояние пользователя
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;
      if (user?.emailVerified ?? false) {
        timer.cancel();
        // AuthGate автоматически перестроит UI, когда authStateChangesProvider получит обновленного пользователя
      }
    });

    // Таймер, разрешающий повторную отправку письма через 30 секунд
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        setState(() {
          _canResendEmail = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _sendVerificationEmail() async {
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
    } catch (e) {
      // Можно добавить обработку ошибок, например, показать SnackBar
    }
  }

  Future<void> _resendVerificationEmail() async {
    setState(() {
      _canResendEmail = false;
    });
    await _sendVerificationEmail();
    // Снова запускаем таймер на 30 секунд
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        setState(() {
          _canResendEmail = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userEmail = FirebaseAuth.instance.currentUser?.email ?? 'your email';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.verifyEmailTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.verifyEmailSentTo,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              userEmail,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.verifyEmailInstructions,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.email_outlined),
              label: Text(l10n.verifyEmailResendButton),
              onPressed: _canResendEmail ? _resendVerificationEmail : null,
            ),
            TextButton(
              onPressed: () {
                ref.read(authServiceProvider).signOut();
              },
              child: Text(
                l10n.verifyEmailCancelButton,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

