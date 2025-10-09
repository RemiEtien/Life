import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'analytics_service.dart';

/// Service for managing audio assets (music and sounds) with on-demand download.
///
/// This service provides:
/// - On-demand download from Firebase Storage
/// - Local caching of downloaded files
/// - Analytics tracking for downloads and playback
/// - Preloading of essential sounds
///
/// Usage:
/// ```dart
/// // Get audio file (downloads if needed)
/// final file = await AudioAssetService.getAudioFile('nature_birds.mp3', AudioCategory.sound);
///
/// // Preload essential sounds at app start
/// await AudioAssetService.preloadEssentials();
/// ```
class AudioAssetService {
  static const String _storageMusicPrefix = 'audio_assets/music';
  static const String _storageSoundsPrefix = 'audio_assets/sounds';
  static const String _cacheDirectoryName = 'audio_cache';

  /// Essential sounds to preload (small files, frequently used)
  static const List<String> _essentialSounds = [
    'nature_birds.mp3',    // 1.3 MB
    'heavy_rain.mp3',      // 599 KB
  ];

  // ============================================================================
  // PUBLIC API
  // ============================================================================

  /// Get audio file, downloading from Firebase Storage if not cached
  ///
  /// [fileName]: Name of the audio file (e.g., 'ocean_waves.mp3')
  /// [category]: Category of audio (music or sound)
  ///
  /// Returns: File object pointing to local cached file
  ///
  /// Throws: Exception if download fails
  static Future<File> getAudioFile(String fileName, AudioCategory category) async {
    try {
      // Check local cache first
      final cachedFile = await _getCachedFile(fileName);

      if (await cachedFile.exists()) {
        // FIX: Verify file is not empty/corrupted before using it
        final fileSize = await cachedFile.length();
        if (fileSize > 0) {
          if (kDebugMode) {
            debugPrint('[AudioAsset] Using cached: $fileName (${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB)');
          }
          return cachedFile;
        } else {
          // File exists but is empty - delete and re-download
          if (kDebugMode) {
            debugPrint('[AudioAsset] Cached file is empty, re-downloading: $fileName');
          }
          await cachedFile.delete();
        }
      }

      // Download from Firebase Storage
      if (kDebugMode) {
        debugPrint('[AudioAsset] Downloading: $fileName');
      }

      await _downloadFile(fileName, cachedFile, category);

      // Verify download succeeded
      final fileSize = await cachedFile.length();
      if (fileSize == 0) {
        throw Exception('Downloaded file is empty');
      }

      // Log analytics
      final sizeMB = fileSize / (1024 * 1024);

      await AnalyticsService.logAudioAssetDownloaded(
        assetName: fileName,
        category: category.name,
        sizeMB: double.parse(sizeMB.toStringAsFixed(2)),
      );

      return cachedFile;
    } catch (e) {
      debugPrint('[AudioAsset] Error getting file $fileName: $e');
      rethrow;
    }
  }

  /// Preload essential sounds in background (call at app start)
  ///
  /// Downloads only small, frequently-used sounds
  /// Total: ~2 MB instead of 76 MB
  static Future<void> preloadEssentials() async {
    if (kDebugMode) {
      debugPrint('[AudioAsset] Preloading ${_essentialSounds.length} essential sounds...');
    }

    try {
      await Future.wait(
        _essentialSounds.map(
          (fileName) => getAudioFile(fileName, AudioCategory.sound),
        ),
      );

      if (kDebugMode) {
        debugPrint('[AudioAsset] ✅ Essential sounds preloaded');
      }
    } catch (e) {
      // Don't fail app startup if preload fails
      debugPrint('[AudioAsset] ⚠️ Preload failed (non-critical): $e');
    }
  }

  /// Check if audio file is cached locally
  ///
  /// Useful for showing download indicators in UI
  static Future<bool> isFileCached(String fileName) async {
    final cachedFile = await _getCachedFile(fileName);
    return cachedFile.exists();
  }

  /// Get size of cached audio file in MB
  ///
  /// Returns null if file is not cached
  static Future<double?> getCachedFileSize(String fileName) async {
    final cachedFile = await _getCachedFile(fileName);

    if (!await cachedFile.exists()) {
      return null;
    }

    final fileSize = await cachedFile.length();
    return fileSize / (1024 * 1024);
  }

