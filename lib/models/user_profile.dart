import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../utils/input_validator.dart';

@immutable
class UserProfile {
  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;
  final String? countryCode;
  final String? languageCode;
  final String themePreference;
  final String performanceMode;
  final String? manualPerformanceLevel;
  final bool notificationsEnabled;
  final bool anniversaryNotifications;
  final bool motivationalNotifications;
  final bool insightNotifications;
  // --- ENCRYPTION FIELDS ---
  final bool isEncryptionEnabled;
  final String? wrappedDEK; // Data Encryption Key, encrypted with KEK
  final String? salt; // Salt for deriving KEK from master password
  final bool isQuickUnlockEnabled; // NEW: Flag for biometric/PIN unlock
  final bool requireBiometricForMemory; // NEW: Flag for per-memory unlock

  // --- PREMIUM FIELDS ---
  final bool isPremium;
  final DateTime? premiumUntil;
  final DateTime? trialStartedAt;

  // --- NEW VISUAL SETTINGS ---
  final double visualSpeed;
  final double visualAmplitude;
  final double visualYearLinePosition;
  final double visualBranchDensity;
  final double visualBranchIntensity;
  final bool visualAnimationEnabled;

  // --- EMOTION VISUALIZATION SETTINGS ---
  // Timeline (Lifeline) Settings
  final bool enableEmotionalGradient;

  // Level 1: Yearly Gradient (zoom < 0.6)
  final bool enableYearlyGradient;
  final double yearlyGradientIntensity;
  final double yearlyGradientRadius;
  final double yearlyGradientBlur;
  final double yearlyGradientSaturation;

  // Level 2: Monthly Clusters (zoom 0.6-1.2)
  final bool enableMonthlyClusters;
  final double monthlyClusterIntensity;
  final double monthlyClusterRadius;
  final double monthlyClusterBlur;
  final double monthlyClusterSaturation;

  // Level 3: Node Aura (zoom >= 1.2) - для одиночных узлов
  final bool enableNodeAura;
  final double nodeAuraIntensity;
  final double nodeAuraRadius;
  final double nodeAuraBlur;
  final double nodeAuraSaturation;

  // Memory View Screen Settings
  final bool enableMemoryViewGradient;
  final bool enableMemoryViewParticles;
  final bool enablePhotoColorGrading;
  // Performance
  final bool enableHighQualityEffects;

