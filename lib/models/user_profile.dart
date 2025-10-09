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
  final bool enableNodeAura;
  final bool enableWeatherEffects;
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
    this.enableNodeAura = true,               // ON по умолчанию
    this.enableWeatherEffects = false,        // OFF по умолчанию (PREMIUM)
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
    bool? enableNodeAura,
    bool? enableWeatherEffects,
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
      enableNodeAura: enableNodeAura ?? this.enableNodeAura,
      enableWeatherEffects: enableWeatherEffects ?? this.enableWeatherEffects,
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
      'enableNodeAura': enableNodeAura,
      'enableWeatherEffects': enableWeatherEffects,
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
      enableNodeAura: json['enableNodeAura'] as bool? ?? true,
      enableWeatherEffects: json['enableWeatherEffects'] as bool? ?? false,
      enableMemoryViewGradient: json['enableMemoryViewGradient'] as bool? ?? true,
      enableMemoryViewParticles: json['enableMemoryViewParticles'] as bool? ?? false,
      enablePhotoColorGrading: json['enablePhotoColorGrading'] as bool? ?? false,
      enableHighQualityEffects: json['enableHighQualityEffects'] as bool? ?? true,
    );
  }
}
