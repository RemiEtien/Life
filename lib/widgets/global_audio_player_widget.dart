import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../providers/application_providers.dart';

class GlobalAudioPlayerWidget extends ConsumerWidget {
  const GlobalAudioPlayerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    // Слушаем состояние плеера, чтобы обновлять иконку
    final audioState = ref.watch(audioPlayerProvider);

    // ИСПРАВЛЕНО: Удалено условие, которое скрывало виджет.
    // Теперь плеер будет отображаться всегда.

    return Positioned(
      top: 16,
      left: 16,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 48,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.skip_previous, color: Colors.white70),
                  onPressed: () => ref.read(audioPlayerProvider.notifier).playPrevious(),
                  tooltip: l10n.audioPlayerPreviousTooltip,
                  iconSize: 22,
                ),
                IconButton(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    // Иконка по-прежнему зависит от состояния (играет/пауза)
                    audioState.isPlaying && audioState.isGlobalPlayerActive
                        ? Icons.pause_circle_outline
                        : Icons.play_circle_outline,
                    color: Colors.white,
                  ),
                  onPressed: () => ref.read(audioPlayerProvider.notifier).toggleGlobalPlayer(),
                  tooltip: audioState.isPlaying ? l10n.audioPlayerPauseTooltip : l10n.audioPlayerPlayTooltip,
                  iconSize: 28,
                ),
                IconButton(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.skip_next, color: Colors.white70),
                  onPressed: () => ref.read(audioPlayerProvider.notifier).playNext(),
                  tooltip: l10n.audioPlayerNextTooltip,
                  iconSize: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
