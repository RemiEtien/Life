import 'package:cloud_functions/cloud_functions.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifeline/models/anchors/anchor_models.dart';
import 'package:lifeline/models/user_profile.dart';
import 'package:lifeline/memory.dart';
import 'package:lifeline/services/audio_service.dart';
import 'package:lifeline/services/auth_service.dart';
import 'package:lifeline/services/encryption_service.dart';
import 'package:lifeline/services/export_service.dart';
import 'package:lifeline/services/firestore_service.dart';
import 'package:lifeline/services/historical_data_service.dart';
import 'package:lifeline/services/memory_repository.dart';
import 'package:lifeline/services/notification_service.dart';
import 'package:lifeline/services/onboarding_service.dart';
import 'package:lifeline/services/purchase_service.dart';
import 'package:lifeline/services/spotify_service.dart';
import 'package:lifeline/services/sync_service.dart';
import 'package:lifeline/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 0. Provider to track network state
// ИСПРАВЛЕНО: Тип изменен на Stream<List<ConnectivityResult>> в соответствии с новой версией пакета connectivity_plus
final connectivityStreamProvider =
    StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

// 1. Service providers (simple)
final firestoreServiceProvider = Provider((ref) => FirestoreService());
final notificationServiceProvider = Provider((ref) => NotificationService());
final exportServiceProvider = Provider((ref) => ExportService());

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

// --- NEW: Purchase Service Provider ---
final purchaseServiceProvider =
    StateNotifierProvider<PurchaseService, PurchaseState>((ref) {
  // ИСПРАВЛЕНИЕ: Provider теперь зависит от authServiceProvider, а не напрямую от authState.
  // Это более стабильный подход, так как сервис доступен всегда.
  return PurchaseService(ref);
});

// 1.5. User Service and Auth Service that depend on Ref
final userServiceProvider = Provider((ref) => UserService(ref));
final authServiceProvider = Provider((ref) => AuthService(ref));

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
final authStateChangesProvider = StreamProvider<User?>(
  (ref) {
    // ИСПРАВЛЕНИЕ: Убираем listenSelf, так как он устарел.
    // Логика блокировки сессии теперь будет управляться внутри самого EncryptionService,
    // который уже слушает изменения в userProfileProvider, что более надежно.
    return ref.watch(authServiceProvider).authStateChanges;
  },
);

// 3. User-dependent providers
final memoryRepositoryProvider = Provider<MemoryRepository?>((ref) {
  final user = ref.watch(authStateChangesProvider).asData?.value;
  if (user != null) {
    final encryptionService = ref.watch(encryptionServiceProvider.notifier);
    return MemoryRepository(
        userId: user.uid, encryptionService: encryptionService);
  }
  return null;
});

final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  final user = ref.watch(authStateChangesProvider).asData?.value;
  if (user != null) {
    return ref.watch(userServiceProvider).getUserProfileStream(user.uid);
  }
  return Stream.value(null);
});

// --- NEW: Convenience provider for premium status ---
final isPremiumProvider = Provider<bool>((ref) {
  final profile = ref.watch(userProfileProvider).asData?.value;
  if (profile == null) return false;

  // Logic for trial period
  if (profile.trialStartedAt != null && !profile.isPremium) {
    if (DateTime.now().difference(profile.trialStartedAt!).inDays < 7) {
      return true; // User is in trial
    }
  }

  // Logic for active subscription
  if (profile.isPremium && profile.premiumUntil != null) {
    return profile.premiumUntil!.isAfter(DateTime.now());
  }

  return false;
});

// 4. Memories stream provider
final memoriesStreamProvider = StreamProvider<List<Memory>>((ref) {
  final memoryRepo = ref.watch(memoryRepositoryProvider);
  if (memoryRepo != null) {
    return memoryRepo.watchAllSortedByDate();
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
    FutureProvider.family<SpotifyTrackDetails?, String>(
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
    FutureProvider.family<EmotionalAnchorBundle?, AnchorProviderArgs>(
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
  final Ref ref;
  LocaleNotifier(this.ref, [Locale? initialLocale]) : super(initialLocale);

  Future<void> syncLocaleWithUserProfile() async {
    final user = ref.read(authStateChangesProvider).asData?.value;
    if (user == null) {
      return;
    }

    final userProfile =
        await ref.read(userServiceProvider).getUserProfile(user.uid);
    final prefs = await SharedPreferences.getInstance();

    if (userProfile?.languageCode != null) {
      final newLocale = Locale(userProfile!.languageCode!);
      if (state != newLocale) {
        state = newLocale;
      }
      await prefs.setString('appLocale', userProfile.languageCode!);
    } else {
      final savedCode = prefs.getString('appLocale');
      if (savedCode != null) {
        if (state?.languageCode != savedCode) {
          state = Locale(savedCode);
        }
      } else {
        // ИСПРАВЛЕНО: `window` устарело. Используем `platformDispatcher`.
        if (state == null) {
          state = WidgetsBinding.instance.platformDispatcher.locale;
        }
      }
    }
  }

  void setLocale(Locale newLocale) async {
    state = newLocale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('appLocale', newLocale.languageCode);
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  return LocaleNotifier(ref);
});

