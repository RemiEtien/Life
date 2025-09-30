import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';
import '../providers/application_providers.dart';
import '../screens/profile_screen.dart';
import '../services/onboarding_service.dart';

// --- НОВЫЙ ЦВЕТ ДЛЯ ЕДИНОГО СТИЛЯ ---
const Color _onboardingBackgroundColor = Color(0xFF3a2e2d);

/// Helper to get the configuration for each onboarding step from l10n.
Map<String, String?> _getStepConfig(OnboardingStep step, AppLocalizations l10n) {
  switch (step) {
    case OnboardingStep.lifelineIntro:
      return {
        'text': l10n.onboardingLifelineIntroText,
        'button': l10n.onboardingLifelineIntroButton
      };
    case OnboardingStep.addFirstMemory:
      return {'text': l10n.onboardingAddMemoryText, 'button': null};
    case OnboardingStep.navigationGestures:
      return {
        'text': l10n.onboardingNavGesturesText,
        'button': l10n.onboardingContinueButton
      };
    case OnboardingStep.controlsPanel:
      return {
        'text': l10n.onboardingControlsPanelText,
        'button': l10n.onboardingControlsPanelButton
      };
    case OnboardingStep.statsCard:
      return {
        'text': l10n.onboardingStatsCardText,
        'button': l10n.onboardingStatsCardButton
      };
    default:
      return {};
  }
}

/// A widget that displays the onboarding overlay with a spotlight effect.
class OnboardingOverlay extends ConsumerStatefulWidget {
  final GlobalKey? fabKey;
  final GlobalKey? statsCardKey;
  final GlobalKey? controlsPanelKey;

  const OnboardingOverlay({
    super.key,
    this.fabKey,
    this.statsCardKey,
    this.controlsPanelKey,
  });

  @override
  ConsumerState<OnboardingOverlay> createState() => _OnboardingOverlayState();
}