  /// Clear all cached audio files
  ///
  /// Call this when user wants to free up storage
  /// Returns total MB freed
  static Future<double> clearCache() async {
    try {
      final cacheDir = await _getCacheDirectory();

      if (!await cacheDir.exists()) {
        return 0.0;
      }

      // Calculate total size before deletion
      double totalSize = 0.0;
      await for (final entity in cacheDir.list()) {
        if (entity is File) {
          final size = await entity.length();
          totalSize += size;
        }
      }

      // Delete cache directory
      await cacheDir.delete(recursive: true);

      final mbFreed = totalSize / (1024 * 1024);

      if (kDebugMode) {
        debugPrint('[AudioAsset] Cache cleared: ${mbFreed.toStringAsFixed(2)} MB freed');
      }

      return mbFreed;
    } catch (e) {
      debugPrint('[AudioAsset] Error clearing cache: $e');
      return 0.0;
    }
  }

  /// Get total size of audio cache in MB
  static Future<double> getCacheSize() async {
    try {
      final cacheDir = await _getCacheDirectory();

      if (!await cacheDir.exists()) {
        return 0.0;
      }

      double totalSize = 0.0;
      await for (final entity in cacheDir.list()) {
        if (entity is File) {
          final size = await entity.length();
          totalSize += size;
        }
      }

      return totalSize / (1024 * 1024);
    } catch (e) {
      debugPrint('[AudioAsset] Error getting cache size: $e');
      return 0.0;
    }
  }

  // ============================================================================
  // PRIVATE METHODS
  // ============================================================================

  /// Get cached file path
  static Future<File> _getCachedFile(String fileName) async {
    final cacheDir = await _getCacheDirectory();
    return File('${cacheDir.path}/$fileName');
  }

  /// Get cache directory, creating if needed
  ///
  /// FIX: Use getApplicationSupportDirectory() instead of getApplicationDocumentsDirectory()
  /// to ensure files persist across app restarts and are not cleared by system.
  /// ApplicationSupport directory is designed for app-generated content that should
  /// persist but is not user-visible (perfect for audio cache).
  static Future<Directory> _getCacheDirectory() async {
    final appDir = await getApplicationSupportDirectory();
    final cacheDir = Directory('${appDir.path}/$_cacheDirectoryName');

    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }

