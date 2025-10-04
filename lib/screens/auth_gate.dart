import 'dart:async';
import 'dart:io';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/encryption_service.dart';
import 'unlock_screen.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';
import '../memory.dart';
import '../providers/application_providers.dart';
import 'login_screen.dart';
import 'memory_edit_screen.dart';
import 'memory_view_screen.dart';
import 'select_memory_screen.dart';
import 'verify_email_screen.dart';
import '../services/notification_service.dart';
import '../widgets/lifeline_widget.dart';
import '../widgets/premium_upsell_widgets.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  StreamSubscription? _notificationSubscription;
  StreamSubscription? _sharingSubscription;

  @override
  void initState() {
    super.initState();
    unawaited(FirebaseCrashlytics.instance.log('AuthGate: initState'));
    _notificationSubscription = onNotificationTap.stream.listen((payload) {
      if (mounted) {
        _handleNotificationTap(payload);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        if (l10n != null) {
          _checkForDrafts(l10n);
        }

        if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
          _sharingSubscription =
              ReceiveSharingIntent.instance.getMediaStream().listen((value) {
            if (mounted) {
              _handleSharedFiles(value);
            }
          }, onError: (err) {
            debugPrint('getMediaStream error: $err');
          });

          ReceiveSharingIntent.instance.getInitialMedia().then((value) {
            if (mounted) {
              _handleSharedFiles(value);
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    unawaited(FirebaseCrashlytics.instance.log('AuthGate: dispose'));
    _notificationSubscription?.cancel();
    _sharingSubscription?.cancel();
    super.dispose();
  }

  Future<void> _handleSharedFiles(List<SharedMediaFile> files) async {
    if (files.isEmpty || !mounted) return;

    final authValue = ref.read(authStateChangesProvider);
    final user = authValue.asData?.value;
    if (user == null) {
      return;
    }

    // NEW: Show dialog instantly without processing
    // Processing will happen in background after user chooses action
    unawaited(ReceiveSharingIntent.instance.reset());
    _showShareActionSheet(files, user.uid);
  }

  void _showShareActionSheet(List<SharedMediaFile> files, String userId) {
    final l10n = AppLocalizations.of(context)!;
    final isPremium = ref.read(isPremiumProvider);

    // Count photos and videos
    final photoCount = files.where((f) => f.type == SharedMediaType.image).length;
    final videoCount = files.where((f) => f.type == SharedMediaType.video).length;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              Text(
                l10n.shareActionTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.shareActionSubtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              // Show instant preview with original file paths (no processing yet)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    final file = files[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 100,
                          height: 100,
                          child: file.type == SharedMediaType.image
                              ? Image.file(File(file.path), fit: BoxFit.cover)
                              : Container(
                                  color: Colors.black54,
                                  child: const Icon(Icons.videocam,
                                      color: Colors.white, size: 50),
                                ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_circle_outline),
                label: Text(l10n.shareCreateNewMemory),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  // Check premium limits BEFORE processing
                  if (!isPremium && photoCount > 3) {
                    Navigator.of(context).pop();
                    await showPremiumDialog(context, l10n.premiumFeaturePhotos);
                    return;
                  }
                  if (!isPremium && videoCount > 1) {
                    Navigator.of(context).pop();
                    await showPremiumDialog(context, l10n.premiumFeatureVideos);
                    return;
                  }

                  Navigator.of(context).pop(); // Close bottom sheet
                  // Pass raw files - processing will happen in MemoryEditScreen
                  unawaited(Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MemoryEditScreen(
                        userId: userId,
                        sharedFiles: files,
                      ),
                    ),
                  ));
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: Text(l10n.shareAddToExisting),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  foregroundColor: Colors.white,
                  side: BorderSide(
                      color: Colors.white.withAlpha((255 * 0.5).round())),
                ),
                onPressed: () async {
                  // Check premium limits BEFORE processing
                  if (!isPremium && photoCount > 3) {
                    Navigator.of(context).pop();
                    await showPremiumDialog(context, l10n.premiumFeaturePhotos);
                    return;
                  }
                  if (!isPremium && videoCount > 1) {
                    Navigator.of(context).pop();
                    await showPremiumDialog(context, l10n.premiumFeatureVideos);
                    return;
                  }

                  Navigator.of(context).pop(); // Close bottom sheet
                  // Pass raw files - processing will happen in SelectMemoryScreen
                  unawaited(Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SelectMemoryScreen(
                        sharedFiles: files,
                      ),
                    ),
                  ));
                },
              ),
            ],
          ),
          ),
        );
      },
    );
  }

  Future<void> _checkForDrafts(AppLocalizations l10n) async {
    if (!mounted) return;
    unawaited(FirebaseCrashlytics.instance.log('AuthGate: Checking for drafts.'));

    final repo = ref.read(memoryRepositoryProvider);
    if (repo == null) {
      unawaited(FirebaseCrashlytics.instance
          .log('AuthGate: Draft check aborted, repo is null.'));
      return;
    }

    final draft = await repo.findDraft();

    if (!mounted) {
      unawaited(FirebaseCrashlytics.instance
          .log('AuthGate: Unmounted after finding draft.'));
      return;
    }

    final currentAuthValue = ref.read(authStateChangesProvider);
    if (currentAuthValue.asData?.value == null) {
      unawaited(FirebaseCrashlytics.instance
          .log('AuthGate: Draft check aborted, user logged out.'));
      return;
    }

    if (draft != null) {
      unawaited(FirebaseCrashlytics.instance
          .log('AuthGate: Found draft ${draft.id}. Showing dialog.'));
      _showDraftDialog(draft, l10n);
    } else {
      unawaited(FirebaseCrashlytics.instance.log('AuthGate: No drafts found.'));
    }
  }

  void _showDraftDialog(Memory draft, AppLocalizations l10n) {
    if (!mounted) return;
    final repo = ref.read(memoryRepositoryProvider);
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
              FirebaseCrashlytics.instance
                  .log('AuthGate: Discarding draft ${draft.id}.');
              unawaited(repo?.delete(draft.id));
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: Text(l10n.authGateContinueEditing),
            onPressed: () {
              FirebaseCrashlytics.instance
                  .log('AuthGate: Continuing to edit draft ${draft.id}.');
              Navigator.of(context).pop();
              if (mounted) {
                unawaited(Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MemoryEditScreen(
                        initial: draft, userId: draft.userId!),
                  ),
                ));
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleNotificationTap(String? payload) async {
    unawaited(FirebaseCrashlytics.instance
        .log('AuthGate: Handling notification tap with payload: $payload'));
    if (!mounted || payload == null) return;

    final memoryId = int.tryParse(payload);

    final memoryRepo = ref.read(memoryRepositoryProvider);

    if (memoryId == null || memoryRepo == null) {
      unawaited(FirebaseCrashlytics.instance
          .log('AuthGate: Invalid payload or repo not ready for notification.'));
      return;
    }

    final memory = await memoryRepo.getById(memoryId);

    if (!mounted) {
      unawaited(FirebaseCrashlytics.instance
          .log('AuthGate: Unmounted after getting memory by ID.'));
      return;
    }

    if (ref.read(authStateChangesProvider).value == null) {
      unawaited(FirebaseCrashlytics.instance
          .log('AuthGate: Notification tap aborted, user logged out.'));
      return;
    }

    if (memory != null && navigatorKey.currentContext != null) {
      unawaited(FirebaseCrashlytics.instance.log(
          'AuthGate: Navigating to MemoryViewScreen for memory ${memory.id}.'));
      unawaited(Navigator.of(navigatorKey.currentContext!).push(
        MaterialPageRoute(
            builder: (_) =>
                MemoryViewScreen(memory: memory, userId: memoryRepo.userId)),
      ));
    } else {
      unawaited(FirebaseCrashlytics.instance
          .log('AuthGate: Memory with id $memoryId not found for notification.'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateChangesProvider);
    final l10n = AppLocalizations.of(context)!;

    return authState.when(
      loading: () {
        unawaited(FirebaseCrashlytics.instance.log('AuthGate: Build state is authState.loading'));
        return _LoadingScreen(message: l10n.authGateAuthenticating);
      },
      error: (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, reason: 'AuthGate: authState.error');
        return _ErrorScreen(
          l10n: l10n,
          error: error.toString(),
          onRetry: () => ref.refresh(authStateChangesProvider),
        );
      },
      data: (user) {
        if (user == null) {
          unawaited(FirebaseCrashlytics.instance.log('AuthGate: Build state is authState.data (user is null). Navigating to LoginScreen.'));
          return const LoginScreen();
        }

        final isEmailPasswordProvider = user.providerData
            .any((userInfo) => userInfo.providerId == 'password');
        if (isEmailPasswordProvider && !user.emailVerified) {
          unawaited(FirebaseCrashlytics.instance.log('AuthGate: Build state is authState.data (user not verified). Navigating to VerifyEmailScreen.'));
          return const VerifyEmailScreen();
        }

        // --- FIX for problems 1 & 3: Watch providers directly to drive the UI state ---
        final userProfileAsync = ref.watch(userProfileProvider);
        final encryptionState = ref.watch(encryptionServiceProvider);

        return userProfileAsync.when(
          loading: () => _LoadingScreen(message: l10n.authGateAuthenticating),
          error: (err, stack) => _ErrorScreen(
            l10n: l10n,
            error: err.toString(),
            onRetry: () => ref.refresh(userProfileProvider),
          ),
          data: (profile) {
            if (profile == null) {
              // This can happen briefly when a user is created but the profile isn't yet.
              // Show a loading screen while `ensureUserProfileExists` runs.
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  ref
                      .read(userServiceProvider)
                      .ensureUserProfileExists(user, context);
                }
              });
              return _LoadingScreen(message: l10n.authGateLoadingMemories);
            }

            // **CRITICAL LOGIC**: Show UnlockScreen if encryption is enabled and state is locked.
            if (profile.isEncryptionEnabled &&
                encryptionState == EncryptionState.locked) {
              return const UnlockScreen();
            }

            // If not locked, proceed to show the main app content.
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
                final onboardingState = ref.watch(onboardingServiceProvider);
                if (memories.isEmpty && !onboardingState.isActive) {
                  unawaited(FirebaseCrashlytics.instance.log(
                      'AuthGate: Build state is memoriesState.data (memories are empty).'));
                  return Scaffold(
                    body: Stack(
                      children: [
                        SafeArea(child: LifelineWidget(key: ValueKey(user.uid))),
                        _EmptyStateOverlay(l10n: l10n),
                      ],
                    ),
                  );
                }
                unawaited(FirebaseCrashlytics.instance.log(
                    'AuthGate: Build state is memoriesState.data (showing ${memories.length} memories).'));
                return Scaffold(
                  body: SafeArea(
                    child: LifelineWidget(key: ValueKey(user.uid)),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

// --- Helper Widgets ---

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
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                message,
                key: ValueKey(message),
                style:
                    TextStyle(color: Colors.white.withAlpha((255 * 0.7).round())),
              ),
            ),
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
                style:
                    TextStyle(color: Colors.white.withAlpha((255 * 0.7).round())),
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
            color: Colors.black.withAlpha((255 * 0.7).round()),
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: Colors.white.withAlpha((255 * 0.2).round())),
          ),
          child: Text(
            l10n.authGateEmptyState,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white.withAlpha((255 * 0.8).round()),
                height: 1.5),
          ),
        ),
      ),
    );
  }
}
