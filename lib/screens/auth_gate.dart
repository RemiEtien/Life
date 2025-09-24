import 'dart:async';
import 'dart:io';
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
import 'package:lifeline/screens/select_memory_screen.dart';
import 'package:lifeline/screens/verify_email_screen.dart';
import 'package:lifeline/services/notification_service.dart';
import 'package:lifeline/widgets/lifeline_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

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
    FirebaseCrashlytics.instance.log('AuthGate: initState');
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
      }
    });

    _sharingSubscription =
        ReceiveSharingIntent.instance.getMediaStream().listen((List<SharedMediaFile> value) {
      if (mounted) {
        _handleSharedFiles(value);
      }
    }, onError: (err) {
      debugPrint("getMediaStream error: $err");
    });

    ReceiveSharingIntent.instance.getInitialMedia().then((List<SharedMediaFile> value) {
      if (mounted) {
        _handleSharedFiles(value);
      }
    });
  }

  @override
  void dispose() {
    FirebaseCrashlytics.instance.log('AuthGate: dispose');
    _notificationSubscription?.cancel();
    _sharingSubscription?.cancel();
    super.dispose();
  }

  Future<void> _handleSharedFiles(List<SharedMediaFile> files) async {
    if (files.isEmpty || !mounted) return;
  
    // Читаем все необходимые значения ДО асинхронных операций
    final authValue = ref.read(authStateChangesProvider);
    final user = authValue.asData?.value;
    if (user == null) {
      return;
    }
  
    final imageProcessor = ref.read(imageProcessingServiceProvider);
    final List<MediaItem> processedMedia = [];
  
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  
    for (var file in files) {
      if (file.type == SharedMediaType.image) {
        final result = await imageProcessor.processPickedImage(XFile(file.path));
        if (result != null) {
          processedMedia.add(MediaItem(
            path: result.compressedImagePath,
            thumbPath: result.thumbnailPath,
            isLocal: true,
          ));
        }
      }
       // TODO: Добавить обработку видео, если необходимо.
    }
  
    if (mounted) Navigator.of(context).pop();
  
    if (processedMedia.isNotEmpty && mounted) {
      ReceiveSharingIntent.instance.reset();
      _showShareActionSheet(processedMedia, user.uid);
    }
  }

  void _showShareActionSheet(List<MediaItem> media, String userId) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
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
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: media.length,
                  itemBuilder: (context, index) {
                    final item = media[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 100,
                          height: 100,
                          child: Image.file(File(item.thumbPath), fit: BoxFit.cover),
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
                onPressed: () {
                  Navigator.of(context).pop(); // Close bottom sheet
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MemoryEditScreen(
                        userId: userId,
                        initialMedia: media,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: Text(l10n.shareAddToExisting),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withAlpha((255 * 0.5).round())),
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Close bottom sheet
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SelectMemoryScreen(
                        mediaToAdd: media,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _checkForDrafts(AppLocalizations l10n) async {
    if (!mounted) return;
    FirebaseCrashlytics.instance.log('AuthGate: Checking for drafts.');
  
    // Читаем repo один раз
    final repo = ref.read(memoryRepositoryProvider);
    if (repo == null) {
      FirebaseCrashlytics.instance
          .log('AuthGate: Draft check aborted, repo is null.');
      return;
    }
  
    final draft = await repo.findDraft();
  
    if (!mounted) {
      FirebaseCrashlytics.instance
          .log('AuthGate: Unmounted after finding draft.');
      return;
    }
  
    // Проверяем auth state заново после асинхронной операции
    final currentAuthValue = ref.read(authStateChangesProvider);
    if (currentAuthValue.asData?.value == null) {
      FirebaseCrashlytics.instance
          .log('AuthGate: Draft check aborted, user logged out.');
      return;
    }
  
    if (draft != null) {
      FirebaseCrashlytics.instance
          .log('AuthGate: Found draft ${draft.id}. Showing dialog.');
      _showDraftDialog(draft, l10n);
    } else {
      FirebaseCrashlytics.instance.log('AuthGate: No drafts found.');
    }
  }

  void _showDraftDialog(Memory draft, AppLocalizations l10n) {
    if (!mounted) return;
    
    // Читаем repo заранее
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
              // Используем заранее прочитанный repo
              repo?.delete(draft.id);
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
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MemoryEditScreen(
                        initial: draft, userId: draft.userId!),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleNotificationTap(String? payload) async {
    FirebaseCrashlytics.instance
        .log('AuthGate: Handling notification tap with payload: $payload');
    if (!mounted || payload == null) return;

    final memoryId = int.tryParse(payload);

    final memoryRepo = ref.read(memoryRepositoryProvider);

    if (memoryId == null || memoryRepo == null) {
      FirebaseCrashlytics.instance
          .log('AuthGate: Invalid payload or repo not ready for notification.');
      return;
    }

    final memory = await memoryRepo.getById(memoryId);

    if (!mounted) {
      FirebaseCrashlytics.instance
          .log('AuthGate: Unmounted after getting memory by ID.');
      return;
    }

    if (ref.read(authStateChangesProvider).value == null) {
      FirebaseCrashlytics.instance
          .log('AuthGate: Notification tap aborted, user logged out.');
      return;
    }

    if (memory != null && navigatorKey.currentContext != null) {
      FirebaseCrashlytics.instance
          .log('AuthGate: Navigating to MemoryViewScreen for memory ${memory.id}.');
      Navigator.of(navigatorKey.currentContext!).push(
        MaterialPageRoute(
            builder: (_) =>
                MemoryViewScreen(memory: memory, userId: memoryRepo.userId)),
      );
    } else {
      FirebaseCrashlytics.instance
          .log('AuthGate: Memory with id $memoryId not found for notification.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateChangesProvider);
    final onboardingState = ref.watch(onboardingServiceProvider);
    final l10n = AppLocalizations.of(context)!;

    return authState.when(
      loading: () {
        FirebaseCrashlytics.instance
            .log('AuthGate: Build state is authState.loading');
        return _LoadingScreen(message: l10n.authGateAuthenticating);
      },
      error: (error, stack) {
        FirebaseCrashlytics.instance
            .recordError(error, stack, reason: 'AuthGate: authState.error');
        return _ErrorScreen(
          l10n: l10n,
          error: error.toString(),
          onRetry: () => ref.refresh(authStateChangesProvider),
        );
      },
      data: (user) {
        if (user == null) {
          FirebaseCrashlytics.instance.log(
              'AuthGate: Build state is authState.data (user is null). Navigating to LoginScreen.');
          return const LoginScreen();
        }

        final isEmailPasswordProvider = user.providerData
            .any((userInfo) => userInfo.providerId == 'password');
        if (isEmailPasswordProvider && !user.emailVerified) {
          FirebaseCrashlytics.instance.log(
              'AuthGate: Build state is authState.data (user not verified). Navigating to VerifyEmailScreen.');
          return const VerifyEmailScreen();
        }

        FirebaseCrashlytics.instance.log(
            'AuthGate: Build state is authState.data (user is authenticated). Watching memories...');
        final memoriesState = ref.watch(memoriesStreamProvider);
        return memoriesState.when(
          loading: () {
            FirebaseCrashlytics.instance
                .log('AuthGate: Build state is memoriesState.loading');
            return _LoadingScreen(message: l10n.authGateLoadingMemories);
          },
          error: (error, stack) {
            FirebaseCrashlytics.instance.recordError(error, stack,
                reason: 'AuthGate: memoriesState.error');
            return _ErrorScreen(
              l10n: l10n,
              error: error.toString(),
              onRetry: () => ref.refresh(memoriesStreamProvider),
            );
          },
          data: (memories) {
            if (memories.isEmpty && !onboardingState.isActive) {
              FirebaseCrashlytics.instance.log(
                  'AuthGate: Build state is memoriesState.data (memories are empty).');
              return Scaffold(
                body: Stack(
                  children: [
                    SafeArea(child: LifelineWidget(key: ValueKey(user.uid))),
                    _EmptyStateOverlay(l10n: l10n),
                  ],
                ),
              );
            }
            FirebaseCrashlytics.instance.log(
                'AuthGate: Build state is memoriesState.data (showing ${memories.length} memories).');
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
                style: TextStyle(color: Colors.white.withAlpha((255 * 0.7).round()))),
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
                style: TextStyle(color: Colors.white.withAlpha((255 * 0.7).round())),
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
            border: Border.all(color: Colors.white.withAlpha((255 * 0.2).round())),
          ),
          child: Text(
            l10n.authGateEmptyState,
            textAlign: TextAlign.center,
            style:
                TextStyle(color: Colors.white.withAlpha((255 * 0.8).round()), height: 1.5),
          ),
        ),
      ),
    );
  }
}
