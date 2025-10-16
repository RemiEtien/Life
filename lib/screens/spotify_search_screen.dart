import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../models/anchors/anchor_models.dart';
import '../providers/application_providers.dart';

class SpotifySearchScreen extends ConsumerStatefulWidget {
  const SpotifySearchScreen({super.key});

  @override
  ConsumerState<SpotifySearchScreen> createState() => _SpotifySearchScreenState();
}

class _SpotifySearchScreenState extends ConsumerState<SpotifySearchScreen> {
  final _searchController = TextEditingController();
  List<SpotifyTrackDetails> _searchResults = [];
  bool _isLoading = false;

  Future<void> _search() async {
    if (_searchController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    // ИСПРАВЛЕНИЕ: Сначала получаем сервис, потом выполняем асинхронный вызов
    final spotifyService = ref.read(spotifyServiceProvider);
    final results = await spotifyService
        .searchTracks(_searchController.text.trim());

    // ИСПРАВЛЕНИЕ: Проверяем, что виджет все еще существует после асинхронной операции
    if (!mounted) return;

    setState(() {
      _searchResults = results;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.spotifySearchTitle),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              textCapitalization: TextCapitalization.sentences,
              enableSuggestions: true,
              autocorrect: true,
              decoration: InputDecoration(
                labelText: l10n.spotifySearchHint,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _search,
                ),
              ),
              onSubmitted: (_) => _search(),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final track = _searchResults[index];
                      return ListTile(
                        leading: track.albumArtUrl != null
                            ? CachedNetworkImage(
                                imageUrl: track.albumArtUrl!,
                                placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.music_note),
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.music_note),
                        title: Text(track.name),
                        subtitle: Text(track.artist),
                        onTap: () {
                          Navigator.of(context).pop(track.id);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
