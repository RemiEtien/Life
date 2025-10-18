import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/anchors/anchor_models.dart';
import '../models/user_profile.dart';
import '../memory.dart';
import '../services/audio_service.dart';
import '../services/auth_service.dart';
import '../services/biometric_service.dart';
import '../services/encryption_service.dart';
import '../services/export_service.dart';
import '../services/firestore_service.dart';
import '../services/historical_data_service.dart';
import '../services/image_processing_service.dart';
import '../services/memory_repository.dart';
import '../services/notification_service.dart';
import '../services/onboarding_service.dart';
import '../services/purchase_service.dart';
import '../services/spotify_service.dart';
import '../services/sync_service.dart';
import '../services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 0. Provider to track network state
final connectivityStreamProvider =
    StreamProvider.autoDispose<List<ConnectivityResult>>((ref) {
  final stream = Connectivity().onConnectivityChanged;
  return stream.handleError((error) {
    debugPrint('Connectivity error: $error');
    return <ConnectivityResult>[ConnectivityResult.none];
  });
});

// 1. Service providers (simple)
final firestoreServiceProvider = Provider((ref) => FirestoreService(ref));
final notificationServiceProvider = Provider((ref) => NotificationService());
final exportServiceProvider = Provider((ref) => ExportService());
final biometricServiceProvider = Provider((ref) => BiometricService());

final imageProcessingServiceProvider = Provider((ref) => ImageProcessingService());

final historicalDataServiceProvider = Provider<HistoricalDataService>((ref) {
  final spotifyService = ref.watch(spotifyServiceProvider);
  return HistoricalDataService(spotifyService);
});

final firebaseFunctionsProvider = Provider<FirebaseFunctions>((ref) {
  return FirebaseFunctions.instanceFor(region: 'us-central1');
});

final spotifyServiceProvider = Provider<SpotifyService>((ref) {
  final functions = ref.watch(firebaseFunctionsProvider);
  return SpotifyService(functions);
});

final purchaseServiceProvider =
    StateNotifierProvider<PurchaseService, PurchaseState>((ref) {
  return PurchaseService(ref);
});

// 1.5. User Service and Auth Service that depend on Ref
final userServiceProvider = Provider((ref) => UserService(ref));
final authServiceProvider = Provider((ref) {
  final authService = AuthService(ref);
  ref.onDispose(() {
    authService.dispose();
  });
  return authService;
});

// 1.6. Sync Service Provider (depends on other providers)
final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(ref);
});

// --- ENCRYPTION PROVIDER ---
final encryptionServiceProvider =
    StateNotifierProvider<EncryptionService, EncryptionState>((ref) {
  return EncryptionService(ref);
});

// --- ONBOARDING PROVIDER ---
final onboardingServiceProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  return OnboardingNotifier();
});

// 2. Authentication state provider
final authStateChangesProvider = StreamProvider.autoDispose<User?>((ref) {
  final authService = ref.watch(authServiceProvider);

  return authService.authStateChanges.handleError((error) {
    debugPrint('Auth state error: $error');
    return null;
  });
});

// 3. User-dependent providers
final memoryRepositoryProvider = Provider.autoDispose<MemoryRepository?>((ref) {
  final user = ref.watch(authStateChangesProvider).asData?.value;
  if (user != null) {
    final encryptionService = ref.watch(encryptionServiceProvider.notifier);
    
    final link = ref.keepAlive();
    Timer? timer;
    ref.onDispose(() {
        timer?.cancel();
    });
    ref.onCancel(() {
       timer = Timer(const Duration(seconds: 10), () {
          link.close();
       });
    });

    return MemoryRepository(
        userId: user.uid, encryptionService: encryptionService);
  }
  return null;
});

final userProfileProvider = StreamProvider.autoDispose<UserProfile?>((ref) {
  final user = ref.watch(authStateChangesProvider).asData?.value;
  if (user != null) {
    ref.keepAlive();
    return ref.watch(userServiceProvider).getUserProfileStream(user.uid);
  }
  return Stream.value(null);
});

final isPremiumProvider = Provider<bool>((ref) {
  final profile = ref.watch(userProfileProvider).asData?.value;
  if (profile == null) return false;

  if (profile.trialStartedAt != null && !profile.isPremium) {
    if (DateTime.now().difference(profile.trialStartedAt!).inDays < 7) {
      return true;
    }
  }

  if (profile.isPremium && profile.premiumUntil != null) {
    return profile.premiumUntil!.isAfter(DateTime.now());
  }

  return false;
});

// 4. Memories stream provider
final memoriesStreamProvider = StreamProvider.autoDispose<List<Memory>>((ref) {
  final memoryRepo = ref.watch(memoryRepositoryProvider);
  if (memoryRepo != null) {
    final link = ref.keepAlive();
    Timer? timer;
     ref.onDispose(() {
        timer?.cancel();
    });
    ref.onCancel(() {
       timer = Timer(const Duration(seconds: 10), () {
          link.close();
       });
    });
    return memoryRepo.watchAllSortedByDate();
  }
  return Stream.value([]);
});

// 4.1. Drafts stream provider - watches all draft memories
final draftsStreamProvider = StreamProvider.autoDispose<List<Memory>>((ref) {
  final memoryRepo = ref.watch(memoryRepositoryProvider);
  if (memoryRepo != null) {
    final link = ref.keepAlive();
    Timer? timer;
    ref.onDispose(() {
      timer?.cancel();
    });
    ref.onCancel(() {
      timer = Timer(const Duration(seconds: 10), () {
        link.close();
      });
    });
    return memoryRepo.watchAllDrafts();
  }
  return Stream.value([]);
});

