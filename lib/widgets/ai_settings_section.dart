import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../models/user_profile.dart';
import '../providers/application_providers.dart';
import '../services/user_service.dart';
import '../utils/safe_logger.dart';
import '../utils/connectivity_helper.dart';

/// AI Settings Section Widget for ProfileScreen
///
/// Displays granular AI feature controls with:
/// - Master AI enable switch with consent dialog
/// - Smart Prompts settings (FREE tier)
/// - Pattern Analysis settings (PREMIUM tier)
/// - Predictive Insights settings (PREMIUM tier)
/// - Privacy controls
class AISettingsSection extends ConsumerWidget {
  const AISettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return profileAsync.when(
      data: (profile) {
        if (profile == null) return const SizedBox.shrink();
        return _buildAISettingsContent(context, ref, profile);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildAISettingsContent(BuildContext context, WidgetRef ref, UserProfile profile) {
    final l10n = AppLocalizations.of(context)!;

    return ExpansionTile(
      title: Text(l10n.aiSettingsTitle),
      subtitle: Text(
        profile.aiEnabled ? l10n.aiSettingsSubtitleEnabled : l10n.aiSettingsSubtitleDisabled,
        style: TextStyle(
          color: profile.aiEnabled ? Colors.green : Colors.grey,
          fontSize: 12,
        ),
      ),
      leading: const Icon(Icons.auto_awesome),
      children: [
        // Master Switch
        SwitchListTile(
          title: Text(l10n.aiSettingsMasterSwitch),
          subtitle: Text(l10n.aiSettingsMasterSwitchSubtitle),
          value: profile.aiEnabled,
          onChanged: (value) {
            if (value && !profile.aiEnabled) {
              // First time activation - show consent dialog
              _showAIConsentDialog(context, ref, profile, l10n);
            } else {
              _updateProfile(ref, profile, {'aiEnabled': value});
            }
          },
        ),

        if (profile.aiEnabled) ...[
          const Divider(),

          // Smart Prompts (FREE)
          ListTile(
            title: Row(
              children: [
                Text(l10n.aiSettingsSmartPrompts),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(l10n.aiSettingsBadgeFree, style: const TextStyle(fontSize: 10, color: Colors.white)),
                ),
              ],
            ),
            subtitle: Text(l10n.aiSettingsSmartPromptsSubtitle),
          ),
          SwitchListTile(
            title: Text('  ${l10n.aiSettingsSmartPromptsInEdit}'),
            value: profile.aiSmartPromptsEnabled && profile.aiSmartPromptsInEdit,
            onChanged: profile.aiSmartPromptsEnabled
                ? (v) => _updateProfile(ref, profile, {'aiSmartPromptsInEdit': v})
                : null,
          ),

          const Divider(),

          // Pattern Analysis (PREMIUM)
          ListTile(
            title: Row(
              children: [
                Text(l10n.aiSettingsPatternAnalysis),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(l10n.aiSettingsBadgePremium, style: const TextStyle(fontSize: 10, color: Colors.white)),
                ),
              ],
            ),
            subtitle: Text(l10n.aiSettingsPatternAnalysisSubtitle),
            trailing: !profile.isPremium
                ? TextButton(
                    onPressed: () => _showPremiumUpgrade(context, l10n),
                    child: Text(l10n.aiSettingsUpgradeButton),
                  )
                : null,
          ),
          if (profile.isPremium) ...[
            SwitchListTile(
              title: Text('  ${l10n.aiSettingsPatternAnalysisEnable}'),
              value: profile.aiPatternAnalysisEnabled,
              onChanged: (v) => _updateProfile(ref, profile, {'aiPatternAnalysisEnabled': v}),
            ),
            if (profile.aiPatternAnalysisEnabled) ...[
              SwitchListTile(
                title: Text('    ${l10n.aiSettingsPatternAnalysisMonthly}'),
                value: profile.aiPatternsInMonthlyView,
                onChanged: (v) => _updateProfile(ref, profile, {'aiPatternsInMonthlyView': v}),
              ),
              SwitchListTile(
                title: Text('    ${l10n.aiSettingsPatternAnalysisMemory}'),
                value: profile.aiPatternsInMemoryView,
                onChanged: (v) => _updateProfile(ref, profile, {'aiPatternsInMemoryView': v}),
              ),
              SwitchListTile(
                title: Text('    ${l10n.aiSettingsPatternAnalysisList}'),
                value: profile.aiPatternsInMemoryList,
                onChanged: (v) => _updateProfile(ref, profile, {'aiPatternsInMemoryList': v}),
              ),
            ],
          ],

          const Divider(),

          // Predictive Insights (PREMIUM)
          ListTile(
            title: Row(
              children: [
                Text(l10n.aiSettingsPredictiveInsights),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(l10n.aiSettingsBadgePremium, style: const TextStyle(fontSize: 10, color: Colors.white)),
                ),
              ],
            ),
            subtitle: Text(l10n.aiSettingsPredictiveInsightsSubtitle),
            trailing: !profile.isPremium
                ? TextButton(
                    onPressed: () => _showPremiumUpgrade(context, l10n),
                    child: Text(l10n.aiSettingsUpgradeButton),
                  )
                : null,
          ),
          if (profile.isPremium) ...[
            SwitchListTile(
              title: Text('  ${l10n.aiSettingsPredictiveInsightsEnable}'),
              value: profile.aiPredictiveInsightsEnabled,
              onChanged: (v) => _updateProfile(ref, profile, {'aiPredictiveInsightsEnabled': v}),
            ),
            if (profile.aiPredictiveInsightsEnabled) ...[
              SwitchListTile(
                title: Text('    ${l10n.aiSettingsPredictiveInsightsEdit}'),
                value: profile.aiPredictiveInEdit,
                onChanged: (v) => _updateProfile(ref, profile, {'aiPredictiveInEdit': v}),
              ),
              SwitchListTile(
                title: Text('    ${l10n.aiSettingsPredictiveInsightsNotifications}'),
                subtitle: Text(l10n.aiSettingsPredictiveInsightsNotificationsSubtitle),
                value: profile.aiPredictiveNotifications,
                onChanged: (v) => _updateProfile(ref, profile, {'aiPredictiveNotifications': v}),
              ),
            ],
          ],

          const Divider(),

          // Privacy Control
          ListTile(
            title: Text(l10n.aiSettingsPrivacyTitle),
            subtitle: Text(l10n.aiSettingsPrivacySubtitle),
          ),
          SwitchListTile(
            title: Text('  ${l10n.aiSettingsPrivacyEncrypted}'),
            subtitle: Text(l10n.aiSettingsPrivacyEncryptedSubtitle),
            value: profile.aiProcessEncryptedMemories,
            onChanged: (v) {
              if (v) {
                _showEncryptedAIWarning(context, ref, profile, l10n);
              } else {
                _updateProfile(ref, profile, {'aiProcessEncryptedMemories': v});
              }
            },
          ),

          // Privacy info card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.privacy_tip, size: 16),
                      const SizedBox(width: 8),
                      Text(l10n.aiSettingsPrivacyInfoTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.aiSettingsPrivacyInfoContent,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _showAIConsentDialog(BuildContext context, WidgetRef ref, UserProfile profile, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.aiConsentDialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• ${l10n.aiConsentDialogBenefit1}'),
            Text('• ${l10n.aiConsentDialogBenefit2}'),
            Text('• ${l10n.aiConsentDialogBenefit3}'),
            const SizedBox(height: 16),
            Text(l10n.aiConsentDialogPrivacyTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('• ${l10n.aiConsentDialogPrivacy1}'),
            Text('• ${l10n.aiConsentDialogPrivacy2}'),
            Text('• ${l10n.aiConsentDialogPrivacy3}'),
            Text('• ${l10n.aiConsentDialogPrivacy4}'),
            const SizedBox(height: 16),
            Text(
              l10n.aiConsentDialogPrivacyNote,
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.aiConsentDialogCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.aiConsentDialogEnable),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Check internet connection before enabling AI
      final hasInternet = await ConnectivityHelper.checkInternetWithWarning(context);
      if (hasInternet) {
        await _updateProfile(ref, profile, {'aiEnabled': true});
      }
    }
  }

  void _showEncryptedAIWarning(BuildContext context, WidgetRef ref, UserProfile profile, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.aiEncryptedWarningTitle),
        content: Text(l10n.aiEncryptedWarningContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.aiEncryptedWarningCancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateProfile(ref, profile, {'aiProcessEncryptedMemories': true});
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text(l10n.aiEncryptedWarningEnable),
          ),
        ],
      ),
    );
  }