class _OnboardingOverlayState extends ConsumerState<OnboardingOverlay> {
  Rect? _targetRect;
  OnboardingStep? _currentStep;
  late final StreamSubscription _onboardingSubscription;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      debugPrint('[Onboarding] initState: Setting up listener.');
    }
    // Using a direct stream subscription for more control
    _onboardingSubscription =
        ref.read(onboardingServiceProvider.notifier).stream.listen((next) {
      if (kDebugMode) {
        debugPrint(
            '[Onboarding] Listener Fired! Step: ${next.currentStep}. IsActive: ${next.isActive}');
      }
      if (_currentStep != next.currentStep || next.isActive) {
        _currentStep = next.currentStep;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _calculateRect();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _onboardingSubscription.cancel();
    super.dispose();
  }

  void _calculateRect() {
    final step = ref.read(onboardingServiceProvider).currentStep;
    if (kDebugMode) {
      debugPrint('[Onboarding] CALC_RECT START for $step');
    }

    final targetKey = _getTargetKey(step);
    final overlayRenderBox = context.findRenderObject() as RenderBox?;

    if (!mounted || overlayRenderBox == null) {
      if (kDebugMode) {
        debugPrint(
            '[Onboarding] CALC_RECT ABORT: Not mounted or overlayRenderBox is null.');
      }
      return;
    }

    if (targetKey == null) {
      if (kDebugMode) {
        debugPrint(
            '[Onboarding] CALC_RECT INFO: No target key for step $step. Clearing rect.');
      }
      if (_targetRect != null) {
        setState(() => _targetRect = null);
      }
      return;
    }

    final RenderBox? targetRenderBox =
        targetKey.currentContext?.findRenderObject() as RenderBox?;

    if (targetRenderBox != null && targetRenderBox.hasSize) {
      final globalRect =
          targetRenderBox.localToGlobal(Offset.zero) & targetRenderBox.size;
      // Translate the global rect to the local coordinates of the overlay
      final localTopLeft = overlayRenderBox.globalToLocal(globalRect.topLeft);
      final localRect = localTopLeft & globalRect.size;

      if (kDebugMode) {
        debugPrint(
            '[Onboarding] CALC_RECT SUCCESS: Global=$globalRect, Local=$localRect');
      }

      if (_targetRect != localRect) {
        setState(() => _targetRect = localRect);
      }
    } else {
      if (kDebugMode) {
        debugPrint(
            '[Onboarding] CALC_RECT RETRY: Target RenderBox not ready for $step. Scheduling retry.');
      }
      // Retry on the next frame if the widget layout is not ready yet
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _calculateRect();
      });
    }
  }

  GlobalKey? _getTargetKey(OnboardingStep step) {
    switch (step) {
      case OnboardingStep.addFirstMemory:
        return widget.fabKey;
      case OnboardingStep.statsCard:
        return widget.statsCardKey;
      case OnboardingStep.controlsPanel:
        return widget.controlsPanelKey;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final onboardingState = ref.watch(onboardingServiceProvider);
    final notifier = ref.read(onboardingServiceProvider.notifier);
    final l10n = AppLocalizations.of(context)!;

    if (!onboardingState.isActive) {
      return const SizedBox.shrink();
    }

    // Recalculate rect if the step has changed
    if (_currentStep != onboardingState.currentStep) {
      _currentStep = onboardingState.currentStep;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _calculateRect();
        }
      });
    }

    // Handle full-screen dialog steps
    switch (onboardingState.currentStep) {
      case OnboardingStep.welcome:
        return _WelcomeDialog(notifier: notifier, l10n: l10n);
      case OnboardingStep.encryptionIntro:
        return _EncryptionDialog(notifier: notifier, l10n: l10n);
      case OnboardingStep.navigationGestures:
        return _GesturesDialog(notifier: notifier, l10n: l10n);
      case OnboardingStep.finalWords:
        return _FinalWordsDialog(notifier: notifier, l10n: l10n);
      default:
        break; // Continue to the spotlight overlay
    }

    final config = _getStepConfig(onboardingState.currentStep, l10n);
    final String? text = config['text'];
    final String? buttonText = config['button'];
    final isCircle =
        onboardingState.currentStep == OnboardingStep.addFirstMemory;
    final isAddMemoryStep =
        onboardingState.currentStep == OnboardingStep.addFirstMemory;

    return Stack(
      children: [
        // Layer 1: The visual spotlight effect
        Positioned.fill(
          child: CustomPaint(
            size: Size.infinite,
            painter: SpotlightPainter(
              spotlightRect: _targetRect,
              isCircle: isCircle,
            ),
          ),
        ),
        // Layer 2: The gesture detector to handle taps
        Positioned.fill(
          child: GestureDetector(
            onTap: () {
              if (isAddMemoryStep) {
                notifier.nextStep();
              }
            },
            child: Container(color: Colors.transparent),
          ),
        ),
        // Layer 3: The coachmark text and button
        if (text != null)
          _Coachmark(
            text: text,
            buttonText: buttonText,
            targetRect: _targetRect,
            onAction: notifier.nextStep,
          ),
        // Layer 4: The "Skip" button, always on top
        Positioned(
          top: 40,
          right: 16,
          child: TextButton(
            onPressed: notifier.skip,
            child: Text(l10n.onboardingSkipTourButton,
                style: const TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ),
      ],
    );
  }
}

// All helper widgets are now passed the l10n object.

class _WelcomeDialog extends StatelessWidget {
  final OnboardingNotifier notifier;
  final AppLocalizations l10n;
  const _WelcomeDialog({required this.notifier, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return _buildDialogBase(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.onboardingWelcomeTitle,
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Text(
            l10n.onboardingWelcomeSubtitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              TextButton(
                  onPressed: notifier.skip,
                  child: Text(l10n.onboardingSkipButton)),
              ElevatedButton(
                  onPressed: notifier.nextStep,
                  child: Text(l10n.onboardingBeginTourButton)),
            ],
          ),
        ],
      ),
    );
  }
}

class _EncryptionDialog extends ConsumerWidget {
  final OnboardingNotifier notifier;
  final AppLocalizations l10n;
  const _EncryptionDialog({required this.notifier, required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider).value;
    final isEncryptionEnabled = userProfile?.isEncryptionEnabled ?? false;

    if (isEncryptionEnabled) {
      return _buildDialogBase(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shield,
                size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(l10n.onboardingEncryptionActiveTitle,
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Text(
              l10n.onboardingEncryptionActiveSubtitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
                onPressed: notifier.nextStep,
                child: Text(l10n.onboardingEncryptionContinueButton)),
          ],
        ),
      );
    }

    return _buildDialogBase(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield_outlined,
              size: 48, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text(l10n.onboardingEncryptionTitle,
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Text(
            l10n.onboardingEncryptionSubtitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              TextButton(
                  onPressed: notifier.nextStep,
                  child: Text(l10n.onboardingEncryptionLaterButton)),
              ElevatedButton(
                  onPressed: () async {
                    final success =
                        await showCreateMasterPasswordDialog(context, ref);
                    if (success) {
                      notifier.nextStep();
                    }
                  },
                  child: Text(l10n.onboardingEncryptionSetupButton)),
            ],
          ),
        ],
      ),
    );
  }
}

