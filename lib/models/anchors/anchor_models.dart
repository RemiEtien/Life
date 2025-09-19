class EmotionalAnchorBundle {
  final List<NewsAnchor> worldNews;
  final List<NewsAnchor> countryNews;
  final List<MusicAnchor> musicChart;
  final List<MovieAnchor> movieReleases;

  const EmotionalAnchorBundle({
    this.worldNews = const [],
    this.countryNews = const [],
    this.musicChart = const [],
    this.movieReleases = const [],
  });
}

class NewsAnchor {
  final String title;
  final String description;
  final String source;
  final String? imageUrl;

  const NewsAnchor({
    required this.title,
    required this.description,
    required this.source,
    this.imageUrl,
  });

  factory NewsAnchor.fromWikipediaEvent(Map<String, dynamic> json) {
    final pages = json['pages'] as List;
    final firstPage = pages.isNotEmpty ? pages.first : null;
    String? imageUrl;
    if (firstPage != null && firstPage['thumbnail'] != null) {
      imageUrl = firstPage['thumbnail']['source'] as String?;
    }

    return NewsAnchor(
      title: '${json['year']}: ${json['text']}',
      description: firstPage?['extract'] ?? 'No further details available.',
      source: 'Wikipedia',
      imageUrl: imageUrl,
    );
  }
}

class MusicAnchor {
  final int rank;
  final String title;
  final String artist;
  final String? albumArtUrl;
  final String? spotifyUrl; // НОВОЕ ПОЛЕ: Ссылка на трек в Spotify

  const MusicAnchor({
    required this.rank,
    required this.title,
    required this.artist,
    this.albumArtUrl,
    this.spotifyUrl, // Добавлено в конструктор
  });

  // НОВЫЙ КОНСТРУКТОР: для удобного создания из данных Spotify
  factory MusicAnchor.fromSpotifyTrack(SpotifyTrackDetails track, int rank) {
    return MusicAnchor(
      rank: rank,
      title: track.name,
      artist: track.artist,
      albumArtUrl: track.albumArtUrl,
      spotifyUrl: track.trackUrl,
    );
  }
}

class MovieAnchor {
  final String title;
  final String description;
  final String? posterUrl;
  final double? rating;

  const MovieAnchor({
    required this.title,
    required this.description,
    this.posterUrl,
    this.rating,
  });
}

// Этот класс-помощник нужен для сервиса Spotify, чтобы передавать данные
class SpotifyTrackDetails {
  final String id;
  final String name;
  final String artist;
  final String? albumArtUrl;
  final String? trackUrl;

  SpotifyTrackDetails({
    required this.id,
    required this.name,
    required this.artist,
    this.albumArtUrl,
    this.trackUrl,
  });
}