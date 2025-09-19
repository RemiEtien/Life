import 'dart:async';
import 'dart:convert';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:intl/intl.dart';
import 'package:lifeline/models/anchors/anchor_models.dart';
import 'package:lifeline/services/spotify_service.dart';

class HistoricalDataService {
  final SpotifyService _spotifyService;

  HistoricalDataService(this._spotifyService);

  Future<EmotionalAnchorBundle?> getEmotionalAnchor(
      DateTime date, String? countryCode, String? languageCode) async {
    const lang = 'en';

    try {
      // Запускаем запросы параллельно, но теперь при ошибке любого из них
      // будет выброшено исключение, которое поймает Provider.
      final results = await Future.wait([
        _fetchNewsEvents(date, lang),
        _fetchBillboardWeekWithRetries(date),
      ]);

      final worldNews = results[0] as List<NewsAnchor>;
      final musicChart = results[1] as List<MusicAnchor>;

      // Если оба списка пусты, даже после успешных запросов, возвращаем null,
      // чтобы показать сообщение "Нет данных".
      if (worldNews.isEmpty && musicChart.isEmpty) {
        return null;
      }

      return EmotionalAnchorBundle(
        worldNews: worldNews,
        musicChart: musicChart,
      );
    } catch (e, stackTrace) {
      // Логируем ошибку и пробрасываем ее дальше, чтобы UI мог показать
      // состояние ошибки с кнопкой "Повторить".
      FirebaseCrashlytics.instance.recordError(e, stackTrace,
          reason: 'HistoricalDataService: getEmotionalAnchor failed');
      rethrow;
    }
  }

  // Убран try-catch, чтобы ошибки "всплывали" до Provider'а.
  Future<List<NewsAnchor>> _fetchNewsEvents(DateTime date, String lang) async {
    // Сначала пытаемся получить статью, т.к. она более релевантна.
    final articleNews = await _fetchArticleForSpecificDate(date, lang);
    if (articleNews.isNotEmpty) return articleNews;

    // Если статьи нет, получаем события "в этот день".
    return await _fetchOnThisDayEvents(date, lang);
  }