// 5. Provider for synchronization management
class SyncNotifier extends StateNotifier<SyncState> {
  SyncNotifier() : super(const SyncState());

  void updateState({
    int? pendingJobs,
    bool? isSyncing,
    String? currentStatus,
    double? progress,
  }) {
    state = state.copyWith(
      pendingJobs: pendingJobs,
      isSyncing: isSyncing,
      currentStatus: currentStatus,
      progress: progress,
    );
  }
}

final syncNotifierProvider =
    StateNotifierProvider<SyncNotifier, SyncState>(
  (ref) => SyncNotifier(),
);

// 6. Async providers for data with parameters
final spotifyTrackDetailsProvider =
    FutureProvider.autoDispose.family<SpotifyTrackDetails?, String>(
  (ref, trackId) async {
    return ref.watch(spotifyServiceProvider).getTrackDetails(trackId);
  },
);

class AnchorProviderArgs {
  final DateTime date;
  final String? countryCode;
  final String? languageCode;

  AnchorProviderArgs({required this.date, this.countryCode, this.languageCode});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnchorProviderArgs &&
          runtimeType == other.runtimeType &&
          date == other.date &&
          countryCode == other.countryCode &&
          languageCode == other.languageCode;

  @override
  int get hashCode =>
      date.hashCode ^ countryCode.hashCode ^ languageCode.hashCode;
}

final emotionalAnchorProvider =
    FutureProvider.autoDispose.family<EmotionalAnchorBundle?, AnchorProviderArgs>(
  (ref, args) {
    return ref.watch(historicalDataServiceProvider).getEmotionalAnchor(
          args.date,
          args.countryCode,
          args.languageCode,
        );
  },
);

// 7. Provider for the audio player
final audioPlayerProvider =
    NotifierProvider<AudioNotifier, AudioPlayerState>(AudioNotifier.new);

// 8. Provider for managing the application's locale
class LocaleNotifier extends StateNotifier<Locale?> {
  final Ref _ref;
  bool _disposed = false;

  LocaleNotifier(this._ref, [Locale? initialLocale]) : super(initialLocale);

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> syncLocaleWithUserProfile() async {
    if (_disposed) return;

    try {
      final authValue = _ref.read(authStateChangesProvider);
      final userService = _ref.read(userServiceProvider);
      final user = authValue.asData?.value;

      if (user == null || _disposed) {
        return;
      }

      final userProfile = await userService.getUserProfile(user.uid);
      if (_disposed) return;

      final prefs = await SharedPreferences.getInstance();
      if (_disposed) return;

      final savedCode = prefs.getString('appLocale');
      final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;

      if (userProfile?.languageCode != null) {
        // Check if this is first launch after reinstall (no saved locale in SharedPreferences)
        final isFirstLaunchAfterReinstall = savedCode == null;

        if (isFirstLaunchAfterReinstall) {
          // First launch after reinstall: use system language and update Firestore
          debugPrint('[LocaleNotifier] First launch after reinstall detected. Using system locale: ${systemLocale.languageCode}');

          if (!_disposed && state != systemLocale) {
            state = systemLocale;
          }
          if (!_disposed) {
            await prefs.setString('appLocale', systemLocale.languageCode);
            // Update Firestore with system language
            final updatedProfile = userProfile!.copyWith(languageCode: systemLocale.languageCode);
            await userService.updateUserProfile(updatedProfile);
            debugPrint('[LocaleNotifier] Updated Firestore language to: ${systemLocale.languageCode}');
          }
        } else {
          // Normal case: use Firestore language (user's saved preference)
          final newLocale = Locale(userProfile!.languageCode!);
          if (!_disposed && state != newLocale) {
            state = newLocale;
            debugPrint('[LocaleNotifier] Synced locale with Firestore: ${userProfile.languageCode}');
          }
          if (!_disposed) {
            await prefs.setString('appLocale', userProfile.languageCode!);
          }
        }
      } else {
        // No languageCode in Firestore
        if (savedCode != null && !_disposed) {
          if (state?.languageCode != savedCode) {
            state = Locale(savedCode);
          }
        } else {
          if (!_disposed && state == null) {
            state = WidgetsBinding.instance.platformDispatcher.locale;
          }
        }
      }
    } catch (e) {
      if (!_disposed) {
        debugPrint('Error in syncLocaleWithUserProfile: $e');
      }
    }
  }

  Future<void> setLocale(Locale newLocale) async {
    if (_disposed) return;

    try {
      state = newLocale;
      final prefs = await SharedPreferences.getInstance();
      if (!_disposed) {
        await prefs.setString('appLocale', newLocale.languageCode);
      }
    } catch (e) {
      if (!_disposed) {
        debugPrint('Error in setLocale: $e');
      }
    }
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  return LocaleNotifier(ref);
});

// NEW: Provider to track if the unlock screen is visible.
// This is used to prevent the app from locking the session when the biometric
// prompt is shown, which temporarily puts the app in the background.
final isUnlockScreenVisibleProvider = StateProvider<bool>((ref) => false);

// FIX: Provider to track if signOut is in progress
// This prevents UnlockScreen from appearing during the race condition when
// AuthGate rebuilds DURING signOut before it completes
// Using StateProvider to avoid CircularDependencyError
final isSigningOutProvider = StateProvider<bool>((ref) => false);