  const UserProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
    this.countryCode,
    this.languageCode,
    this.themePreference = 'system',
    this.performanceMode = 'auto',
    this.manualPerformanceLevel,
    this.notificationsEnabled = true,
    this.anniversaryNotifications = true,
    this.motivationalNotifications = true,
    this.insightNotifications = true,
    this.isEncryptionEnabled = false,
    this.wrappedDEK,
    this.salt,
    this.isQuickUnlockEnabled = false, // Default to false
    this.requireBiometricForMemory = false, // Default to false
    this.isPremium = false,
    this.premiumUntil,
    this.trialStartedAt,
    // --- NEW CONSTRUCTOR PARAMS with defaults ---
    this.visualSpeed = 2.0,
    this.visualAmplitude = 10.0,
    this.visualYearLinePosition = 0.65,
    this.visualBranchDensity = 0.35,
    this.visualBranchIntensity = 0.6,
    this.visualAnimationEnabled = true,
    // --- EMOTION VISUALIZATION PARAMS with defaults ---
    this.enableEmotionalGradient = true,      // ON по умолчанию
    // Level 1: Yearly Gradient
    this.enableYearlyGradient = true,         // ON по умолчанию
    this.yearlyGradientIntensity = 0.4,       // Прозрачность 0.0-1.0
    this.yearlyGradientRadius = 200.0,        // Радиус свечения
    this.yearlyGradientBlur = 150.0,          // Размытие
    this.yearlyGradientSaturation = 1.5,      // Насыщенность цвета
    // Level 2: Monthly Clusters
    this.enableMonthlyClusters = true,        // ON по умолчанию
    this.monthlyClusterIntensity = 0.5,       // Прозрачность 0.0-1.0
    this.monthlyClusterRadius = 100.0,        // Радиус свечения
    this.monthlyClusterBlur = 80.0,           // Размытие
    this.monthlyClusterSaturation = 1.5,      // Насыщенность цвета
    // Level 3: Node Aura (одиночные узлы)
    this.enableNodeAura = true,               // ON по умолчанию
    this.nodeAuraIntensity = 0.525,           // Прозрачность (увеличено на 50%)
    this.nodeAuraRadius = 3.75,               // Множитель радиуса (nodeRadius * 3.75)
    this.nodeAuraBlur = 1.0,                  // Множитель размытия
    this.nodeAuraSaturation = 1.0,            // Насыщенность цвета
    // Memory View Screen
    this.enableMemoryViewGradient = true,     // ON по умолчанию
    this.enableMemoryViewParticles = false,   // OFF по умолчанию (PREMIUM)
    this.enablePhotoColorGrading = false,     // OFF по умолчанию (PREMIUM)
    this.enableHighQualityEffects = true,     // ON по умолчанию
  });

  UserProfile copyWith({
    String? displayName,
    String? photoUrl,
    String? countryCode,
    String? languageCode,
    String? themePreference,
    String? performanceMode,
    String? manualPerformanceLevel,
    bool? notificationsEnabled,
    bool? anniversaryNotifications,
    bool? motivationalNotifications,
    bool? insightNotifications,
    bool? isEncryptionEnabled,
    String? wrappedDEK,
    String? salt,
    bool? isQuickUnlockEnabled,
    bool? requireBiometricForMemory,
    bool? isPremium,
    DateTime? premiumUntil,
    DateTime? trialStartedAt,
    // --- NEW copyWith PARAMS ---
    double? visualSpeed,
    double? visualAmplitude,
    double? visualYearLinePosition,
    double? visualBranchDensity,
    double? visualBranchIntensity,
    bool? visualAnimationEnabled,
    // --- EMOTION VISUALIZATION copyWith PARAMS ---
    bool? enableEmotionalGradient,
    // Level 1: Yearly Gradient
    bool? enableYearlyGradient,
    double? yearlyGradientIntensity,
    double? yearlyGradientRadius,
    double? yearlyGradientBlur,
    double? yearlyGradientSaturation,
    // Level 2: Monthly Clusters
    bool? enableMonthlyClusters,
    double? monthlyClusterIntensity,
    double? monthlyClusterRadius,
    double? monthlyClusterBlur,
    double? monthlyClusterSaturation,
    // Level 3: Node Aura
    bool? enableNodeAura,
    double? nodeAuraIntensity,
    double? nodeAuraRadius,
    double? nodeAuraBlur,
    double? nodeAuraSaturation,
    // Memory View
    bool? enableMemoryViewGradient,
    bool? enableMemoryViewParticles,
    bool? enablePhotoColorGrading,
    bool? enableHighQualityEffects,
  }) {
    // Validate displayName if provided
    if (displayName != null) {
      final validation = InputValidator.validateUserName(displayName);
      if (!validation.isValid) {
        throw ArgumentError('Invalid display name: ${validation.error}');
      }
    }

    return UserProfile(
      uid: uid,
      email: email,
      displayName: displayName != null ? InputValidator.validateUserName(displayName).value! : this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      countryCode: countryCode ?? this.countryCode,
      languageCode: languageCode ?? this.languageCode,
      themePreference: themePreference ?? this.themePreference,
      performanceMode: performanceMode ?? this.performanceMode,
      manualPerformanceLevel:
          manualPerformanceLevel ?? this.manualPerformanceLevel,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      anniversaryNotifications: anniversaryNotifications ?? this.anniversaryNotifications,
      motivationalNotifications: motivationalNotifications ?? this.motivationalNotifications,
      insightNotifications: insightNotifications ?? this.insightNotifications,
      isEncryptionEnabled: isEncryptionEnabled ?? this.isEncryptionEnabled,
      wrappedDEK: wrappedDEK ?? this.wrappedDEK,
      salt: salt ?? this.salt,
      isQuickUnlockEnabled: isQuickUnlockEnabled ?? this.isQuickUnlockEnabled,
      requireBiometricForMemory:
          requireBiometricForMemory ?? this.requireBiometricForMemory,
      isPremium: isPremium ?? this.isPremium,
      premiumUntil: premiumUntil ?? this.premiumUntil,
      trialStartedAt: trialStartedAt ?? this.trialStartedAt,
      // --- NEW copyWith ASSIGNMENTS ---
      visualSpeed: visualSpeed ?? this.visualSpeed,
      visualAmplitude: visualAmplitude ?? this.visualAmplitude,
      visualYearLinePosition:
          visualYearLinePosition ?? this.visualYearLinePosition,
      visualBranchDensity: visualBranchDensity ?? this.visualBranchDensity,
      visualBranchIntensity:
          visualBranchIntensity ?? this.visualBranchIntensity,
      visualAnimationEnabled:
          visualAnimationEnabled ?? this.visualAnimationEnabled,
      // --- EMOTION VISUALIZATION copyWith ASSIGNMENTS ---
      enableEmotionalGradient: enableEmotionalGradient ?? this.enableEmotionalGradient,
      // Level 1
      enableYearlyGradient: enableYearlyGradient ?? this.enableYearlyGradient,
      yearlyGradientIntensity: yearlyGradientIntensity ?? this.yearlyGradientIntensity,
      yearlyGradientRadius: yearlyGradientRadius ?? this.yearlyGradientRadius,
      yearlyGradientBlur: yearlyGradientBlur ?? this.yearlyGradientBlur,
      yearlyGradientSaturation: yearlyGradientSaturation ?? this.yearlyGradientSaturation,
      // Level 2
      enableMonthlyClusters: enableMonthlyClusters ?? this.enableMonthlyClusters,
      monthlyClusterIntensity: monthlyClusterIntensity ?? this.monthlyClusterIntensity,
      monthlyClusterRadius: monthlyClusterRadius ?? this.monthlyClusterRadius,
      monthlyClusterBlur: monthlyClusterBlur ?? this.monthlyClusterBlur,
      monthlyClusterSaturation: monthlyClusterSaturation ?? this.monthlyClusterSaturation,
      // Level 3
      enableNodeAura: enableNodeAura ?? this.enableNodeAura,
      nodeAuraIntensity: nodeAuraIntensity ?? this.nodeAuraIntensity,
      nodeAuraRadius: nodeAuraRadius ?? this.nodeAuraRadius,
      nodeAuraBlur: nodeAuraBlur ?? this.nodeAuraBlur,
      nodeAuraSaturation: nodeAuraSaturation ?? this.nodeAuraSaturation,
      // Memory View
      enableMemoryViewGradient: enableMemoryViewGradient ?? this.enableMemoryViewGradient,
      enableMemoryViewParticles: enableMemoryViewParticles ?? this.enableMemoryViewParticles,
      enablePhotoColorGrading: enablePhotoColorGrading ?? this.enablePhotoColorGrading,
      enableHighQualityEffects: enableHighQualityEffects ?? this.enableHighQualityEffects,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'countryCode': countryCode,
      'languageCode': languageCode,
      'themePreference': themePreference,
      'performanceMode': performanceMode,
      'manualPerformanceLevel': manualPerformanceLevel,
      'notificationsEnabled': notificationsEnabled,
      'anniversaryNotifications': anniversaryNotifications,
      'motivationalNotifications': motivationalNotifications,
      'insightNotifications': insightNotifications,
      'isEncryptionEnabled': isEncryptionEnabled,
      'wrappedDEK': wrappedDEK,
      'salt': salt,
      'isQuickUnlockEnabled': isQuickUnlockEnabled,
      'requireBiometricForMemory': requireBiometricForMemory,
      'isPremium': isPremium,
      'premiumUntil':
          premiumUntil != null ? Timestamp.fromDate(premiumUntil!) : null,
      'trialStartedAt':
          trialStartedAt != null ? Timestamp.fromDate(trialStartedAt!) : null,
      // --- NEW toJson FIELDS ---
      'visualSpeed': visualSpeed,
      'visualAmplitude': visualAmplitude,
      'visualYearLinePosition': visualYearLinePosition,
      'visualBranchDensity': visualBranchDensity,
      'visualBranchIntensity': visualBranchIntensity,
      'visualAnimationEnabled': visualAnimationEnabled,
      // --- EMOTION VISUALIZATION toJson FIELDS ---
      'enableEmotionalGradient': enableEmotionalGradient,
      // Level 1
      'enableYearlyGradient': enableYearlyGradient,
      'yearlyGradientIntensity': yearlyGradientIntensity,
      'yearlyGradientRadius': yearlyGradientRadius,
      'yearlyGradientBlur': yearlyGradientBlur,
      'yearlyGradientSaturation': yearlyGradientSaturation,
      // Level 2
      'enableMonthlyClusters': enableMonthlyClusters,
      'monthlyClusterIntensity': monthlyClusterIntensity,
      'monthlyClusterRadius': monthlyClusterRadius,
      'monthlyClusterBlur': monthlyClusterBlur,
      'monthlyClusterSaturation': monthlyClusterSaturation,
      // Level 3
      'enableNodeAura': enableNodeAura,
      'nodeAuraIntensity': nodeAuraIntensity,
      'nodeAuraRadius': nodeAuraRadius,
      'nodeAuraBlur': nodeAuraBlur,
      'nodeAuraSaturation': nodeAuraSaturation,
      // Memory View
      'enableMemoryViewGradient': enableMemoryViewGradient,
      'enableMemoryViewParticles': enableMemoryViewParticles,
      'enablePhotoColorGrading': enablePhotoColorGrading,
      'enableHighQualityEffects': enableHighQualityEffects,
    };
  }

  factory UserProfile.fromJson(String uid, Map<String, dynamic> json) {
    return UserProfile(
      uid: uid,
      displayName: json['displayName'] as String,
      email: json['email'] as String,
      photoUrl: json['photoUrl'] as String?,
      countryCode: json['countryCode'] as String?,
      languageCode: json['languageCode'] as String?,
      themePreference: json['themePreference'] as String? ?? 'system',
      performanceMode: json['performanceMode'] as String? ?? 'auto',
      manualPerformanceLevel: json['manualPerformanceLevel'] as String?,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      anniversaryNotifications: json['anniversaryNotifications'] as bool? ?? true,
      motivationalNotifications: json['motivationalNotifications'] as bool? ?? true,
      insightNotifications: json['insightNotifications'] as bool? ?? true,
      isEncryptionEnabled: json['isEncryptionEnabled'] as bool? ?? false,
      wrappedDEK: json['wrappedDEK'] as String?,
      salt: json['salt'] as String?,
      isQuickUnlockEnabled: json['isQuickUnlockEnabled'] as bool? ?? false,
      requireBiometricForMemory:
          json['requireBiometricForMemory'] as bool? ?? false,
      isPremium: json['isPremium'] as bool? ?? false,
      premiumUntil: (json['premiumUntil'] as Timestamp?)?.toDate(),
      trialStartedAt: (json['trialStartedAt'] as Timestamp?)?.toDate(),
      // --- NEW fromJson ASSIGNMENTS with defaults ---
      visualSpeed: (json['visualSpeed'] as num?)?.toDouble() ?? 2.0,
      visualAmplitude: (json['visualAmplitude'] as num?)?.toDouble() ?? 10.0,
      visualYearLinePosition:
          (json['visualYearLinePosition'] as num?)?.toDouble() ?? 0.65,
      visualBranchDensity:
          (json['visualBranchDensity'] as num?)?.toDouble() ?? 0.35,
      visualBranchIntensity:
          (json['visualBranchIntensity'] as num?)?.toDouble() ?? 0.6,
      visualAnimationEnabled: json['visualAnimationEnabled'] as bool? ?? true,
      // --- EMOTION VISUALIZATION fromJson ASSIGNMENTS with defaults ---
      enableEmotionalGradient: json['enableEmotionalGradient'] as bool? ?? true,
      // Level 1
      enableYearlyGradient: json['enableYearlyGradient'] as bool? ?? true,
      yearlyGradientIntensity: (json['yearlyGradientIntensity'] as num?)?.toDouble() ?? 0.4,
      yearlyGradientRadius: (json['yearlyGradientRadius'] as num?)?.toDouble() ?? 200.0,
      yearlyGradientBlur: (json['yearlyGradientBlur'] as num?)?.toDouble() ?? 150.0,
      yearlyGradientSaturation: (json['yearlyGradientSaturation'] as num?)?.toDouble() ?? 1.5,
      // Level 2
      enableMonthlyClusters: json['enableMonthlyClusters'] as bool? ?? true,
      monthlyClusterIntensity: (json['monthlyClusterIntensity'] as num?)?.toDouble() ?? 0.5,
      monthlyClusterRadius: (json['monthlyClusterRadius'] as num?)?.toDouble() ?? 100.0,
      monthlyClusterBlur: (json['monthlyClusterBlur'] as num?)?.toDouble() ?? 80.0,
      monthlyClusterSaturation: (json['monthlyClusterSaturation'] as num?)?.toDouble() ?? 1.5,
      // Level 3
      enableNodeAura: json['enableNodeAura'] as bool? ?? true,
      nodeAuraIntensity: (json['nodeAuraIntensity'] as num?)?.toDouble() ?? 0.525,
      nodeAuraRadius: (json['nodeAuraRadius'] as num?)?.toDouble() ?? 3.75,
      nodeAuraBlur: (json['nodeAuraBlur'] as num?)?.toDouble() ?? 1.0,
      nodeAuraSaturation: (json['nodeAuraSaturation'] as num?)?.toDouble() ?? 1.0,
      // Memory View
      enableMemoryViewGradient: json['enableMemoryViewGradient'] as bool? ?? true,
      enableMemoryViewParticles: json['enableMemoryViewParticles'] as bool? ?? false,
      enablePhotoColorGrading: json['enablePhotoColorGrading'] as bool? ?? false,
      enableHighQualityEffects: json['enableHighQualityEffects'] as bool? ?? true,
    );
  }
}