class _GesturesDialog extends StatelessWidget {
  final OnboardingNotifier notifier;
  final AppLocalizations l10n;
  const _GesturesDialog({required this.notifier, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return _buildDialogBase(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.onboardingGesturesTitle,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(children: [
                const Icon(Icons.swipe, size: 40),
                const SizedBox(height: 8),
                Text(l10n.onboardingGestureSwipe)
              ]),
              Column(children: [
                const Icon(Icons.zoom_in_map, size: 40),
                const SizedBox(height: 8),
                Text(l10n.onboardingGesturePinch)
              ]),
            ],
          ),
          const SizedBox(height: 16),
          Text(l10n.onboardingGesturesSubtitle, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton(
              onPressed: notifier.nextStep,
              child: Text(l10n.onboardingContinueButton)),
        ],
      ),
    );
  }
}

class _FinalWordsDialog extends StatelessWidget {
  final OnboardingNotifier notifier;
  final AppLocalizations l10n;
  const _FinalWordsDialog({required this.notifier, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return _buildDialogBase(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.onboardingFinalTitle,
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Text(l10n.onboardingFinalSubtitle, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton(
              onPressed: notifier.complete,
              child: Text(l10n.onboardingStartJourneyButton)),
        ],
      ),
    );
  }
}

Widget _buildDialogBase({required Widget child}) {
  return Container(
    color: Colors.black.withOpacity(0.5),
    child: Center(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Dialog(
          backgroundColor: _onboardingBackgroundColor.withOpacity(0.9),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: child,
          ),
        ),
      ),
    ),
  );
}

class SpotlightPainter extends CustomPainter {
  final Rect? spotlightRect;
  final bool isCircle;

  SpotlightPainter({this.spotlightRect, this.isCircle = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.8);
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    if (spotlightRect != null) {
      final spotlightPath = Path();
      // Inflate rect slightly for a better visual buffer around the target
      final holeRect = isCircle
          ? spotlightRect!.inflate(20.0)
          : spotlightRect!.inflate(12.0);

      if (isCircle) {
        spotlightPath.addOval(holeRect);
      } else {
        spotlightPath.addRRect(
            RRect.fromRectAndRadius(holeRect, const Radius.circular(16)));
      }

      canvas.drawPath(
        Path.combine(PathOperation.difference, backgroundPath, spotlightPath),
        paint,
      );
    } else {
      // Fallback for steps without a specific target (e.g., introduction)
      final center = size.center(Offset.zero);
      final radius = size.width * 0.4;
      final radialGradient = RadialGradient(
        colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
        stops: const [0.5, 1.0],
      );
      final gradientPaint = Paint()
        ..shader = radialGradient
            .createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawRect(
          Rect.fromLTWH(0, 0, size.width, size.height), gradientPaint);
    }
  }

  @override
  bool shouldRepaint(covariant SpotlightPainter oldDelegate) {
    return oldDelegate.spotlightRect != spotlightRect ||
        oldDelegate.isCircle != isCircle;
  }
}

class _Coachmark extends StatelessWidget {
  final String text;
  final String? buttonText;
  final Rect? targetRect;
  final VoidCallback onAction;

  const _Coachmark({
    required this.text,
    this.buttonText,
    this.targetRect,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Determine if the target is in the top or bottom half of the screen
    final bool isTargetOnTop =
        (targetRect?.center.dy ?? size.height / 2) < size.height / 2;

    if (targetRect == null && buttonText == null) {
      return const SizedBox.shrink();
    }

    final Widget content = Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _onboardingBackgroundColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: GoogleFonts.openSans(
                  color: Colors.white, fontSize: 16, height: 1.5),
            ),
            if (buttonText != null) ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: onAction,
                  child: Text(buttonText!),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    return Positioned(
      top: isTargetOnTop ? (targetRect?.bottom ?? size.height / 2) + 20 : null,
      bottom: !isTargetOnTop
          ? (size.height - (targetRect?.top ?? size.height / 2)) + 20
          : null,
      left: 24,
      right: 24,
      child: IgnorePointer(
        // The coachmark itself should be ignored if it has no button.
        // Taps will pass through to the GestureDetector underneath.
        ignoring: buttonText == null,
        child: content,
      ),
    );
  }
}