  Future<List<NewsAnchor>> _fetchArticleForSpecificDate(
      DateTime date, String lang) async {
    final String pageTitle = _formatDateForWikipediaArticle(date);
    final url = Uri.parse(
        'https://$lang.wikipedia.org/w/api.php?action=query&prop=extracts&exintro=true&explaintext=true&format=json&titles=${Uri.encodeComponent(pageTitle)}');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final pages = data['query']['pages'];
        if (pages.keys.first == '-1') return [];
        final pageData = pages[pages.keys.first];
        if (pageData['extract'] != null && pageData['extract'].isNotEmpty) {
          final extract = pageData['extract'] as String;
          return [
            NewsAnchor(
                title: pageTitle.replaceAll('_', ' '),
                description: extract,
                source: 'Wikipedia ($lang)')
          ];
        }
      }
    } catch (e, stackTrace) {
       if (kDebugMode) {
         print("Error in _fetchArticleForSpecificDate: $e");
       }
       FirebaseCrashlytics.instance.recordError(e, stackTrace, reason: 'Wikipedia article fetch failed');
    }
    return [];
  }

  Future<List<NewsAnchor>> _fetchOnThisDayEvents(
      DateTime date, String lang) async {
    final url = Uri.parse(
        'https://api.wikimedia.org/feed/v1/wikipedia/$lang/onthisday/events/${date.month}/${date.day}');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return (data['events'] as List)
            .map((event) => NewsAnchor.fromWikipediaEvent(event))
            .take(5)
            .toList();
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("Error in _fetchOnThisDayEvents: $e");
      }
      FirebaseCrashlytics.instance.recordError(e, stackTrace, reason: 'Wikipedia OnThisDay fetch failed');
    }
    return [];
  }

  DateTime _normalizeToBillboardWeek(DateTime anyDate) {
    int daysToSubtract = (anyDate.weekday % 7) - (DateTime.saturday % 7);
    if (daysToSubtract < 0) {
      daysToSubtract += 7;
    }
    return anyDate.subtract(Duration(days: daysToSubtract));
  }

  Future<List<MusicAnchor>> _fetchBillboardWeekWithRetries(DateTime date,
      {int maxWeeksBack = 8}) async {
    DateTime chartDate = _normalizeToBillboardWeek(date);

    for (int i = 0; i < maxWeeksBack; i++) {
      final tryDate = chartDate.subtract(Duration(days: 7 * i));
      final formattedDate = DateFormat('yyyy-MM-dd').format(tryDate);
      
      if (kDebugMode) {
        print('Attempting to fetch Billboard chart for week of $formattedDate...');
      }
      
      try {
        final entries = await _fetchAndParseBillboardPage(tryDate);
        
        if (entries.isNotEmpty) {
           if (kDebugMode) {
             print('Successfully parsed ${entries.length} entries from Billboard for $formattedDate.');
           }
          final spotifyMatches = await _mapEntriesToSpotify(entries);
          
          if (spotifyMatches.isNotEmpty) {
             if (kDebugMode) {
               print('Successfully matched ${spotifyMatches.length} tracks on Spotify.');
             }
             return spotifyMatches;
          } else {
             if (kDebugMode) {
               print('Parsed Billboard entries, but found no matches on Spotify. Trying previous week...');
             }
          }
        }
      } catch (e, stackTrace) {
        FirebaseCrashlytics.instance.recordError(
          e, 
          stackTrace, 
          reason: 'Billboard week fetch failed for $formattedDate'
        );
        if (kDebugMode) {
          print("Error fetching week $formattedDate, trying previous week. Error: $e");
        }
      }
    }
    
    throw Exception(
        "Could not find any valid Billboard chart with Spotify matches within $maxWeeksBack weeks of $date.");
  }

  Future<List<Map<String, String>>> _fetchAndParseBillboardPage(DateTime chartDate) async {
    final ymd = DateFormat('yyyy-MM-dd').format(chartDate);
    final url = Uri.parse('https://www.billboard.com/charts/hot-100/$ymd/');
    
    try {
      final resp = await http.get(
        url,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        },
      ).timeout(const Duration(seconds: 15));

      if (resp.statusCode != 200) {
        if (kDebugMode) {
          print('Billboard HTTP Info: Status ${resp.statusCode} for date $ymd (chart may not exist)');
        }
        return [];
      }

      final doc = parser.parse(resp.body);
      final items = doc.querySelectorAll('div.o-chart-results-list-row-container, .chart-list__element');
      
      if (items.isEmpty) {
        if (kDebugMode) {
          print('Could not find chart items on Billboard page for $ymd. The page structure might have changed.');
        }
        FirebaseCrashlytics.instance.recordError(
          Exception('Billboard parsing failed: No chart items found'),
          null,
          reason: 'HTML structure might have changed for URL: $url'
        );
        return [];
      }
      
      final results = <Map<String, String>>[];
      for (final item in items.take(10)) {
        final titleEl = item.querySelector('h3#title-of-a-story, .c-title');
        final artistEl = titleEl?.nextElementSibling;

        if (titleEl != null && artistEl != null) {
          final title = titleEl.text.trim();
          final artist = artistEl.text.trim();
          
          if (title.isNotEmpty && artist.isNotEmpty) {
            results.add({'title': title, 'artist': artist});
          }
        }
      }
      return results;

    } on TimeoutException catch(e, stackTrace) {
      if (kDebugMode) {
        print("Timeout during Billboard fetch for $ymd: $e");
      }
      FirebaseCrashlytics.instance.recordError(e, stackTrace, reason: 'Billboard Timeout for $ymd');
      rethrow;
    } catch(e, stackTrace) {
      if (kDebugMode) {
        print("Exception during Billboard fetch/parse for $ymd: $e");
      }
       FirebaseCrashlytics.instance.recordError(e, stackTrace, reason: 'Billboard Fetch/Parse Exception for $ymd');
      rethrow;
    }
  }

  Future<List<MusicAnchor>> _mapEntriesToSpotify(List<Map<String, String>> entries) async {
      List<MusicAnchor> musicAnchors = [];
      int rank = 1;
      for (final entry in entries) {
        final cleanTitleStr = _cleanTitle(entry['title']!);
        final cleanArtistStr = _cleanArtist(entry['artist']!);

        final spotifyDetails = await _spotifyService.findBestMatch(cleanTitleStr, cleanArtistStr);
        if (spotifyDetails != null) {
          musicAnchors.add(MusicAnchor.fromSpotifyTrack(spotifyDetails, rank++));
        }
      }
      return musicAnchors;
  }

  String _cleanTitle(String s) {
    var t = s;
    t = t.replaceAll(RegExp(r'\s*\(.*?\)'), '');
    t = t.replaceAll(RegExp(r'\s*\[.*?\]'), '');
    t = t.replaceAll(RegExp(r'\s*-\s*(Remaster(ed)?|From.*|Live.*|Radio Edit).*$', caseSensitive: false), '');
    return t.trim();
  }

  String _cleanArtist(String s) {
    var a = s;
    a = a.replaceAll(RegExp(r'\s+(feat\.|featuring|with)\s+.*$', caseSensitive: false), '');
    a = a.split(RegExp(r',|&| x ')).first;
    return a.trim();
  }
  
  String _formatDateForWikipediaArticle(DateTime date) {
    return DateFormat('MMMM d, yyyy', 'en_US').format(date);
  }
}

