import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:lifeline/models/anchors/anchor_models.dart';

class SpotifyService {
  final FirebaseFunctions _functions;

  // ИЗМЕНЕНО: FirebaseFunctions теперь передается через конструктор
  SpotifyService(this._functions);

  // Ленивая инициализация для вызова облачных функций
  late final HttpsCallable _searchTracksCallable =
      _functions.httpsCallable('searchTracks');
  late final HttpsCallable _getTrackDetailsCallable =
      _functions.httpsCallable('getTrackDetails');

  /// ИЗМЕНЕНО: Более безопасный маппер с проверкой типов, чтобы избежать падений.
  SpotifyTrackDetails _mapToTrackDetails(Map<String, dynamic> data) {
    // Вспомогательная функция для безопасного преобразования любого значения в String.
    String? _s(dynamic v) => v?.toString();

    return SpotifyTrackDetails(
      id: _s(data['id']) ?? '',
      name: _s(data['name']) ?? 'Unknown Track',
      artist: _s(data['artist']) ?? 'Unknown Artist',
      albumArtUrl: _s(data['albumArtUrl']),
      trackUrl: _s(data['trackUrl']),
    );
  }

  /// ИЗМЕНЕНО: Добавлена надежная обработка и преобразование ответа от Firebase Functions.
  Future<List<SpotifyTrackDetails>> searchTracks(String query) async {
    try {
      final result = await _searchTracksCallable.call<dynamic>({
        'query': query,
      });

      // 1. Безопасно преобразуем корневой объект
      final Map<String, dynamic> root = Map<String, dynamic>.from(result.data as Map);
      
      // 2. Безопасно извлекаем список
      final List<dynamic> rawTracks = root['tracks'] as List<dynamic>? ?? const [];

      // 3. Безопасно преобразуем каждый элемент списка
      final tracks = rawTracks.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        return _mapToTrackDetails(map);
      }).toList();

      return tracks;
    } on FirebaseFunctionsException catch (e, stackTrace) {
      if (kDebugMode) {
        print('FirebaseFunctionsException searching tracks: ${e.code} - ${e.message}');
      }
      FirebaseCrashlytics.instance.recordError(e, stackTrace, reason: 'Spotify Search Failed (Cloud Function)');
      return [];
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Unexpected error during track search: $e');
      }
      FirebaseCrashlytics.instance.recordError(e, stackTrace, reason: 'Spotify Search Failed (Client-side)');
      return [];
    }
  }

  /// ИЗМЕНЕНО: Добавлена надежная обработка и преобразование ответа от Firebase Functions.
  Future<SpotifyTrackDetails?> getTrackDetails(String trackId) async {
    try {
      final result = await _getTrackDetailsCallable.call<dynamic>({
        'trackId': trackId,
      });
      
      final Map<String, dynamic> root = Map<String, dynamic>.from(result.data as Map);
      
      final detailsData = root['details'] as Map?;
      if (detailsData == null) return null;

      final Map<String, dynamic> detailsMap = Map<String, dynamic>.from(detailsData);
      return _mapToTrackDetails(detailsMap);

    } on FirebaseFunctionsException catch (e, stackTrace) {
      if (kDebugMode) {
        print('FirebaseFunctionsException getting track details: ${e.code} - ${e.message}');
      }
      FirebaseCrashlytics.instance.recordError(e, stackTrace, reason: 'Spotify GetDetails Failed (Cloud Function)');
      return null;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Unexpected error getting track details: $e');
      }
      FirebaseCrashlytics.instance.recordError(e, stackTrace, reason: 'Spotify GetDetails Failed (Client-side)');
      return null;
    }
  }

  /// Ищет трек по названию и исполнителю и возвращает лучшее совпадение.
  Future<SpotifyTrackDetails?> findBestMatch(String title, String artist) async {
    try {
      // Формируем точный запрос для поиска
      final query = 'track:"$title" artist:"$artist"';
      final results = await searchTracks(query);
      if (results.isNotEmpty) {
        return results.first;
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error finding best match on Spotify: $e');
      }
      return null;
    }
  }
}
