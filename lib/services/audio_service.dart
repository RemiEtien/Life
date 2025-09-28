import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Модель состояния плеера
class AudioPlayerState {
  final bool isPlaying;
  final GlobalTrackDetails? currentTrack;
  final bool isGlobalPlayerActive; // Определяет, играет ли глобальный плеер или звук из воспоминания

  AudioPlayerState({
    this.isPlaying = false,
    this.currentTrack,
    this.isGlobalPlayerActive = false,
  });

  AudioPlayerState copyWith({
    bool? isPlaying,
    GlobalTrackDetails? currentTrack,
    bool? isGlobalPlayerActive,
  }) {
    return AudioPlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      currentTrack: currentTrack ?? this.currentTrack,
      isGlobalPlayerActive: isGlobalPlayerActive ?? this.isGlobalPlayerActive,
    );
  }
}

// Модель для треков
class GlobalTrackDetails {
  final String name;
  final String assetPath;
  GlobalTrackDetails({required this.name, required this.assetPath});
}

// Notifier
class AudioNotifier extends Notifier<AudioPlayerState> {
  final AudioPlayer _player = AudioPlayer();
  // НОВОЕ ПОЛЕ: для запоминания состояния
  bool _wasGlobalPlayerActiveBeforeAmbient = false;

  final List<GlobalTrackDetails> _playlist = [
    GlobalTrackDetails(name: 'Ambient Background', assetPath: 'music/ambient-background-339939.mp3'),
    GlobalTrackDetails(name: 'Ambient Background II', assetPath: 'music/ambient-background-347405.mp3'),
    GlobalTrackDetails(name: 'Ambient Music', assetPath: 'music/ambient-music-349056.mp3'),
    GlobalTrackDetails(name: 'Blue Ice Ambient', assetPath: 'music/blue-ice-ambient-background-music-365976.mp3'),
    GlobalTrackDetails(name: 'Midnight Forest', assetPath: 'music/midnight-forest-184304.mp3'),
    GlobalTrackDetails(name: 'Relaxing Electronic', assetPath: 'music/relaxing-electronic-ambient-music-354471.mp3'),
    GlobalTrackDetails(name: 'Solitude Dark Ambient', assetPath: 'music/solitude-dark-ambient-music-354468.mp3'),
    GlobalTrackDetails(name: 'Space Ambient', assetPath: 'music/space-ambient-351305.mp3'),
    GlobalTrackDetails(name: 'Space Ambient Cinematic', assetPath: 'music/space-ambient-cinematic-351304.mp3'),
  ];
  int _currentIndex = 0;

  static const List<String> availableSounds = [
    'None', 'Cicada Night', 'Forest Night', 'Forest Rain', 'Heavy Rain',
    'Heavy Storm', 'Nature Birds', 'Ocean Waves', 'Summer Day', 'Wind Storm',
  ];

  @override
  AudioPlayerState build() {
    _player.onPlayerComplete.listen((event) {
      if (state.isGlobalPlayerActive && state.isPlaying) {
        playNext();
      }
    });
    return AudioPlayerState();
  }

  static String getSoundAssetPath(String soundName) {
    if (soundName == 'None') return '';
    return 'sounds/${soundName.toLowerCase().replaceAll(' ', '_')}.mp3';
  }

  Future<void> playAmbientSound(String soundName) async {
    // Запоминаем, играл ли глобальный плеер
    if (state.isGlobalPlayerActive && state.isPlaying) {
      _wasGlobalPlayerActiveBeforeAmbient = true;
    }
    await pauseGlobalPlayer();

    await _player.stop();

    if (soundName == 'None') {
      state = state.copyWith(isGlobalPlayerActive: false);
      return;
    }

    final assetPath = getSoundAssetPath(soundName);
    if (assetPath.isNotEmpty) {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.play(AssetSource(assetPath));
      state = state.copyWith(isPlaying: true, isGlobalPlayerActive: false);
    }
  }

  Future<void> stopAmbientSound() async {
    if (!state.isGlobalPlayerActive) {
      await _player.stop();
      state = state.copyWith(isPlaying: false);
    }
  }

  // НОВЫЙ МЕТОД
  Future<void> resumeGlobalPlayerIfNeeded() async {
    if (_wasGlobalPlayerActiveBeforeAmbient) {
      await _playCurrentGlobalTrack();
      _wasGlobalPlayerActiveBeforeAmbient = false; // Сбрасываем флаг
    }
  }

  Future<void> _playCurrentGlobalTrack() async {
    if (_playlist.isEmpty) return;
    final track = _playlist[_currentIndex];
    
    await _player.setReleaseMode(ReleaseMode.stop); 
    await _player.play(AssetSource(track.assetPath));
    
    state = state.copyWith(
      isPlaying: true, 
      currentTrack: track,
      isGlobalPlayerActive: true,
    );
  }

  void playNext() {
    if (_playlist.isEmpty) return;
    _currentIndex = (_currentIndex + 1) % _playlist.length;
    _playCurrentGlobalTrack();
  }

  void playPrevious() {
    if (_playlist.isEmpty) return;
    _currentIndex = (_currentIndex - 1 + _playlist.length) % _playlist.length;
    _playCurrentGlobalTrack();
  }

  void toggleGlobalPlayer() {
    if (state.isPlaying && state.isGlobalPlayerActive) {
      pauseGlobalPlayer();
    } else {
      // ИСПРАВЛЕНИЕ: При возобновлении плеера, останавливаем любой другой звук (например, эмбиент)
      _player.stop();
      _playCurrentGlobalTrack();
    }
  }

  Future<void> pauseGlobalPlayer() async {
    if (state.isGlobalPlayerActive) {
      await _player.pause();
      state = state.copyWith(isPlaying: false);
    }
  }
  
  // ИСПРАВЛЕНО: Метод переименован для ясности и теперь полностью останавливает плеер.
  Future<void> pauseAllAudio() async {
    await _player.pause();
    state = state.copyWith(isPlaying: false);
  }
  
  Future<void> stopAndReset() async {
    await _player.stop();
    state = AudioPlayerState();
    _wasGlobalPlayerActiveBeforeAmbient = false;
  }

  void setVolume(double volume) {
    _player.setVolume(volume);
  }
}