  void _showPremiumUpgrade(BuildContext context, AppLocalizations l10n) {
    // TODO: Navigate to premium upgrade screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.aiSettingsUpgradeDialogContent),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _updateProfile(WidgetRef ref, UserProfile profile, Map<String, dynamic> updates) async {
    try {
      final userService = ref.read(userServiceProvider);

      // Create updated profile using copyWith
      UserProfile updatedProfile = profile;

      updates.forEach((key, value) {
        switch (key) {
          case 'aiEnabled':
            updatedProfile = updatedProfile.copyWith(aiEnabled: value as bool);
            break;
          case 'aiSmartPromptsEnabled':
            updatedProfile = updatedProfile.copyWith(aiSmartPromptsEnabled: value as bool);
            break;
          case 'aiSmartPromptsInEdit':
            updatedProfile = updatedProfile.copyWith(aiSmartPromptsInEdit: value as bool);
            break;
          case 'aiPatternAnalysisEnabled':
            updatedProfile = updatedProfile.copyWith(aiPatternAnalysisEnabled: value as bool);
            break;
          case 'aiPatternsInMonthlyView':
            updatedProfile = updatedProfile.copyWith(aiPatternsInMonthlyView: value as bool);
            break;
          case 'aiPatternsInMemoryView':
            updatedProfile = updatedProfile.copyWith(aiPatternsInMemoryView: value as bool);
            break;
          case 'aiPatternsInMemoryList':
            updatedProfile = updatedProfile.copyWith(aiPatternsInMemoryList: value as bool);
            break;
          case 'aiPredictiveInsightsEnabled':
            updatedProfile = updatedProfile.copyWith(aiPredictiveInsightsEnabled: value as bool);
            break;
          case 'aiPredictiveInEdit':
            updatedProfile = updatedProfile.copyWith(aiPredictiveInEdit: value as bool);
            break;
          case 'aiPredictiveNotifications':
            updatedProfile = updatedProfile.copyWith(aiPredictiveNotifications: value as bool);
            break;
          case 'aiProcessEncryptedMemories':
            updatedProfile = updatedProfile.copyWith(aiProcessEncryptedMemories: value as bool);
            break;
        }
      });

      await userService.updateUserProfile(updatedProfile);
      SafeLogger.debug('AI settings updated: $updates', tag: 'AISettingsSection');
    } catch (e, stackTrace) {
      SafeLogger.error('Failed to update AI settings', error: e, stackTrace: stackTrace, tag: 'AISettingsSection');
    }
  }
}
