import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Centralized analytics service for tracking user behavior and app events.
///
/// This service wraps Firebase Analytics to provide:
/// - Type-safe event logging
/// - Consistent parameter naming
/// - Easy-to-use methods for common events
/// - Privacy-compliant tracking
///
/// Usage:
/// ```dart
/// await AnalyticsService.logMemoryCreated(
///   hasPhoto: true,
///   hasEmotions: true,
/// );
/// ```
class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // ============================================================================
  // AUTHENTICATION EVENTS
  // ============================================================================

  /// Log user sign up event
  ///
  /// [method]: Authentication method (google, apple, email)
  static Future<void> logSignUp(String method) async {
    if (kDebugMode) {
      debugPrint('[Analytics] Sign Up: method=$method');
    }

    await _analytics.logEvent(
      name: 'sign_up',
      parameters: {
        'method': method,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Log user login event
  ///
  /// [method]: Authentication method (google, apple, email)
  /// [biometricEnabled]: Whether biometric unlock is enabled
  static Future<void> logLogin(String method, {bool biometricEnabled = false}) async {
    if (kDebugMode) {
      debugPrint('[Analytics] Login: method=$method, biometric=$biometricEnabled');
    }

    await _analytics.logEvent(
      name: 'login',
      parameters: {
        'method': method,
        'biometric_enabled': biometricEnabled ? 1 : 0,
      },
    );
  }

  /// Log user logout event
  static Future<void> logLogout() async {
    if (kDebugMode) {
      debugPrint('[Analytics] Logout');
    }

    await _analytics.logEvent(name: 'logout');
  }

  // ============================================================================
  // MEMORY EVENTS
  // ============================================================================

  /// Log memory creation event
  ///
  /// Parameters:
  /// - [hasMedia]: Whether memory has any media (photo/video/audio)
  /// - [mediaCount]: Total number of media items
  /// - [hasEmotions]: Whether emotions were added
  /// - [hasReflection]: Whether reflection was added
  /// - [wordCount]: Number of words in content
  /// - [isEncrypted]: Whether memory is encrypted
  static Future<void> logMemoryCreated({
    required bool hasMedia,
    required int mediaCount,
    required bool hasEmotions,
    required bool hasReflection,
    required int wordCount,
    bool isEncrypted = false,
  }) async {
    if (kDebugMode) {
      debugPrint('[Analytics] Memory Created: media=$mediaCount, emotions=$hasEmotions, encrypted=$isEncrypted');
    }

    await _analytics.logEvent(
      name: 'memory_created',
      parameters: {
        'has_media': hasMedia ? 1 : 0,
        'media_count': mediaCount,
        'has_emotions': hasEmotions ? 1 : 0,
        'has_reflection': hasReflection ? 1 : 0,
        'word_count': wordCount,
        'is_encrypted': isEncrypted ? 1 : 0,
      },
    );
  }

  /// Log memory edit event
  static Future<void> logMemoryEdited({
    required bool contentChanged,
    required bool mediaChanged,
  }) async {
    if (kDebugMode) {
      debugPrint('[Analytics] Memory Edited: content=$contentChanged, media=$mediaChanged');
    }

    await _analytics.logEvent(
      name: 'memory_edited',
      parameters: {
        'content_changed': contentChanged ? 1 : 0,
        'media_changed': mediaChanged ? 1 : 0,
      },
    );
  }

  /// Log memory deletion event
  static Future<void> logMemoryDeleted({required bool wasEncrypted}) async {
    if (kDebugMode) {
      debugPrint('[Analytics] Memory Deleted: encrypted=$wasEncrypted');
    }

    await _analytics.logEvent(
      name: 'memory_deleted',
      parameters: {
        'was_encrypted': wasEncrypted ? 1 : 0,
      },
    );
  }

  /// Log memory view event
  static Future<void> logMemoryViewed({
    required bool hasMedia,
    required bool hasReflection,
  }) async {
    await _analytics.logEvent(
      name: 'memory_viewed',
      parameters: {
        'has_media': hasMedia ? 1 : 0,
        'has_reflection': hasReflection ? 1 : 0,
      },
    );
  }

  // ============================================================================
  // MEDIA EVENTS
  // ============================================================================

  /// Log media addition to memory
  ///
  /// [mediaType]: Type of media (photo, video, audio)
  /// [count]: Number of items added
  static Future<void> logMediaAdded(String mediaType, {int count = 1}) async {
    if (kDebugMode) {
      debugPrint('[Analytics] Media Added: type=$mediaType, count=$count');
    }

    await _analytics.logEvent(
      name: 'media_added',
      parameters: {
        'media_type': mediaType,
        'count': count,
      },
    );
  }

  /// Log media playback
  ///
  /// [mediaType]: Type of media (video, audio)
  /// [source]: Where media was played from (memory, gallery)
  static Future<void> logMediaPlayed(String mediaType, {String source = 'memory'}) async {
    await _analytics.logEvent(
      name: 'media_played',
      parameters: {
        'media_type': mediaType,
        'source': source,
      },
    );
  }

  // ============================================================================
  // PREMIUM / PURCHASE EVENTS
  // ============================================================================

  /// Log when user initiates a purchase
  ///
  /// [productId]: Product identifier
  /// [price]: Price in user's currency
  /// [currency]: Currency code (USD, EUR, etc.)
  static Future<void> logPurchaseInitiated(
    String productId, {
    double? price,
    String currency = 'USD',
  }) async {
    if (kDebugMode) {
      debugPrint('[Analytics] Purchase Initiated: $productId, $price $currency');
    }

    final params = <String, Object>{
      'product_id': productId,
      'currency': currency,
    };

    if (price != null) {
      params['price'] = price;
    }

    await _analytics.logEvent(
      name: 'purchase_initiated',
      parameters: params,
    );
  }

  /// Log completed purchase (use Firebase's standard event)
  ///
  /// [productId]: Product identifier
  /// [transactionId]: Unique transaction ID
  /// [revenue]: Purchase amount
  /// [currency]: Currency code
  static Future<void> logPurchaseCompleted(
    String productId,
    String transactionId,
    double revenue, {
    String currency = 'USD',
  }) async {
    if (kDebugMode) {
      debugPrint('[Analytics] Purchase Completed: $productId, $revenue $currency');
    }

    // Use Firebase's standard purchase event
    await _analytics.logPurchase(
      value: revenue,
      currency: currency,
      parameters: {
        'product_id': productId,
        'transaction_id': transactionId,
      },
    );
  }

  /// Log purchase cancellation or failure
  static Future<void> logPurchaseFailed(String productId, {String? reason}) async {
    if (kDebugMode) {
      debugPrint('[Analytics] Purchase Failed: $productId, reason=$reason');
    }

    await _analytics.logEvent(
      name: 'purchase_failed',
      parameters: {
        'product_id': productId,
        if (reason != null) 'reason': reason,
      },
    );
  }

  /// Log when premium screen is viewed
  static Future<void> logPremiumScreenViewed() async {
    await _analytics.logEvent(name: 'premium_screen_viewed');
  }

  // ============================================================================
  // FEATURE USAGE EVENTS
  // ============================================================================

  /// Log timeline view
  ///
  /// [memoryCount]: Total memories shown
  /// [dateRangeDays]: Number of days in date range
  static Future<void> logTimelineViewed({
    required int memoryCount,
    int? dateRangeDays,
  }) async {
    await _analytics.logEvent(
      name: 'timeline_viewed',
      parameters: {
        'memory_count': memoryCount,
        if (dateRangeDays != null) 'date_range_days': dateRangeDays,
      },
    );
  }

  /// Log search usage
  ///
  /// [queryLength]: Length of search query
  /// [resultsCount]: Number of results found
  static Future<void> logSearchPerformed({
    required int queryLength,
    required int resultsCount,
  }) async {
    await _analytics.logEvent(
      name: 'search_performed',
      parameters: {
        'query_length': queryLength,
        'results_count': resultsCount,
      },
    );
  }

  /// Log when encryption feature is used
  static Future<void> logEncryptionEnabled() async {
    if (kDebugMode) {
      debugPrint('[Analytics] Encryption Enabled');
    }

    await _analytics.logEvent(name: 'encryption_enabled');
  }

  /// Log Spotify integration
  static Future<void> logSpotifyLinked() async {
    if (kDebugMode) {
      debugPrint('[Analytics] Spotify Linked');
    }

    await _analytics.logEvent(name: 'spotify_linked');
  }

  /// Log feature discovery
  ///
  /// [featureName]: Name of discovered feature
  static Future<void> logFeatureDiscovered(String featureName) async {
    if (kDebugMode) {
      debugPrint('[Analytics] Feature Discovered: $featureName');
    }

    await _analytics.logEvent(
      name: 'feature_discovered',
      parameters: {
        'feature_name': featureName,
      },
    );
  }

  // ============================================================================
  // SESSION EVENTS
  // ============================================================================

  /// Log app session start
  ///
  /// [appVersion]: Current app version
  static Future<void> logSessionStart(String appVersion) async {
    if (kDebugMode) {
      debugPrint('[Analytics] Session Start: v$appVersion');
    }

    await _analytics.logEvent(
      name: 'session_start',
      parameters: {
        'app_version': appVersion,
      },
    );
  }

  // ============================================================================
  // SCREEN VIEWS
  // ============================================================================

  /// Log screen view (automatically tracked by Firebase, but can be manual)
  ///
  /// [screenName]: Name of the screen
  static Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(
      screenName: screenName,
    );
  }

  // ============================================================================
  // USER PROPERTIES
  // ============================================================================

  /// Set user properties (persistent across sessions)
  ///
  /// Call this after authentication or when properties change
  static Future<void> setUserProperties({
    required bool isPremium,
    required String language,
    required bool encryptionEnabled,
    String? platform,
  }) async {
    if (kDebugMode) {
      debugPrint('[Analytics] Set User Properties: premium=$isPremium, lang=$language, encryption=$encryptionEnabled');
    }

    await _analytics.setUserProperty(
      name: 'premium_status',
      value: isPremium ? 'premium' : 'free',
    );

    await _analytics.setUserProperty(
      name: 'language',
      value: language,
    );

    await _analytics.setUserProperty(
      name: 'encryption_enabled',
      value: encryptionEnabled ? 'yes' : 'no',
    );

    if (platform != null) {
      await _analytics.setUserProperty(
        name: 'platform',
        value: platform,
      );
    }
  }

  /// Update premium status (convenience method)
  static Future<void> setPremiumStatus(bool isPremium) async {
    if (kDebugMode) {
      debugPrint('[Analytics] Premium Status: $isPremium');
    }

    await _analytics.setUserProperty(
      name: 'premium_status',
      value: isPremium ? 'premium' : 'free',
    );
  }

  // ============================================================================
  // AUDIO ASSET EVENTS (NEW)
  // ============================================================================

  /// Log when audio asset is downloaded
  ///
  /// [assetName]: Name of audio file
  /// [category]: Type (music, sound)
  /// [sizeMB]: File size in MB
  static Future<void> logAudioAssetDownloaded({
    required String assetName,
    required String category,
    required double sizeMB,
  }) async {
    if (kDebugMode) {
      debugPrint('[Analytics] Audio Downloaded: $assetName ($sizeMB MB)');
    }

    await _analytics.logEvent(
      name: 'audio_asset_downloaded',
      parameters: {
        'asset_name': assetName,
        'category': category,
        'size_mb': sizeMB,
      },
    );
  }

  /// Log when audio asset plays
  ///
  /// [assetName]: Name of audio file
  /// [category]: Type (music, sound)
  /// [wasPreloaded]: Whether file was already cached
  static Future<void> logAudioAssetPlayed({
    required String assetName,
    required String category,
    required bool wasPreloaded,
  }) async {
    await _analytics.logEvent(
      name: 'audio_asset_played',
      parameters: {
        'asset_name': assetName,
        'category': category,
        'was_preloaded': wasPreloaded ? 1 : 0,
      },
    );
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Enable or disable analytics collection
  ///
  /// Respects user privacy preferences
  static Future<void> setAnalyticsEnabled(bool enabled) async {
    if (kDebugMode) {
      debugPrint('[Analytics] Analytics ${enabled ? 'enabled' : 'disabled'}');
    }

    await _analytics.setAnalyticsCollectionEnabled(enabled);
  }

  /// Set user ID (call after successful authentication)
  ///
  /// Use hashed/anonymized ID, NOT email or real name
  static Future<void> setUserId(String? userId) async {
    await _analytics.setUserId(id: userId);
  }
}
