import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifeline/l10n/app_localizations.dart';
import 'package:lifeline/main.dart';
import 'package:lifeline/memory.dart';
import 'package:lifeline/providers/application_providers.dart';
import 'package:lifeline/screens/login_screen.dart';
import 'package:lifeline/screens/memory_edit_screen.dart';
import 'package:lifeline/screens/memory_view_screen.dart';
import 'package:lifeline/screens/verify_email_screen.dart';
import 'package:lifeline/services/memory_repository.dart';
import 'package:lifeline/services/notification_service.dart';
import 'package:lifeline/widgets/lifeline_widget.dart';

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  StreamSubscription? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    _notificationSubscription = onNotificationTap.stream.listen((payload) {
      // Add mounted check before handling tap
      if (mounted) {
        _handleNotificationTap(payload);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkForDrafts();
      }
    });
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  void _checkForDrafts() async {
    // Check if the widget is still mounted before proceeding.
    if (!mounted) return;
    final repo = ref.read(memoryRepositoryProvider);

    // This delay can be risky, so another mounted check is good practice.
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) {
      FirebaseCrashlytics.instance
          .log('AuthGate: Unmounted after 500ms delay in _checkForDrafts.');
      return;
    }

    if (repo != null) {
      final draft = await repo.findDraft();
      // Crucial check after the await call for findDraft.
      if (!mounted) {
        FirebaseCrashlytics.instance
            .log('AuthGate: Unmounted after finding draft in _checkForDrafts.');
        return;
      }
      if (draft != null) {
        final l10n = AppLocalizations.of(context);
        if (l10n != null) {
          _showDraftDialog(draft, l10n);
        }
      }
    }
  }

  void _showDraftDialog(Memory draft, AppLocalizations l10n) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(l10n.authGateUnsavedDraftTitle),
        content: Text(l10n.authGateUnsavedDraftContent),
        actions: [
          TextButton(
            child: Text(l10n.authGateDiscard,
                style: const TextStyle(color: Colors.redAccent)),
            onPressed: () {
              // It's safe to use ref here as it's not in an async gap.
              ref.read(memoryRepositoryProvider)?.delete(draft.id);
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: Text(l10n.authGateContinueEditing),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      MemoryEditScreen(initial: draft, userId: draft.userId!),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleNotificationTap(String? payload) async {
    if (!mounted || payload == null) return;

    final memoryId = int.tryParse(payload);

    // Add another mounted check here for safety, though less critical.
    if (!mounted) return;

    final memoryRepo = ref.read(memoryRepositoryProvider);

    if (memoryId == null || memoryRepo == null) return;

    final memory = await memoryRepo.getById(memoryId);

    // Crucial check after awaiting the memory from the repository.
    if (!mounted) {
      FirebaseCrashlytics.instance.log(
          'AuthGate: Unmounted after getting memory by ID in _handleNotificationTap.');
      return;
    }

    if (memory != null && navigatorKey.currentContext != null) {
      Navigator.of(navigatorKey.currentContext!).push(
        MaterialPageRoute(
            builder: (_) =>
                MemoryViewScreen(memory: memory, userId: memoryRepo.userId)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateChangesProvider);
    final l10n = AppLocalizations.of(context)!;

    return authState.when(
      loading: () => _LoadingScreen(message: l10n.authGateAuthenticating),
      error: (error, stack) => _ErrorScreen(
        l10n: l10n,
        error: error.toString(),
        onRetry: () => ref.refresh(authStateChangesProvider),
      ),
      data: (user) {
        if (user == null) {
          return const LoginScreen();
        }

        final isEmailPasswordProvider =
            user.providerData.any((userInfo) => userInfo.providerId == 'password');
        if (isEmailPasswordProvider && !user.emailVerified) {
          return const VerifyEmailScreen();
        }

        final memoriesState = ref.watch(memoriesStreamProvider);
        return memoriesState.when(
          loading: () =>
              _LoadingScreen(message: l10n.authGateLoadingMemories),
          error: (error, stack) => _ErrorScreen(
            l10n: l10n,
            error: error.toString(),
            onRetry: () => ref.refresh(memoriesStreamProvider),
          ),
          data: (memories) {
            if (memories.isEmpty) {
              return Scaffold(
                body: Stack(
                  children: [
                    SafeArea(child: LifelineWidget(key: ValueKey(user.uid))),
                    _EmptyStateOverlay(l10n: l10n),
                  ],
                ),
              );
            }

            return Scaffold(
              body: SafeArea(
                child: LifelineWidget(key: ValueKey(user.uid)),
              ),
            );
          },
        );
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  final String message;
  const _LoadingScreen({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0C11),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', width: 120, height: 120),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.white),
            ),
            const SizedBox(height: 20),
            Text(message,
                style: TextStyle(color: Colors.white.withOpacity(0.7))),
          ],
        ),
      ),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  final AppLocalizations l10n;

  const _ErrorScreen(
      {required this.error, required this.onRetry, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0C11),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline,
                  color: Colors.redAccent.shade100, size: 60),
              const SizedBox(height: 20),
              Text(
                l10n.authGateSomethingWentWrong,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.authGateCouldNotLoad,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: Text(l10n.authGateTryAgain),
                onPressed: onRetry,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyStateOverlay extends StatelessWidget {
  final AppLocalizations l10n;
  const _EmptyStateOverlay({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 100,
      left: 20,
      right: 20,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Text(
            l10n.authGateEmptyState,
            textAlign: TextAlign.center,
            style:
                TextStyle(color: Colors.white.withOpacity(0.8), height: 1.5),
          ),
        ),
      ),
    );
  }
}

