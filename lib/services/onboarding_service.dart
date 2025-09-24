import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _onboardingCompletedKey = 'hasCompletedOnboarding';

/// Defines all the steps in the onboarding process.
enum OnboardingStep {
  none,
  welcome,
  lifelineIntro,
  encryptionIntro, // NEW STEP
  addFirstMemory,
  navigationGestures,
  controlsPanel,
  statsCard,
  finalWords,
}

/// Represents the current state of the onboarding process.
@immutable
class OnboardingState {
  final OnboardingStep currentStep;
  final bool isActive;
  final bool hasCompleted;

  const OnboardingState({
    this.currentStep = OnboardingStep.none,
    this.isActive = false,
    this.hasCompleted = false,
  });

  OnboardingState copyWith({
    OnboardingStep? currentStep,
    bool? isActive,
    bool? hasCompleted,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      isActive: isActive ?? this.isActive,
      hasCompleted: hasCompleted ?? this.hasCompleted,
    );
  }
}

/// Manages the state and flow of the user onboarding process.
class OnboardingNotifier extends StateNotifier<OnboardingState> {
  late final Future<void> _loadingFuture;
  bool _isLoaded = false;

  OnboardingNotifier() : super(const OnboardingState()) {
    _loadingFuture = _loadOnboardingStatus();
  }

  Future<void> _loadOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final hasCompleted = prefs.getBool(_onboardingCompletedKey) ?? false;
    state = state.copyWith(hasCompleted: hasCompleted);
    _isLoaded = true;
  }

  /// Starts the onboarding process if it hasn't been completed before.
  void startOnAppLaunch() async {
    if (!_isLoaded) {
      await _loadingFuture; // Ensure loading is finished before proceeding
    }
    if (!mounted) return;

    if (!state.hasCompleted && state.currentStep == OnboardingStep.none) {
      state = state.copyWith(isActive: true, currentStep: OnboardingStep.welcome);
    }
  }

  // ИСПРАВЛЕНИЕ: Новый метод для принудительного запуска обучения, например, из профиля.
  /// Force-starts the onboarding tour, regardless of completion status.
  /// This is used for replaying the tutorial.
  void startTour() {
    if (kDebugMode) {
      print("[OnboardingService] Forcing tour to start.");
    }
    // Этот метод намеренно не проверяет hasCompleted, чтобы позволить повторный запуск.
    state = state.copyWith(isActive: true, currentStep: OnboardingStep.welcome);
  }


  /// Advances the onboarding to the next step in the sequence.
  void nextStep() {
    if (!state.isActive) return;

    OnboardingStep nextStep;
    switch (state.currentStep) {
      case OnboardingStep.welcome:
        nextStep = OnboardingStep.lifelineIntro;
        break;
      case OnboardingStep.lifelineIntro:
        nextStep = OnboardingStep.encryptionIntro; // Go to encryption next
        break;
      case OnboardingStep.encryptionIntro:
        nextStep = OnboardingStep.addFirstMemory; // Then to add memory
        break;
      case OnboardingStep.addFirstMemory:
        // SIMPLIFIED: Just move to the next step without forcing creation.
        nextStep = OnboardingStep.navigationGestures;
        break;
      case OnboardingStep.navigationGestures:
        nextStep = OnboardingStep.controlsPanel;
        break;
      case OnboardingStep.controlsPanel:
        nextStep = OnboardingStep.statsCard;
        break;
      case OnboardingStep.statsCard:
        nextStep = OnboardingStep.finalWords;
        break;
      case OnboardingStep.finalWords:
        complete();
        return;
      default:
        nextStep = OnboardingStep.none;
    }
    state = state.copyWith(currentStep: nextStep);
  }

  /// Skips the onboarding process entirely.
  Future<void> skip() async {
    state = state.copyWith(isActive: false, currentStep: OnboardingStep.none);
    await _markAsCompleted();
  }

  /// Marks the onboarding as completed.
  Future<void> complete() async {
    state = state.copyWith(isActive: false, currentStep: OnboardingStep.none);
    await _markAsCompleted();
  }

  /// Resets the onboarding status, allowing it to be replayed.
  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompletedKey, false);
    state = const OnboardingState(hasCompleted: false);
  }

  Future<void> _markAsCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompletedKey, true);
    state = state.copyWith(hasCompleted: true);
  }
}