    return cacheDir;
  }

  /// Download file from Firebase Storage
  static Future<void> _downloadFile(
    String fileName,
    File destinationFile,
    AudioCategory category,
  ) async {
    // Determine storage path based on category
    final storagePath = category == AudioCategory.music
        ? '$_storageMusicPrefix/$fileName'
        : '$_storageSoundsPrefix/$fileName';

    // Get Firebase Storage reference
    final storageRef = FirebaseStorage.instance.ref().child(storagePath);

    try {
      // Download file
      await storageRef.writeToFile(destinationFile);

      if (kDebugMode) {
        final fileSize = await destinationFile.length();
        final sizeMB = fileSize / (1024 * 1024);
        debugPrint('[AudioAsset] Downloaded: $fileName (${sizeMB.toStringAsFixed(2)} MB)');
      }
    } on FirebaseException catch (e) {
      debugPrint('[AudioAsset] Firebase error downloading $fileName: ${e.code} - ${e.message}');
      throw Exception('Failed to download audio: ${e.message}');
    } catch (e) {
      debugPrint('[AudioAsset] Error downloading $fileName: $e');
      throw Exception('Failed to download audio: $e');
    }
  }

  // ============================================================================
  // CATALOG (for UI)
  // ============================================================================

  /// Get list of available music files
  ///
  /// This is a static list. In a production app, you might want to
  /// fetch this from Firestore or a JSON file
  static List<AudioAssetInfo> getAvailableMusic() {
    return const [
      AudioAssetInfo(
        fileName: 'ambient-background-347405.mp3',
        displayName: 'Ambient Background',
        category: AudioCategory.music,
        approximateSizeMB: 16.0,
      ),
      AudioAssetInfo(
        fileName: 'ambient-background-339939.mp3',
        displayName: 'Calm Ambient',
        category: AudioCategory.music,
        approximateSizeMB: 7.9,
      ),
      AudioAssetInfo(
        fileName: 'relaxing-electronic-ambient-music-354471.mp3',
        displayName: 'Relaxing Electronic',
        category: AudioCategory.music,
        approximateSizeMB: 5.6,
      ),
      AudioAssetInfo(
        fileName: 'solitude-dark-ambient-music-354468.mp3',
        displayName: 'Solitude',
        category: AudioCategory.music,
        approximateSizeMB: 5.3,
      ),
      AudioAssetInfo(
        fileName: 'midnight-forest-184304.mp3',
        displayName: 'Midnight Forest',
        category: AudioCategory.music,
        approximateSizeMB: 5.2,
      ),
      AudioAssetInfo(
        fileName: 'blue-ice-ambient-background-music-365976.mp3',
        displayName: 'Blue Ice',
        category: AudioCategory.music,
        approximateSizeMB: 5.0,
      ),
      AudioAssetInfo(
        fileName: 'space-ambient-351305.mp3',
        displayName: 'Space Ambient',
        category: AudioCategory.music,
        approximateSizeMB: 4.2,
      ),
      AudioAssetInfo(
        fileName: 'ambient-music-349056.mp3',
        displayName: 'Peaceful Ambient',
        category: AudioCategory.music,
        approximateSizeMB: 4.0,
      ),
      AudioAssetInfo(
        fileName: 'space-ambient-cinematic-351304.mp3',
        displayName: 'Cinematic Space',
        category: AudioCategory.music,
        approximateSizeMB: 3.2,
      ),
    ];
  }

  /// Get list of available sound effects
  static List<AudioAssetInfo> getAvailableSounds() {
    return const [
      AudioAssetInfo(
        fileName: 'ocean_waves.mp3',
        displayName: 'Ocean Waves',
        category: AudioCategory.sound,
        approximateSizeMB: 4.9,
      ),
      AudioAssetInfo(
        fileName: 'cicada_night.mp3',
        displayName: 'Cicada Night',
        category: AudioCategory.sound,
        approximateSizeMB: 3.2,
      ),
      AudioAssetInfo(
        fileName: 'wind_storm.mp3',
        displayName: 'Wind Storm',
        category: AudioCategory.sound,
        approximateSizeMB: 3.1,
      ),
      AudioAssetInfo(
        fileName: 'forest_night.mp3',
        displayName: 'Forest Night',
        category: AudioCategory.sound,
        approximateSizeMB: 2.7,
      ),
      AudioAssetInfo(
        fileName: 'forest_rain.mp3',
        displayName: 'Forest Rain',
        category: AudioCategory.sound,
        approximateSizeMB: 2.5,
      ),
      AudioAssetInfo(
        fileName: 'nature_birds.mp3',
        displayName: 'Nature Birds',
        category: AudioCategory.sound,
        approximateSizeMB: 1.3,
      ),
      AudioAssetInfo(
        fileName: 'summer_day.mp3',
        displayName: 'Summer Day',
        category: AudioCategory.sound,
        approximateSizeMB: 1.1,
      ),
      AudioAssetInfo(
        fileName: 'heavy_rain.mp3',
        displayName: 'Heavy Rain',
        category: AudioCategory.sound,
        approximateSizeMB: 0.6,
      ),
    ];
  }
}

// ============================================================================
// MODELS
// ============================================================================

/// Category of audio asset
enum AudioCategory {
  music,
  sound,
}

/// Information about an audio asset
class AudioAssetInfo {
  final String fileName;
  final String displayName;
  final AudioCategory category;
  final double approximateSizeMB;

  const AudioAssetInfo({
    required this.fileName,
    required this.displayName,
    required this.category,
    required this.approximateSizeMB,
  });

  /// Get human-readable size string
  String get sizeString {
    if (approximateSizeMB < 1) {
      return '${(approximateSizeMB * 1024).toStringAsFixed(0)} KB';
    }
    return '${approximateSizeMB.toStringAsFixed(1)} MB';
  }
}
